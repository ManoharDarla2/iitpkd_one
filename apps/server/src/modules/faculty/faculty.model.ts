import { t } from 'elysia';

export const FacultyListQuerySchema = t.Object({
  department: t.Optional(t.String()),
});

export const FacultySlugParamsSchema = t.Object({
  slug: t.String({ minLength: 1 }),
});

export const FacultyListItemSchema = t.Object({
  id: t.Number(),
  slug: t.String(),
  name: t.String(),
  designation: t.String(),
  department: t.String(),
  imageUrl: t.String(),
});

export const FacultyDetailSchema = t.Object({
  id: t.Number(),
  slug: t.String(),
  name: t.String(),
  imageUrl: t.String(),
  department: t.String(),
  designation: t.String(),
  email: t.String(),
  biosketch: t.String(),
  teaching: t.String(),
  office: t.String(),
  publications: t.String(),
  additionalInformation: t.String(),
});
