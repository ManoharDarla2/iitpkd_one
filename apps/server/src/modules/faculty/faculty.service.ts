import { and, desc, eq } from 'drizzle-orm';

import { db } from '../../db/db';
import { facultyTable } from '../../db/schema';

type FacultyListFilters = {
  department?: string;
};

export class FacultyService {
  async getFacultyList(filters: FacultyListFilters) {
    return db
      .select({
        id: facultyTable.id,
        slug: facultyTable.slug,
        name: facultyTable.name,
        designation: facultyTable.designation,
        department: facultyTable.department,
        imageUrl: facultyTable.imageUrl,
      })
      .from(facultyTable)
      .where(filters.department ? and(eq(facultyTable.department, filters.department)) : undefined)
      .orderBy(facultyTable.name);
  }

  async getFacultyBySlug(slug: string) {
    const rows = await db
      .select({
        id: facultyTable.id,
        slug: facultyTable.slug,
        name: facultyTable.name,
        imageUrl: facultyTable.imageUrl,
        department: facultyTable.department,
        designation: facultyTable.designation,
        email: facultyTable.email,
        biosketch: facultyTable.biosketch,
        teaching: facultyTable.teaching,
        office: facultyTable.office,
        publications: facultyTable.publications,
        additionalInformation: facultyTable.additionalInformation,
      })
      .from(facultyTable)
      .where(eq(facultyTable.slug, slug))
      .limit(1);

    return rows[0] ?? null;
  }

  async getFacultyMetadata() {
    const rows = await db
      .select({
        updatedAt: facultyTable.updatedAt,
      })
      .from(facultyTable)
      .orderBy(desc(facultyTable.updatedAt))
      .limit(1);

    const updatedAt = rows[0]?.updatedAt ?? null;

    return {
      updatedAt,
      version: updatedAt ? updatedAt.toISOString().slice(0, 10) : '0',
    };
  }
}

export const facultyService = new FacultyService();
