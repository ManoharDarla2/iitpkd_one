import { Elysia, t } from 'elysia';

import { ErrorEnvelope, MetaSchema, SuccessEnvelope, toIso } from '../../common/http';
import {
  FacultyDetailSchema,
  FacultyListItemSchema,
  FacultyListQuerySchema,
  FacultySlugParamsSchema,
} from './faculty.model';
import { facultyService } from './faculty.service';

export const facultyController = new Elysia({ prefix: '/faculty' })
  .get('/', async ({ query }) => {
    const data = await facultyService.getFacultyList({
      department: query.department,
    });

    return SuccessEnvelope(data, 'Faculty list retrieved successfully');
  }, {
    query: FacultyListQuerySchema,
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: t.Array(FacultyListItemSchema),
      }),
    },
    detail: {
      summary: 'Get faculty list',
      tags: ['Faculty'],
    },
  })
  .get('/metadata', async () => {
    const data = await facultyService.getFacultyMetadata();

    return SuccessEnvelope({
      updatedAt: toIso(data.updatedAt) ?? '',
      version: data.version,
    }, 'Faculty metadata retrieved');
  }, {
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: MetaSchema,
      }),
    },
    detail: {
      summary: 'Get faculty metadata',
      tags: ['Faculty'],
    },
  })
  .get('/:slug', async ({ params, status }) => {
    const data = await facultyService.getFacultyBySlug(params.slug);

    if (!data) {
      return status(404, ErrorEnvelope('Faculty profile not found'));
    }

    return SuccessEnvelope(data, 'Faculty profile retrieved successfully');
  }, {
    params: FacultySlugParamsSchema,
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: FacultyDetailSchema,
      }),
      404: t.Object({
        success: t.Literal(false),
        message: t.String(),
      }),
    },
    detail: {
      summary: 'Get faculty profile by slug',
      tags: ['Faculty'],
    },
  });
