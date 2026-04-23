import { t } from 'elysia';

export const CompetitionItemSchema = t.Object({
  websiteUrl: t.String(),
  title: t.String(),
  applyLink: t.String(),
  deadline: t.String(),
});
