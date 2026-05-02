import { Elysia, t } from 'elysia';

import { SuccessEnvelope } from '../../common/http';
import { CompetitionItemSchema } from './model';
import { competitionService } from './service';

export const competitionController = new Elysia({ prefix: '/competitions' })
  .get('/', async () => {
    const data = await competitionService.getCompetitions();

    return SuccessEnvelope(data, 'Competitions retrieved successfully');
  }, {
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: t.Array(CompetitionItemSchema),
      }),
    },
    detail: {
      summary: 'Get competitions list',
      tags: ['Competitions'],
    },
  });
