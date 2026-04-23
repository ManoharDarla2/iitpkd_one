import { Elysia, t } from 'elysia';

import { SuccessEnvelope } from '../../common/http';
import {
  SearchQuerySchema,
  SearchResponseDataSchema,
  SearchSuggestionsQuerySchema,
} from './search.model';
import { searchService } from './search.service';

export const searchController = new Elysia({ prefix: '/search' })
  .get('/', async ({ query }) => {
    const q = (query.q ?? '').trim();
    const limit = query.limit ?? 20;
    const data = await searchService.search({
      q,
      category: query.category,
      limit,
    });

    const message = q ? `Search results for "${q}"` : 'Empty query';

    return SuccessEnvelope(data, message);
  }, {
    query: SearchQuerySchema,
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: SearchResponseDataSchema,
      }),
    },
    detail: {
      summary: 'Search across faculty, equipment and schedules',
      tags: ['Search'],
    },
  })
  .get('/suggestions', async ({ query }) => {
    const q = (query.q ?? '').trim();
    const limit = query.limit ?? 8;
    const data = await searchService.suggestions(q, limit);

    const message = q ? `Suggestions for "${q}"` : 'Popular suggestions';

    return SuccessEnvelope(data, message);
  }, {
    query: SearchSuggestionsQuerySchema,
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: t.Array(t.String()),
      }),
    },
    detail: {
      summary: 'Search query suggestions',
      tags: ['Search'],
    },
  });
