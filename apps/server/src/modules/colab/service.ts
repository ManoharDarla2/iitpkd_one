import { and, count, desc, eq, sql } from 'drizzle-orm';
import { randomUUID } from 'crypto';

import { neonDb as db } from '../../db';
import {
  colab,
  colabMember,
  colabRequest,
  colabRequestStatusEnum,
  colabRequestTypeEnum,
} from '../../db/neon/schema';

type ColabCreateInput = {
  title: string;
  description: string;
  type: 'project' | 'job';
  requirements?: string;
  maxMembers?: number;
  startDate?: string;
  endDate?: string;
  isActive?: boolean;
};

type ColabUpdateInput = Partial<ColabCreateInput>;

type ColabListFilters = {
  type?: 'project' | 'job';
  isActive?: boolean;
  createdBy?: string;
};

type ColabRequestCreateInput = {
  colabId: string;
  recipientId?: string;
  message?: string;
  expiresAt?: string;
};

export class ColabService {
  async list(filters: ColabListFilters) {
    const joinedCount = db
      .select({
        colabId: colabMember.colabId,
        joinedCount: count(colabMember.userId).as('joined_count'),
      })
      .from(colabMember)
      .groupBy(colabMember.colabId)
      .as('joined_count');

    return db
      .select({
        id: colab.id,
        imageUrl: colab.imageUrl,
        title: colab.title,
        description: colab.description,
        type: colab.type,
        requirements: colab.requirements,
        maxMembers: colab.maxMembers,
        startDate: colab.startDate,
        endDate: colab.endDate,
        isActive: colab.isActive,
        createdBy: colab.createdBy,
        createdAt: colab.createdAt,
        updatedAt: colab.updatedAt,
        joinedCount: sql<number>`coalesce(${joinedCount.joinedCount}, 0)`
          .mapWith(Number)
          .as('joined_count'),
      })
      .from(colab)
      .leftJoin(joinedCount, eq(joinedCount.colabId, colab.id))
      .where(
        and(
          filters.type ? eq(colab.type, filters.type) : undefined,
          filters.isActive !== undefined ? eq(colab.isActive, filters.isActive) : undefined,
          filters.createdBy ? eq(colab.createdBy, filters.createdBy) : undefined,
        ),
      )
      .orderBy(desc(colab.createdAt));
  }

  async getById(id: string) {
    const joinedCount = db
      .select({
        colabId: colabMember.colabId,
        joinedCount: count(colabMember.userId).as('joined_count'),
      })
      .from(colabMember)
      .groupBy(colabMember.colabId)
      .as('joined_count');

    const rows = await db
      .select({
        id: colab.id,
        imageUrl: colab.imageUrl,
        title: colab.title,
        description: colab.description,
        type: colab.type,
        requirements: colab.requirements,
        maxMembers: colab.maxMembers,
        startDate: colab.startDate,
        endDate: colab.endDate,
        isActive: colab.isActive,
        createdBy: colab.createdBy,
        createdAt: colab.createdAt,
        updatedAt: colab.updatedAt,
        joinedCount: sql<number>`coalesce(${joinedCount.joinedCount}, 0)`
          .mapWith(Number)
          .as('joined_count'),
      })
      .from(colab)
      .leftJoin(joinedCount, eq(joinedCount.colabId, colab.id))
      .where(eq(colab.id, id))
      .limit(1);

    return rows[0] ?? null;
  }

  async create(userId: string, payload: ColabCreateInput, imageUrl?: string | null) {
    const id = randomUUID();
    const [row] = await db
      .insert(colab)
      .values({
        id,
        imageUrl: imageUrl ?? null,
        title: payload.title,
        description: payload.description,
        type: payload.type,
        requirements: payload.requirements ?? '',
        maxMembers: payload.maxMembers ?? null,
        startDate: payload.startDate ? new Date(payload.startDate) : null,
        endDate: payload.endDate ? new Date(payload.endDate) : null,
        isActive: payload.isActive ?? true,
        createdBy: userId,
      })
      .returning();

    return row;
  }

