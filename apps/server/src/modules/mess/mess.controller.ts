import { Elysia, t } from 'elysia';

import { ErrorEnvelope, MetaSchema, SuccessEnvelope, toIso } from '../../common/http';
import {
  MessMenuItemSchema,
  MessTodaySchema,
  WeekTypeQuerySchema,
  WeekTypeSchema,
} from './mess.model';
import { messService } from './mess.service';

export const messController = new Elysia({ prefix: '/mess' })
  .get('/menu', async ({ query }) => {
    const data = await messService.getMenu({ weekType: query.weekType });
    const normalized = data.map((item) => ({
      id: item.id,
      weekType: messService.mapMenuWeekType(item.weekType),
      day: item.day,
      meals: item.meals,
    }));

    return SuccessEnvelope(normalized, 'Mess menu retrieved successfully');
  }, {
    query: WeekTypeQuerySchema,
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: t.Array(MessMenuItemSchema),
      }),
    },
    detail: {
      summary: 'Get mess menu',
      tags: ['Mess'],
    },
  })
  .get('/menu/today', async ({ status }) => {
    const data = await messService.getTodayMenu();

    if (!Object.keys(data.meals).length) {
      return status(404, ErrorEnvelope('Mess menu for today was not found'));
    }

    return SuccessEnvelope(data, "Today's menu retrieved");
  }, {
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: MessTodaySchema,
      }),
      404: t.Object({
        success: t.Literal(false),
        message: t.String(),
      }),
    },
    detail: {
      summary: 'Get today mess menu',
      tags: ['Mess'],
    },
  })
  .get('/metadata', async () => {
    const data = await messService.getMessMetadata();

    return SuccessEnvelope({
      updatedAt: toIso(data.updatedAt) ?? '',
      version: data.version,
    }, 'Mess metadata retrieved');
  }, {
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: MetaSchema,
      }),
    },
    detail: {
      summary: 'Get mess metadata',
      tags: ['Mess'],
    },
  })
  .get('/week-types', () => {
    return SuccessEnvelope(['odd', 'even'], 'Available week types retrieved');
  }, {
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: t.Array(WeekTypeSchema),
      }),
    },
    detail: {
      summary: 'Get allowed week types',
      tags: ['Mess'],
    },
  });
