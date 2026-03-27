import { t } from 'elysia';

export const WeekTypeSchema = t.Union([t.Literal('odd'), t.Literal('even')]);

export const WeekTypeQuerySchema = t.Object({
  weekType: t.Optional(WeekTypeSchema),
});

export const MealSchema = t.Object({
  breakfast: t.Optional(t.Array(t.String())),
  lunch: t.Optional(t.Array(t.String())),
  snacks: t.Optional(t.Array(t.String())),
  dinner: t.Optional(t.Array(t.String())),
});

export const MessMenuItemSchema = t.Object({
  id: t.Number(),
  weekType: WeekTypeSchema,
  day: t.String(),
  meals: MealSchema,
});

export const MessTodaySchema = t.Object({
  date: t.String(),
  calculatedWeek: WeekTypeSchema,
  day: t.String(),
  meals: MealSchema,
});
