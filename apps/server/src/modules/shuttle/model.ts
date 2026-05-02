import { t } from 'elysia';

export const ShuttleQuerySchema = t.Object({
  day: t.Optional(t.String()),
  from: t.Optional(t.String()),
  to: t.Optional(t.String()),
});

export const ShuttleItemSchema = t.Object({
  id: t.Number(),
  from: t.String(),
  to: t.String(),
  time: t.String(),
  via: t.Array(t.String()),
  days: t.Array(t.String()),
  isOutsideTrip: t.Boolean(),
  isMultipleBuses: t.Boolean(),
});
