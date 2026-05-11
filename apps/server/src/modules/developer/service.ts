import { eq } from 'drizzle-orm';

import { tursoDb as db } from '../../db';
import { messWeekConfigTable } from '../../db/turso/schema';

export class DeveloperService {
  async setWeekType(weekType: 'odd' | 'even') {
    const now = new Date().toISOString().split('T')[0];
    const existing = await db.select().from(messWeekConfigTable).limit(1);

    if (existing.length > 0) {
      const result = await db
        .update(messWeekConfigTable)
        .set({ referenceDate: now, weekType, updatedAt: new Date() })
        .where(eq(messWeekConfigTable.id, existing[0].id))
        .returning();
      return result[0];
    }

    const result = await db
      .insert(messWeekConfigTable)
      .values({ referenceDate: now, weekType })
      .returning();
    return result[0];
  }

  async getWeekConfig() {
    const rows = await db.select().from(messWeekConfigTable).limit(1);
    return rows[0] ?? null;
  }
}

export const developerService = new DeveloperService();
