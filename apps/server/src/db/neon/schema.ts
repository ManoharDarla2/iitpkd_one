import { relations, sql } from "drizzle-orm";
import {
  boolean,
  index,
  integer,
  pgEnum,
  pgTable,
  primaryKey,
  text,
  timestamp,
} from "drizzle-orm/pg-core";

export const user = pgTable("user", {
  id: text("id").primaryKey(),
  name: text("name").notNull(),
  email: text("email").notNull().unique(),
  emailVerified: boolean("email_verified").default(false).notNull(),
  image: text("image"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at")
    .defaultNow()
    .$onUpdate(() => /* @__PURE__ */ new Date())
    .notNull(),
});

export const colabTypeEnum = pgEnum("colab_type", ["project", "job"]);
export const colabRequestTypeEnum = pgEnum("colab_request_type", ["join", "invite"]);
export const colabRequestStatusEnum = pgEnum("colab_request_status", [
  "pending",
  "accepted",
  "rejected",
  "cancelled",
  "expired",
]);

export const colab = pgTable(
  "colab",
  {
    id: text("id").primaryKey(),
    imageUrl: text("image_url"),
    title: text("title").notNull(),
    description: text("description").notNull(),
    type: colabTypeEnum("type").notNull(),
    requirements: text("requirements").notNull().default(""),
    maxMembers: integer("max_members"),
    startDate: timestamp("start_date"),
    endDate: timestamp("end_date"),
    isActive: boolean("is_active").notNull().default(true),
    createdBy: text("created_by")
      .notNull()
      .references(() => user.id, { onDelete: "cascade" }),
    createdAt: timestamp("created_at").defaultNow().notNull(),
    updatedAt: timestamp("updated_at")
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    index("colab_created_by_idx").on(table.createdBy),
    index("colab_type_idx").on(table.type),
    index("colab_active_idx").on(table.isActive),
  ],
);

export const colabMember = pgTable(
  "colab_member",
  {
    colabId: text("colab_id")
      .notNull()
      .references(() => colab.id, { onDelete: "cascade" }),
    userId: text("user_id")
      .notNull()
      .references(() => user.id, { onDelete: "cascade" }),
    joinedAt: timestamp("joined_at").defaultNow().notNull(),
  },
  (table) => [
    primaryKey({ columns: [table.colabId, table.userId] }),
    index("colab_member_colab_idx").on(table.colabId),
    index("colab_member_user_idx").on(table.userId),
  ],
);

export const colabRequest = pgTable(
  "colab_request",
  {
    id: text("id").primaryKey(),
    colabId: text("colab_id")
      .notNull()
      .references(() => colab.id, { onDelete: "cascade" }),
    requesterId: text("requester_id")
      .notNull()
      .references(() => user.id, { onDelete: "cascade" }),
    recipientId: text("recipient_id")
      .notNull()
      .references(() => user.id, { onDelete: "cascade" }),
    type: colabRequestTypeEnum("type").notNull(),
    status: colabRequestStatusEnum("status").notNull().default("pending"),
    message: text("message").notNull().default(""),
    expiresAt: timestamp("expires_at"),
    createdAt: timestamp("created_at").defaultNow().notNull(),
    updatedAt: timestamp("updated_at")
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    index("colab_request_colab_idx").on(table.colabId),
    index("colab_request_requester_idx").on(table.requesterId),
    index("colab_request_recipient_idx").on(table.recipientId),
    index("colab_request_status_idx").on(table.status),
  ],
);

export const session = pgTable(
  "session",
  {
    id: text("id").primaryKey(),
    expiresAt: timestamp("expires_at").notNull(),
    token: text("token").notNull().unique(),
    createdAt: timestamp("created_at").defaultNow().notNull(),
    updatedAt: timestamp("updated_at")
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
    ipAddress: text("ip_address"),
    userAgent: text("user_agent"),
    userId: text("user_id")
      .notNull()
      .references(() => user.id, { onDelete: "cascade" }),
  },
  (table) => [index("session_userId_idx").on(table.userId)],
);

export const account = pgTable(
  "account",
  {
    id: text("id").primaryKey(),
    accountId: text("account_id").notNull(),
    providerId: text("provider_id").notNull(),
    userId: text("user_id")
      .notNull()
      .references(() => user.id, { onDelete: "cascade" }),
    accessToken: text("access_token"),
    refreshToken: text("refresh_token"),
    idToken: text("id_token"),
    accessTokenExpiresAt: timestamp("access_token_expires_at"),
    refreshTokenExpiresAt: timestamp("refresh_token_expires_at"),
    scope: text("scope"),
    password: text("password"),
    createdAt: timestamp("created_at").defaultNow().notNull(),
    updatedAt: timestamp("updated_at")
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [index("account_userId_idx").on(table.userId)],
);

export const verification = pgTable(
  "verification",
  {
    id: text("id").primaryKey(),
    identifier: text("identifier").notNull(),
    value: text("value").notNull(),
    expiresAt: timestamp("expires_at").notNull(),
    createdAt: timestamp("created_at").defaultNow().notNull(),
    updatedAt: timestamp("updated_at")
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [index("verification_identifier_idx").on(table.identifier)],
);

export const userRelations = relations(user, ({ many }) => ({
  sessions: many(session),
  accounts: many(account),
  colabs: many(colab),
  colabMemberships: many(colabMember),
  colabRequestsSent: many(colabRequest, { relationName: "colabRequestsSent" }),
  colabRequestsReceived: many(colabRequest, { relationName: "colabRequestsReceived" }),
}));

export const sessionRelations = relations(session, ({ one }) => ({
  user: one(user, {
    fields: [session.userId],
    references: [user.id],
  }),
}));

export const accountRelations = relations(account, ({ one }) => ({
  user: one(user, {
    fields: [account.userId],
    references: [user.id],
  }),
}));

export const colabRelations = relations(colab, ({ one, many }) => ({
  creator: one(user, {
    fields: [colab.createdBy],
    references: [user.id],
  }),
  members: many(colabMember),
  requests: many(colabRequest),
}));

export const colabMemberRelations = relations(colabMember, ({ one }) => ({
  colab: one(colab, {
    fields: [colabMember.colabId],
    references: [colab.id],
  }),
  user: one(user, {
    fields: [colabMember.userId],
    references: [user.id],
  }),
}));

export const colabRequestRelations = relations(colabRequest, ({ one }) => ({
  colab: one(colab, {
    fields: [colabRequest.colabId],
    references: [colab.id],
  }),
  requester: one(user, {
    fields: [colabRequest.requesterId],
    references: [user.id],
    relationName: "colabRequestsSent",
  }),
  recipient: one(user, {
    fields: [colabRequest.recipientId],
    references: [user.id],
    relationName: "colabRequestsReceived",
  }),
}));
