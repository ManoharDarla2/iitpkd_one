import { Elysia, t } from 'elysia';

import { ErrorEnvelope, SuccessEnvelope } from '../../common/http';
import { SetWeekTypeBodySchema, WeekConfigResponseSchema } from './model';
import { developerService } from './service';
import { messService } from '../mess/service';

export const developerController = new Elysia({ prefix: '/developer' })
  .onBeforeHandle(({ request: { headers }, status }) => {
    const apiKey = headers.get('x-api-key');
    const expectedApiKey = process.env.API_KEY;

    if (!expectedApiKey) {
      return status(500, ErrorEnvelope('API key not configured on server'));
    }

    if (apiKey !== expectedApiKey) {
      return status(401, ErrorEnvelope('Invalid API key'));
    }
  })
  .post('/mess/week-type', async ({ body }) => {
    const result = await developerService.setWeekType(body.weekType);
    messService.invalidateWeekConfigCache();
    return SuccessEnvelope(
      { referenceDate: result.referenceDate, weekType: result.weekType as 'odd' | 'even' },
      'Mess week type configuration saved',
    );
  }, {
    body: SetWeekTypeBodySchema,
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: WeekConfigResponseSchema,
      }),
    },
    detail: {
      summary: 'Set mess week type reference',
      description:
        'Sets the current date as the reference point for mess week type calculation. The provided week type (odd/even) will be assigned to the current week, and all future weeks will alternate from this reference.',
      tags: ['Developer'],
    },
  });
