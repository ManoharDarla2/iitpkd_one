import { and, arrayOverlaps, eq, ilike, or } from 'drizzle-orm';

import { db } from '../../db/db';
import { equipmentTable, facultyTable, messTable, shuttleTable } from '../../db/schema';

type SearchCategory = 'equipment' | 'faculty' | 'schedule';

type SearchFilters = {
  q: string;
  category?: SearchCategory;
  limit: number;
};

type SearchResultItem = {
  id: string;
  category: SearchCategory;
  title: string;
  subtitle: string;
  description: string;
  imageUrl: string;
  metadata: Record<string, string>;
  score: number;
};

const scoreText = (value: string, query: string, highWeight: number, mediumWeight: number): number => {
  const v = value.toLowerCase();
  const q = query.toLowerCase();

  if (v === q) {
    return highWeight;
  }

  if (v.includes(q)) {
    return mediumWeight;
  }

  return 0;
};

const rankAndLimit = (items: SearchResultItem[], limit: number) =>
  items
    .filter((item) => item.score > 0)
    .sort((a, b) => b.score - a.score || a.title.localeCompare(b.title))
    .slice(0, limit)
    .map(({ score: _score, ...item }) => item);

const termToSlug = (value: string) =>
  value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '');

export class SearchService {
  async search(filters: SearchFilters) {
    if (!filters.q.trim()) {
      return {
        query: filters.q,
        category: filters.category ?? null,
        totalCount: 0,
        results: [],
      };
    }

    const buckets: SearchResultItem[] = [];

    if (!filters.category || filters.category === 'equipment') {
      const equipmentRows = await db
        .select({
          id: equipmentTable.id,
          name: equipmentTable.name,
          imageUrl: equipmentTable.imageUrl,
          make: equipmentTable.make,
          model: equipmentTable.model,
          type: equipmentTable.type,
          description: equipmentTable.description,
        })
        .from(equipmentTable)
        .where(
          or(
            ilike(equipmentTable.name, `%${filters.q}%`),
            ilike(equipmentTable.make, `%${filters.q}%`),
            ilike(equipmentTable.model, `%${filters.q}%`),
            ilike(equipmentTable.type, `%${filters.q}%`),
            ilike(equipmentTable.description, `%${filters.q}%`),
          ),
        )
        .limit(filters.limit * 3);

      for (const row of equipmentRows) {
        const score =
          scoreText(row.name, filters.q, 120, 80) +
          scoreText(`${row.make} ${row.model}`.trim(), filters.q, 90, 60) +
          scoreText(row.description, filters.q, 30, 15);

        buckets.push({
          id: `equipment-${row.id}`,
          category: 'equipment',
          title: row.name,
          subtitle: [row.make, row.model].filter(Boolean).join(' ').trim(),
          description: row.description,
          imageUrl: row.imageUrl,
          metadata: {
            make: row.make,
            model: row.model,
            toolType: row.type,
          },
          score,
        });
      }
    }

    if (!filters.category || filters.category === 'faculty') {
      const facultyRows = await db
        .select({
          id: facultyTable.id,
          slug: facultyTable.slug,
          name: facultyTable.name,
          designation: facultyTable.designation,
          department: facultyTable.department,
          imageUrl: facultyTable.imageUrl,
          biosketch: facultyTable.biosketch,
        })
        .from(facultyTable)
        .where(
          or(
            ilike(facultyTable.name, `%${filters.q}%`),
            ilike(facultyTable.department, `%${filters.q}%`),
            ilike(facultyTable.designation, `%${filters.q}%`),
            ilike(facultyTable.biosketch, `%${filters.q}%`),
          ),
        )
        .limit(filters.limit * 3);

      for (const row of facultyRows) {
        const score =
          scoreText(row.name, filters.q, 120, 80) +
          scoreText(row.designation, filters.q, 70, 45) +
          scoreText(row.biosketch, filters.q, 25, 10);

        buckets.push({
          id: `faculty-${row.slug || row.id}`,
          category: 'faculty',
          title: row.name,
          subtitle: row.designation,
          description: row.biosketch,
          imageUrl: row.imageUrl,
          metadata: {
            slug: row.slug,
            department: row.department,
          },
          score,
        });
      }
    }

    if (!filters.category || filters.category === 'schedule') {
      const dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
      const matchedDay = dayNames.find((day) => day.includes(filters.q.toLowerCase()));

      const shuttleRows = await db
        .select({
          id: shuttleTable.id,
          from: shuttleTable.from,
          to: shuttleTable.to,
          time: shuttleTable.time,
          via: shuttleTable.via,
          days: shuttleTable.days,
          isOutsideTrip: shuttleTable.isOutsideTrip,
          isMultipleBuses: shuttleTable.isMultipleBuses,
        })
        .from(shuttleTable)
        .where(and(
          or(
            ilike(shuttleTable.from, `%${filters.q}%`),
            ilike(shuttleTable.to, `%${filters.q}%`),
            ilike(shuttleTable.time, `%${filters.q}%`),
          ),
          ...(matchedDay ? [arrayOverlaps(shuttleTable.days, [matchedDay])] : []),
        ))
        .limit(filters.limit * 2);

      for (const row of shuttleRows) {
        const descriptor = `${row.from} ${row.to} ${row.time}`;
        const score =
          scoreText(descriptor, filters.q, 110, 75) +
          scoreText(row.via.join(' '), filters.q, 45, 25);

        buckets.push({
          id: `schedule-shuttle-${row.id}`,
          category: 'schedule',
          title: `${row.from} -> ${row.to}`,
          subtitle: row.time,
          description: row.via.length ? `Via ${row.via.join(', ')}` : 'Direct shuttle',
          imageUrl: '',
          metadata: {
            kind: 'shuttle',
            isOutsideTrip: String(row.isOutsideTrip),
            isMultipleBuses: String(row.isMultipleBuses),
            days: row.days.join(','),
          },
          score,
        });
      }

      const weekType = filters.q.toLowerCase().includes('even') ? 'even' : filters.q.toLowerCase().includes('odd') ? 'odd' : null;
      const messRows = await db
        .select({
          id: messTable.id,
          weekType: messTable.weekType,
          day: messTable.day,
        })
        .from(messTable)
        .where(and(
          or(
            ilike(messTable.day, `%${filters.q}%`),
            ilike(messTable.weekType, `%${filters.q}%`),
          ),
          ...(weekType ? [eq(messTable.weekType, weekType)] : []),
        ))
        .limit(filters.limit);

      for (const row of messRows) {
        const descriptor = `${row.weekType} ${row.day}`;
        const score = scoreText(descriptor, filters.q, 90, 55);

        buckets.push({
          id: `schedule-mess-${row.id}`,
          category: 'schedule',
          title: `Mess menu - ${row.day}`,
          subtitle: `${row.weekType} week`,
          description: 'Mess schedule item',
          imageUrl: '',
          metadata: {
            kind: 'mess',
            weekType: row.weekType,
            day: row.day,
          },
          score,
        });
      }
    }

    const ranked = rankAndLimit(buckets, filters.limit);

    return {
      query: filters.q,
      category: filters.category ?? null,
      totalCount: ranked.length,
      results: ranked,
    };
  }

