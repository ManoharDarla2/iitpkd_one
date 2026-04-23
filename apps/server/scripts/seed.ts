import 'dotenv/config';
import { promises as fs } from 'node:fs';
import path from 'node:path';

import { db } from '../src/db/db';
import {
  equipmentTable,
  facultyTable,
  messTable,
  shuttleTable,
} from '../src/db/schema';

type FacultyRecord = {
  name: string;
  slug: string;
  image_url?: string;
  department?: string;
  designation?: string;
  email?: string;
  biosketch?: string;
  teaching?: string;
  office?: string;
  publications?: string;
  'additional-information'?: string;
};

type MessRecord = {
  weekType: string;
  day: string;
  meals: {
    breakfast?: string[];
    lunch?: string[];
    snacks?: string[];
    dinner?: string[];
  };
};

type ShuttleRecord = {
  from: string;
  to: string;
  time: string;
  via?: string[];
  days?: string[];
  isOutsideTrip?: boolean;
  isMultipleBuses?: boolean;
};

type EquipmentRecord = {
  title: string;
  images?: string;
  make?: string;
  model?: string;
  type?: string;
  descrption?: string;
};

const dataDir = path.resolve(process.cwd(), 'scripts/data');

function sanitizeJsonContent(raw: string): string {
  return raw
    .replace(/^\uFEFF/, '')
    .replace(/[\u200B-\u200D\u2060\uFEFF]/g, '')
    .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, '');
}

async function readJsonArray<T>(fileName: string): Promise<T[]> {
  const filePath = path.join(dataDir, fileName);
  const raw = await fs.readFile(filePath, 'utf8');
  const sanitized = sanitizeJsonContent(raw);

  let parsed: unknown;
  try {
    parsed = JSON.parse(sanitized);
  } catch (error) {
    throw new Error(`Failed to parse ${fileName}: ${(error as Error).message}`);
  }

  if (!Array.isArray(parsed)) {
    throw new Error(`Expected ${fileName} to contain a top-level JSON array.`);
  }

  return parsed as T[];
}

async function insertInChunks<T extends object>(
  values: T[],
  insertFn: (chunk: T[]) => Promise<unknown>,
  chunkSize = 250,
): Promise<void> {
  for (let i = 0; i < values.length; i += chunkSize) {
    const chunk = values.slice(i, i + chunkSize);
    await insertFn(chunk);
  }
}

async function main(): Promise<void> {
  const [facultyJson, messJson, shuttleJson, equipmentJson] = await Promise.all([
    readJsonArray<FacultyRecord>('faculty_details.json'),
    readJsonArray<MessRecord>('mess-menu.json'),
    readJsonArray<ShuttleRecord>('shuttle-schedule.json'),
    readJsonArray<EquipmentRecord>('equipment-data.json'),
  ]);

  const facultyRows = facultyJson
    .filter((row) => row.name?.trim() && row.slug?.trim())
    .map((row) => ({
      name: row.name.trim(),
      slug: row.slug.trim(),
      imageUrl: row.image_url?.trim() ?? '',
      department: row.department?.trim() ?? '',
      designation: row.designation?.trim() ?? '',
      email: row.email?.trim() ?? '',
      biosketch: row.biosketch?.trim() ?? '',
      teaching: row.teaching?.trim() ?? '',
      office: row.office?.trim() ?? '',
      publications: row.publications?.trim() ?? '',
      additionalInformation: row['additional-information']?.trim() ?? '',
    }));

  const messRows = messJson
    .filter((row) => row.weekType?.trim() && row.day?.trim())
    .map((row) => ({
      weekType: row.weekType.trim().toLowerCase(),
      day: row.day.trim().toLowerCase(),
      meals: {
        breakfast: row.meals?.breakfast ?? [],
        lunch: row.meals?.lunch ?? [],
        snacks: row.meals?.snacks ?? [],
        dinner: row.meals?.dinner ?? [],
      },
    }));

  const shuttleRows = shuttleJson
    .filter((row) => row.from?.trim() && row.to?.trim() && row.time?.trim())
    .map((row) => ({
      from: row.from.trim(),
      to: row.to.trim(),
      time: row.time.trim(),
      via: row.via ?? [],
      days: (row.days ?? []).map((day) => day.trim().toLowerCase()),
      isOutsideTrip: Boolean(row.isOutsideTrip),
      isMultipleBuses: Boolean(row.isMultipleBuses),
    }));

  const equipmentRows = equipmentJson
    .filter((row) => row.title?.trim())
    .map((row) => ({
      name: row.title.trim(),
      imageUrl: row.images?.trim() ?? '',
      make: row.make?.trim() ?? '',
      model: row.model?.trim() ?? '',
      type: row.type?.trim() ?? '',
      description: row.descrption?.trim() ?? '',
    }));


  await db.transaction(async (tx) => {
    await tx.delete(facultyTable);
    await tx.delete(messTable);
    await tx.delete(shuttleTable);
    await tx.delete(equipmentTable);

    await insertInChunks(facultyRows, (chunk) => tx.insert(facultyTable).values(chunk));
    await insertInChunks(messRows, (chunk) => tx.insert(messTable).values(chunk));
    await insertInChunks(shuttleRows, (chunk) => tx.insert(shuttleTable).values(chunk));
    await insertInChunks(equipmentRows, (chunk) => tx.insert(equipmentTable).values(chunk));
  });

  console.log('Seed completed successfully.');
  console.log(
    [
      `Faculty rows: ${facultyRows.length}`,
      `Mess rows: ${messRows.length}`,
      `Shuttle rows: ${shuttleRows.length}`,
      `Equipment rows: ${equipmentRows.length}`,
    ].join('\n'),
  );
}

main().catch((error) => {
  console.error('Seeding failed:', error);
  process.exit(1);
});
