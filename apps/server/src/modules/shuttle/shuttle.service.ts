import { and, arrayContains, desc, eq, sql } from 'drizzle-orm';

import { db } from '../../db/db';
import { shuttleTable } from '../../db/schema';

type ShuttleFilters = {
  day?: string;
  from?: string;
  to?: string;
};

export class ShuttleService {
  async getShuttles(filters: ShuttleFilters) {
    const clauses = [];

    if (filters.day) {
      clauses.push(arrayContains(shuttleTable.days, [filters.day.toLowerCase()]));
    }

    if (filters.from) {
      clauses.push(eq(shuttleTable.from, filters.from));
    }

    if (filters.to) {
      clauses.push(eq(shuttleTable.to, filters.to));
    }

    return db
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
      .where(clauses.length > 0 ? and(...clauses) : undefined)
      .orderBy(shuttleTable.time, shuttleTable.from, shuttleTable.to);
  }

  async getShuttleMetadata() {
    const latestRows = await db
      .select({
        updatedAt: shuttleTable.updatedAt,
      })
      .from(shuttleTable)
      .orderBy(desc(shuttleTable.updatedAt))
      .limit(1);

    const countRows = await db
      .select({
        total: sql<number>`count(${shuttleTable.id})`,
      })
      .from(shuttleTable);

    const updatedAt = latestRows[0]?.updatedAt ?? null;
    const total = countRows[0]?.total ?? 0;

    return {
      updatedAt,
      version: `shuttle-${total}`,
    };
  }
}

export const shuttleService = new ShuttleService();
