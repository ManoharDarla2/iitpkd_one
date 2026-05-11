import { and, desc, eq, sql } from 'drizzle-orm';

import { tursoDb as db } from '../../db';
import { messTable, messWeekConfigTable } from '../../db/turso/schema';

type WeekType = 'odd' | 'even';

type MessMenuFilters = {
  weekType?: WeekType;
};

type MessMeals = {
  breakfast?: string[];
  lunch?: string[];
  snacks?: string[];
  dinner?: string[];
};

const WEEK_REFERENCE_UTC = new Date('2026-01-05T00:00:00.000Z');

const normalizeWeekType = (value: string): WeekType => (value.toLowerCase() === 'even' ? 'even' : 'odd');

export class MessService {
  private weekConfigCache: { referenceDate: string; weekType: string } | null | undefined = undefined;

  invalidateWeekConfigCache() {
    this.weekConfigCache = undefined;
  }

  private async getWeekConfig() {
    if (this.weekConfigCache === undefined) {
      const rows = await db
        .select({ referenceDate: messWeekConfigTable.referenceDate, weekType: messWeekConfigTable.weekType })
        .from(messWeekConfigTable)
        .limit(1);
      this.weekConfigCache = rows[0] ?? null;
    }
    return this.weekConfigCache;
  }

  async getMenu(filters: MessMenuFilters) {
    return db
      .select({
        id: messTable.id,
        weekType: messTable.weekType,
        day: messTable.day,
        meals: messTable.meals,
      })
      .from(messTable)
      .where(filters.weekType ? and(eq(messTable.weekType, filters.weekType)) : undefined)
      .orderBy(messTable.weekType, messTable.day);
  }

  private calculateWeekType(date: Date, refDate: Date, baseType: WeekType): WeekType {
    const diffMs = date.getTime() - refDate.getTime();
    const diffWeeks = Math.floor(diffMs / (7 * 24 * 60 * 60 * 1000));
    if (Math.abs(diffWeeks) % 2 === 0) return baseType;
    return baseType === 'odd' ? 'even' : 'odd';
  }

  async calculateCurrentWeek(date = new Date()): Promise<WeekType> {
    const config = await this.getWeekConfig();
    if (config) {
      const refDate = new Date(config.referenceDate + 'T00:00:00.000Z');
      return this.calculateWeekType(date, refDate, config.weekType as WeekType);
    }

    return this.calculateWeekType(date, WEEK_REFERENCE_UTC, 'odd');
  }

  getCurrentDay(date = new Date()) {
    const names: string[] = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    return names[date.getUTCDay()] ?? 'monday';
  }

  async getTodayMenu() {
    const now = new Date();
    const calculatedWeek = await this.calculateCurrentWeek(now);
    const day = this.getCurrentDay(now);

    const rows = await db
      .select({
        id: messTable.id,
        meals: messTable.meals,
      })
      .from(messTable)
      .where(and(eq(messTable.weekType, calculatedWeek), eq(messTable.day, day)))
      .limit(1);

    return {
      date: now.toISOString().slice(0, 10),
      calculatedWeek,
      day,
      meals: (rows[0]?.meals as MessMeals | null) ?? {},
    };
  }

  async getMessMetadata() {
    const rows = await db
      .select({
        updatedAt: messTable.updatedAt,
      })
      .from(messTable)
      .orderBy(desc(messTable.updatedAt))
      .limit(1);

    const updatedAt = rows[0]?.updatedAt ?? null;
    const versionRows = await db
      .select({
        total: sql<number>`count(${messTable.id})`,
      })
      .from(messTable);

    const total = versionRows[0]?.total ?? 0;

    const calculatedWeek = await this.calculateCurrentWeek();

    return {
      updatedAt,
      version: `mess-${total}`,
      calculatedWeek,
    };
  }

  mapMenuWeekType(value: string) {
    return normalizeWeekType(value);
  }
}

export const messService = new MessService();