  async update(id: string, userId: string, payload: ColabUpdateInput, imageUrl?: string | null) {
    const [row] = await db
      .update(colab)
      .set({
        title: payload.title,
        description: payload.description,
        type: payload.type,
        requirements: payload.requirements,
        maxMembers: payload.maxMembers,
        startDate: payload.startDate ? new Date(payload.startDate) : undefined,
        endDate: payload.endDate ? new Date(payload.endDate) : undefined,
        isActive: payload.isActive,
        imageUrl: imageUrl ?? undefined,
      })
      .where(and(eq(colab.id, id), eq(colab.createdBy, userId)))
      .returning();

    return row ?? null;
  }

  async remove(id: string, userId: string) {
    const rows = await db
      .delete(colab)
      .where(and(eq(colab.id, id), eq(colab.createdBy, userId)))
      .returning({ id: colab.id });

    return rows[0] ?? null;
  }

  async createJoinRequest(userId: string, payload: ColabRequestCreateInput) {
    const colabRow = await db
      .select({
        id: colab.id,
        createdBy: colab.createdBy,
      })
      .from(colab)
      .where(eq(colab.id, payload.colabId))
      .limit(1);

    const target = colabRow[0];

    if (!target) {
      return null;
    }

    const id = randomUUID();
    const [row] = await db
      .insert(colabRequest)
      .values({
        id,
        colabId: payload.colabId,
        requesterId: userId,
        recipientId: target.createdBy,
        type: colabRequestTypeEnum.enumValues[0],
        status: colabRequestStatusEnum.enumValues[0],
        message: payload.message ?? '',
        expiresAt: payload.expiresAt ? new Date(payload.expiresAt) : null,
      })
      .returning();

    return row;
  }

  async createInviteRequest(userId: string, payload: ColabRequestCreateInput) {
    if (!payload.recipientId) {
      return null;
    }

    const id = randomUUID();
    const [row] = await db
      .insert(colabRequest)
      .values({
        id,
        colabId: payload.colabId,
        requesterId: userId,
        recipientId: payload.recipientId,
        type: colabRequestTypeEnum.enumValues[1],
        status: colabRequestStatusEnum.enumValues[0],
        message: payload.message ?? '',
        expiresAt: payload.expiresAt ? new Date(payload.expiresAt) : null,
      })
      .returning();

    return row;
  }

  async listRequests(userId: string) {
    return db
      .select()
      .from(colabRequest)
      .where(
        and(
          eq(colabRequest.recipientId, userId),
          eq(colabRequest.status, colabRequestStatusEnum.enumValues[0]),
        ),
      )
      .orderBy(desc(colabRequest.createdAt));
  }

  async acceptRequest(userId: string, requestId: string) {
    const [requestRow] = await db
      .select()
      .from(colabRequest)
      .where(and(eq(colabRequest.id, requestId), eq(colabRequest.recipientId, userId)))
      .limit(1);

    if (!requestRow || requestRow.status !== colabRequestStatusEnum.enumValues[0]) {
      return null;
    }

    await db.transaction(async (tx) => {
      await tx
        .update(colabRequest)
        .set({ status: colabRequestStatusEnum.enumValues[1] })
        .where(eq(colabRequest.id, requestId));

      await tx
        .insert(colabMember)
        .values({
          colabId: requestRow.colabId,
          userId: requestRow.type === colabRequestTypeEnum.enumValues[0]
            ? requestRow.requesterId
            : requestRow.recipientId,
        })
        .onConflictDoNothing();
    });

    return requestRow;
  }

  async rejectRequest(userId: string, requestId: string) {
    const rows = await db
      .update(colabRequest)
      .set({ status: colabRequestStatusEnum.enumValues[2] })
      .where(and(eq(colabRequest.id, requestId), eq(colabRequest.recipientId, userId)))
      .returning();

    return rows[0] ?? null;
  }
}

export const colabService = new ColabService();
