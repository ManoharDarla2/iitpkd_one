import { Elysia, t } from 'elysia';

import { MetaSchema, SuccessEnvelope, toIso } from '../../common/http';
import { ShuttleItemSchema, ShuttleQuerySchema } from './shuttle.model';
import { shuttleService } from './shuttle.service';

export const shuttleController = new Elysia({ prefix: '/shuttles' })
  .get('/', async ({ query }) => {
    const data = await shuttleService.getShuttles({
      day: query.day,
      from: query.from,
      to: query.to,
    });

    return SuccessEnvelope(data, 'Shuttles retrieved successfully');
  }, {
    query: ShuttleQuerySchema,
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: t.Array(ShuttleItemSchema),
      }),
    },
    detail: {
      summary: 'Get shuttle schedules',
      tags: ['Shuttles'],
    },
  })
  .get('/metadata', async () => {
    const data = await shuttleService.getShuttleMetadata();

    return SuccessEnvelope({
      updatedAt: toIso(data.updatedAt) ?? '',
      version: data.version,
    }, 'Shuttle metadata retrieved');
  }, {
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: MetaSchema,
      }),
    },
    detail: {
      summary: 'Get shuttle metadata',
      tags: ['Shuttles'],
    },
  });
