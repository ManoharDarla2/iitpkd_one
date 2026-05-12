import { Elysia, t } from 'elysia';

import { ErrorEnvelope, SuccessEnvelope, toIso } from '../../common/http';
import { authPlugin } from '../auth/auth-plugin';
import {
  ColabCreateFormSchema,
  ColabDetailSchema,
  ColabItemSchema,
  ColabListQuerySchema,
  ColabRequestCreateSchema,
  ColabRequestDecisionSchema,
  ColabRequestSchema,
  ColabUpdateFormSchema,
} from './model';
import { colabService } from './service';
import { imageService } from '../../services/image.service';

const ColabIdParamsSchema = t.Object({
  id: t.String(),
});

export const colabController = new Elysia({ prefix: '/colabs' })
  .use(authPlugin)
  .get('/', async ({ query }) => {
    const data = await colabService.list({
      type: query.type,
      isActive: query.isActive,
      createdBy: query.createdBy,
    });

    return SuccessEnvelope(
      data.map((item) => ({
        ...item,
        startDate: toIso(item.startDate) ?? null,
        endDate: toIso(item.endDate) ?? null,
        createdAt: toIso(item.createdAt) ?? '',
        updatedAt: toIso(item.updatedAt) ?? '',
      })),
      'Colabs retrieved successfully',
    );
  }, {
    query: ColabListQuerySchema,
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: t.Array(ColabItemSchema),
      }),
    },
    detail: {
      summary: 'List colabs',
      tags: ['Colab'],
    },
  })
  .get('/:id', async ({ params, status: setStatus }) => {
    const data = await colabService.getById(params.id);

    if (!data) {
      return setStatus(404, ErrorEnvelope('Colab not found'));
    }

    return SuccessEnvelope({
      ...data,
      startDate: toIso(data.startDate) ?? null,
      endDate: toIso(data.endDate) ?? null,
      createdAt: toIso(data.createdAt) ?? '',
      updatedAt: toIso(data.updatedAt) ?? '',
    }, 'Colab retrieved successfully');
  }, {
    params: ColabIdParamsSchema,
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: ColabDetailSchema,
      }),
      404: t.Object({
        success: t.Literal(false),
        message: t.String(),
      }),
    },
    detail: {
      summary: 'Get colab detail',
      tags: ['Colab'],
    },
  })
  .post('/', async ({ body, user }) => {
    let imageUrl: string | null = null;

    if (body.image) {
      const arrayBuffer = await body.image.arrayBuffer();
      const buffer = Buffer.from(arrayBuffer);
      imageUrl = await imageService.optimizeAndUpload(buffer);
    }

    const data = await colabService.create(user.id, {
      title: body.title,
      description: body.description,
      type: body.type,
      requirements: body.requirements,
      maxMembers: body.maxMembers ? parseInt(body.maxMembers) : undefined,
      startDate: body.startDate,
      endDate: body.endDate,
      isActive: body.isActive ? body.isActive === 'true' : undefined,
    }, imageUrl);

    return SuccessEnvelope({
      ...data,
      startDate: toIso(data.startDate) ?? null,
      endDate: toIso(data.endDate) ?? null,
      createdAt: toIso(data.createdAt) ?? '',
      updatedAt: toIso(data.updatedAt) ?? '',
      joinedCount: 0,
    }, 'Colab created successfully');
  }, {
    auth: true,
    body: ColabCreateFormSchema,
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: ColabItemSchema,
      }),
    },
    detail: {
      summary: 'Create colab with image upload',
      tags: ['Colab'],
    },
  })
  .patch('/:id', async ({ params, body, user, status: setStatus }) => {
    let imageUrl: string | null | undefined = undefined;

    if (body.image) {
      const arrayBuffer = await body.image.arrayBuffer();
      const buffer = Buffer.from(arrayBuffer);
      imageUrl = await imageService.optimizeAndUpload(buffer);
    }

    const data = await colabService.update(params.id, user.id, {
      title: body.title,
      description: body.description,
      type: body.type,
      requirements: body.requirements,
      maxMembers: body.maxMembers ? parseInt(body.maxMembers) : undefined,
      startDate: body.startDate,
      endDate: body.endDate,
      isActive: body.isActive ? body.isActive === 'true' : undefined,
    }, imageUrl);

    if (!data) {
      return setStatus(404, ErrorEnvelope('Colab not found'));
    }

    return SuccessEnvelope({
      ...data,
      startDate: toIso(data.startDate) ?? null,
      endDate: toIso(data.endDate) ?? null,
      createdAt: toIso(data.createdAt) ?? '',
      updatedAt: toIso(data.updatedAt) ?? '',
      joinedCount: 0,
    }, 'Colab updated successfully');
  }, {
    auth: true,
    params: ColabIdParamsSchema,
    body: ColabUpdateFormSchema,
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: ColabItemSchema,
      }),
      404: t.Object({
        success: t.Literal(false),
        message: t.String(),
      }),
    },
    detail: {
      summary: 'Update colab with image upload',
      tags: ['Colab'],
    },
  })
  .delete('/:id', async ({ params, user, status: setStatus }) => {
    const data = await colabService.remove(params.id, user.id);

    if (!data) {
      return setStatus(404, ErrorEnvelope('Colab not found'));
    }

    return SuccessEnvelope(data, 'Colab deleted successfully');
  }, {
    auth: true,
    params: ColabIdParamsSchema,
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: t.Object({ id: t.String() }),
      }),
      404: t.Object({
        success: t.Literal(false),
        message: t.String(),
      }),
    },
    detail: {
      summary: 'Delete colab',
      tags: ['Colab'],
    },
  })
  .post('/requests/join', async ({ body, user, status: setStatus }) => {
    const data = await colabService.createJoinRequest(user.id, body);

    if (!data) {
      return setStatus(404, ErrorEnvelope('Colab not found'));
    }

    return SuccessEnvelope(data, 'Join request created');
  }, {
    auth: true,
    body: ColabRequestCreateSchema,
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: ColabRequestSchema,
      }),
      404: t.Object({
        success: t.Literal(false),
        message: t.String(),
      }),
    },
    detail: {
      summary: 'Create join request',
      tags: ['Colab'],
    },
  })
  .post('/requests/invite', async ({ body, user, status: setStatus }) => {
    const data = await colabService.createInviteRequest(user.id, body);

    if (!data) {
      return setStatus(400, ErrorEnvelope('Invalid invite request'));
    }

    return SuccessEnvelope(data, 'Invite request created');
  }, {
    auth: true,
    body: ColabRequestCreateSchema,
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: ColabRequestSchema,
      }),
      400: t.Object({
        success: t.Literal(false),
        message: t.String(),
      }),
    },
    detail: {
      summary: 'Create invite request',
      tags: ['Colab'],
    },
  })
  .get('/requests', async ({ user }) => {
    const data = await colabService.listRequests(user.id);

    return SuccessEnvelope(data, 'Requests retrieved successfully');
  }, {
    auth: true,
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: t.Array(ColabRequestSchema),
      }),
    },
    detail: {
      summary: 'List incoming requests',
      tags: ['Colab'],
    },
  })
  .post('/requests/accept', async ({ body, user, status: setStatus }) => {
    const data = await colabService.acceptRequest(user.id, body.requestId);

    if (!data) {
      return setStatus(404, ErrorEnvelope('Request not found'));
    }

    return SuccessEnvelope(data, 'Request accepted');
  }, {
    auth: true,
    body: ColabRequestDecisionSchema,
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: ColabRequestSchema,
      }),
      404: t.Object({
        success: t.Literal(false),
        message: t.String(),
      }),
    },
    detail: {
      summary: 'Accept request',
      tags: ['Colab'],
    },
  })
  .post('/requests/reject', async ({ body, user, status: setStatus }) => {
    const data = await colabService.rejectRequest(user.id, body.requestId);

    if (!data) {
      return setStatus(404, ErrorEnvelope('Request not found'));
    }

    return SuccessEnvelope(data, 'Request rejected');
  }, {
    auth: true,
    body: ColabRequestDecisionSchema,
    response: {
      200: t.Object({
        success: t.Literal(true),
        message: t.String(),
        data: ColabRequestSchema,
      }),
      404: t.Object({
        success: t.Literal(false),
        message: t.String(),
      }),
    },
    detail: {
      summary: 'Reject request',
      tags: ['Colab'],
    },
  });
