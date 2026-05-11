import { t } from 'elysia';

export const WeekTypeSchema = t.Union([t.Literal('odd'), t.Literal('even')]);

export const SetWeekTypeBodySchema = t.Object({
  weekType: WeekTypeSchema,
});

export const WeekConfigResponseSchema = t.Object({
  referenceDate: t.String(),
  weekType: WeekTypeSchema,
});
