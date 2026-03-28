import { t } from 'elysia';

export const SearchCategorySchema = t.Union([
  t.Literal('equipment'),
  t.Literal('faculty'),
  t.Literal('schedule'),
]);

export const SearchQuerySchema = t.Object({
  q: t.Optional(t.String()),
  category: t.Optional(SearchCategorySchema),
  limit: t.Optional(t.Numeric({ minimum: 1, maximum: 100 })),
});

export const SearchSuggestionsQuerySchema = t.Object({
  q: t.Optional(t.String()),
  limit: t.Optional(t.Numeric({ minimum: 1, maximum: 20 })),
});

export const SearchItemSchema = t.Object({
  id: t.String(),
  category: SearchCategorySchema,
  title: t.String(),
  subtitle: t.String(),
  description: t.String(),
  imageUrl: t.String(),
  metadata: t.Record(t.String(), t.String()),
});

export const SearchResponseDataSchema = t.Object({
  query: t.String(),
  category: t.Union([SearchCategorySchema, t.Null()]),
  totalCount: t.Number(),
  results: t.Array(SearchItemSchema),
});
