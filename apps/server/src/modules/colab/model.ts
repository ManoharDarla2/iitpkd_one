import { t } from 'elysia';

export const ColabTypeSchema = t.Union([t.Literal('project'), t.Literal('job')]);
export const ColabRequestTypeSchema = t.Union([t.Literal('join'), t.Literal('invite')]);
export const ColabRequestStatusSchema = t.Union([
  t.Literal('pending'),
  t.Literal('accepted'),
  t.Literal('rejected'),
  t.Literal('cancelled'),
  t.Literal('expired'),
]);

export const ColabCreateSchema = t.Object({
  title: t.String({ minLength: 3, maxLength: 120 }),
  description: t.String({ minLength: 10, maxLength: 2000 }),
  type: ColabTypeSchema,
  requirements: t.Optional(t.String({ maxLength: 2000 })),
  maxMembers: t.Optional(t.Integer({ minimum: 1, maximum: 1000 })),
  startDate: t.Optional(t.String()),
  endDate: t.Optional(t.String()),
  isActive: t.Optional(t.Boolean()),
});

export const ColabUpdateSchema = t.Partial(ColabCreateSchema);

export const ColabListQuerySchema = t.Object({
  type: t.Optional(ColabTypeSchema),
  isActive: t.Optional(t.Boolean()),
  createdBy: t.Optional(t.String()),
});

export const ColabItemSchema = t.Object({
  id: t.String(),
  imageUrl: t.Union([t.String(), t.Null()]),
  title: t.String(),
  description: t.String(),
  type: ColabTypeSchema,
  requirements: t.String(),
  maxMembers: t.Union([t.Integer(), t.Null()]),
  startDate: t.Union([t.String(), t.Null()]),
  endDate: t.Union([t.String(), t.Null()]),
  isActive: t.Boolean(),
  createdBy: t.String(),
  createdAt: t.String(),
  updatedAt: t.String(),
  joinedCount: t.Integer(),
});

export const ColabDetailSchema = ColabItemSchema;

export const ColabMemberSchema = t.Object({
  colabId: t.String(),
  userId: t.String(),
  joinedAt: t.String(),
});

export const ColabRequestCreateSchema = t.Object({
  colabId: t.String(),
  recipientId: t.Optional(t.String()),
  message: t.Optional(t.String({ maxLength: 1000 })),
  expiresAt: t.Optional(t.String()),
});

export const ColabRequestDecisionSchema = t.Object({
  requestId: t.String(),
});

export const ColabRequestSchema = t.Object({
  id: t.String(),
  colabId: t.String(),
  requesterId: t.String(),
  recipientId: t.String(),
  type: ColabRequestTypeSchema,
  status: ColabRequestStatusSchema,
  message: t.String(),
  expiresAt: t.Union([t.String(), t.Null()]),
  createdAt: t.String(),
  updatedAt: t.String(),
});