  async suggestions(query: string, limit: number) {
    if (!query.trim()) {
      return [
        'Shuttle schedule',
        'Mess menu today',
        'Faculty directory',
        '3D printer',
        'CNC router',
      ].slice(0, limit);
    }

    const [equipmentRows, facultyRows, shuttleRows] = await Promise.all([
      db
        .select({
          term: equipmentTable.name,
        })
        .from(equipmentTable)
        .where(ilike(equipmentTable.name, `${query}%`))
        .limit(limit),
      db
        .select({
          term: facultyTable.name,
        })
        .from(facultyTable)
        .where(ilike(facultyTable.name, `${query}%`))
        .limit(limit),
      db
        .select({
          from: shuttleTable.from,
          to: shuttleTable.to,
        })
        .from(shuttleTable)
        .where(or(ilike(shuttleTable.from, `${query}%`), ilike(shuttleTable.to, `${query}%`)))
        .limit(limit),
    ]);

    const set = new Set<string>();

    for (const row of equipmentRows) {
      if (row.term) {
        set.add(row.term);
      }
    }

    for (const row of facultyRows) {
      if (row.term) {
        set.add(row.term);
      }
    }

    for (const row of shuttleRows) {
      set.add(`${row.from} to ${row.to}`);
    }

    if (set.size < limit) {
      set.add(termToSlug(query).replace(/-/g, ' '));
    }

    return Array.from(set).filter(Boolean).slice(0, limit);
  }
}

export const searchService = new SearchService();
