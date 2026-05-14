import Elysia, { Elysia as Elysia$1, t } from "elysia";
import { cors } from "@elysiajs/cors";
import { openapi } from "@elysiajs/openapi";
import "dotenv/config";
import { betterAuth } from "better-auth";
import { bearer, openAPI } from "better-auth/plugins";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { drizzle } from "drizzle-orm/neon-http";
import { neon } from "@neondatabase/serverless";
import { and, count, desc, eq, like, or, relations, sql } from "drizzle-orm";
import { boolean, index, integer, pgEnum, pgTable, primaryKey, text, timestamp } from "drizzle-orm/pg-core";
import { randomUUID } from "crypto";
import { drizzle as drizzle$1 } from "drizzle-orm/libsql";
import { v2 } from "cloudinary";
import { metadata, resize, toWebp } from "imgkit";
import { integer as integer$1, sqliteTable, text as text$1, uniqueIndex } from "drizzle-orm/sqlite-core";
//#region \0rolldown/runtime.js
var __defProp = Object.defineProperty;
var __exportAll = (all, no_symbols) => {
	let target = {};
	for (var name in all) __defProp(target, name, {
		get: all[name],
		enumerable: true
	});
	if (!no_symbols) __defProp(target, Symbol.toStringTag, { value: "Module" });
	return target;
};
const db$1 = drizzle({ client: neon(process.env.NEON_DB_URL) });
//#endregion
//#region src/db/neon/schema.ts
var schema_exports = /* @__PURE__ */ __exportAll({
	account: () => account,
	accountRelations: () => accountRelations,
	colab: () => colab,
	colabMember: () => colabMember,
	colabMemberRelations: () => colabMemberRelations,
	colabRelations: () => colabRelations,
	colabRequest: () => colabRequest,
	colabRequestRelations: () => colabRequestRelations,
	colabRequestStatusEnum: () => colabRequestStatusEnum,
	colabRequestTypeEnum: () => colabRequestTypeEnum,
	colabTypeEnum: () => colabTypeEnum,
	session: () => session,
	sessionRelations: () => sessionRelations,
	user: () => user,
	userRelations: () => userRelations,
	verification: () => verification
});
const user = pgTable("user", {
	id: text("id").primaryKey(),
	name: text("name").notNull(),
	email: text("email").notNull().unique(),
	emailVerified: boolean("email_verified").default(false).notNull(),
	image: text("image"),
	createdAt: timestamp("created_at").defaultNow().notNull(),
	updatedAt: timestamp("updated_at").defaultNow().$onUpdate(() => /* @__PURE__ */ new Date()).notNull()
});
const colabTypeEnum = pgEnum("colab_type", ["project", "job"]);
const colabRequestTypeEnum = pgEnum("colab_request_type", ["join", "invite"]);
const colabRequestStatusEnum = pgEnum("colab_request_status", [
	"pending",
	"accepted",
	"rejected",
	"cancelled",
	"expired"
]);
const colab = pgTable("colab", {
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
	createdBy: text("created_by").notNull().references(() => user.id, { onDelete: "cascade" }),
	createdAt: timestamp("created_at").defaultNow().notNull(),
	updatedAt: timestamp("updated_at").defaultNow().$onUpdate(() => /* @__PURE__ */ new Date()).notNull()
}, (table) => [
	index("colab_created_by_idx").on(table.createdBy),
	index("colab_type_idx").on(table.type),
	index("colab_active_idx").on(table.isActive)
]);
const colabMember = pgTable("colab_member", {
	colabId: text("colab_id").notNull().references(() => colab.id, { onDelete: "cascade" }),
	userId: text("user_id").notNull().references(() => user.id, { onDelete: "cascade" }),
	joinedAt: timestamp("joined_at").defaultNow().notNull()
}, (table) => [
	primaryKey({ columns: [table.colabId, table.userId] }),
	index("colab_member_colab_idx").on(table.colabId),
	index("colab_member_user_idx").on(table.userId)
]);
const colabRequest = pgTable("colab_request", {
	id: text("id").primaryKey(),
	colabId: text("colab_id").notNull().references(() => colab.id, { onDelete: "cascade" }),
	requesterId: text("requester_id").notNull().references(() => user.id, { onDelete: "cascade" }),
	recipientId: text("recipient_id").notNull().references(() => user.id, { onDelete: "cascade" }),
	type: colabRequestTypeEnum("type").notNull(),
	status: colabRequestStatusEnum("status").notNull().default("pending"),
	message: text("message").notNull().default(""),
	expiresAt: timestamp("expires_at"),
	createdAt: timestamp("created_at").defaultNow().notNull(),
	updatedAt: timestamp("updated_at").defaultNow().$onUpdate(() => /* @__PURE__ */ new Date()).notNull()
}, (table) => [
	index("colab_request_colab_idx").on(table.colabId),
	index("colab_request_requester_idx").on(table.requesterId),
	index("colab_request_recipient_idx").on(table.recipientId),
	index("colab_request_status_idx").on(table.status)
]);
const session = pgTable("session", {
	id: text("id").primaryKey(),
	expiresAt: timestamp("expires_at").notNull(),
	token: text("token").notNull().unique(),
	createdAt: timestamp("created_at").defaultNow().notNull(),
	updatedAt: timestamp("updated_at").$onUpdate(() => /* @__PURE__ */ new Date()).notNull(),
	ipAddress: text("ip_address"),
	userAgent: text("user_agent"),
	userId: text("user_id").notNull().references(() => user.id, { onDelete: "cascade" })
}, (table) => [index("session_userId_idx").on(table.userId)]);
const account = pgTable("account", {
	id: text("id").primaryKey(),
	accountId: text("account_id").notNull(),
	providerId: text("provider_id").notNull(),
	userId: text("user_id").notNull().references(() => user.id, { onDelete: "cascade" }),
	accessToken: text("access_token"),
	refreshToken: text("refresh_token"),
	idToken: text("id_token"),
	accessTokenExpiresAt: timestamp("access_token_expires_at"),
	refreshTokenExpiresAt: timestamp("refresh_token_expires_at"),
	scope: text("scope"),
	password: text("password"),
	createdAt: timestamp("created_at").defaultNow().notNull(),
	updatedAt: timestamp("updated_at").$onUpdate(() => /* @__PURE__ */ new Date()).notNull()
}, (table) => [index("account_userId_idx").on(table.userId)]);
const verification = pgTable("verification", {
	id: text("id").primaryKey(),
	identifier: text("identifier").notNull(),
	value: text("value").notNull(),
	expiresAt: timestamp("expires_at").notNull(),
	createdAt: timestamp("created_at").defaultNow().notNull(),
	updatedAt: timestamp("updated_at").defaultNow().$onUpdate(() => /* @__PURE__ */ new Date()).notNull()
}, (table) => [index("verification_identifier_idx").on(table.identifier)]);
const userRelations = relations(user, ({ many }) => ({
	sessions: many(session),
	accounts: many(account),
	colabs: many(colab),
	colabMemberships: many(colabMember),
	colabRequestsSent: many(colabRequest, { relationName: "colabRequestsSent" }),
	colabRequestsReceived: many(colabRequest, { relationName: "colabRequestsReceived" })
}));
const sessionRelations = relations(session, ({ one }) => ({ user: one(user, {
	fields: [session.userId],
	references: [user.id]
}) }));
const accountRelations = relations(account, ({ one }) => ({ user: one(user, {
	fields: [account.userId],
	references: [user.id]
}) }));
const colabRelations = relations(colab, ({ one, many }) => ({
	creator: one(user, {
		fields: [colab.createdBy],
		references: [user.id]
	}),
	members: many(colabMember),
	requests: many(colabRequest)
}));
const colabMemberRelations = relations(colabMember, ({ one }) => ({
	colab: one(colab, {
		fields: [colabMember.colabId],
		references: [colab.id]
	}),
	user: one(user, {
		fields: [colabMember.userId],
		references: [user.id]
	})
}));
const colabRequestRelations = relations(colabRequest, ({ one }) => ({
	colab: one(colab, {
		fields: [colabRequest.colabId],
		references: [colab.id]
	}),
	requester: one(user, {
		fields: [colabRequest.requesterId],
		references: [user.id],
		relationName: "colabRequestsSent"
	}),
	recipient: one(user, {
		fields: [colabRequest.recipientId],
		references: [user.id],
		relationName: "colabRequestsReceived"
	})
}));
//#endregion
//#region src/modules/auth/auth.ts
const auth = betterAuth({
	database: drizzleAdapter(db$1, {
		provider: "pg",
		schema: schema_exports
	}),
	plugins: [openAPI(), bearer()],
	trustedOrigins: [...process.env.NODE_ENV === "development" ? ["http://localhost:3000"] : [], ...process.env.ALLOWED_ORIGINS?.split(",") ?? []],
	socialProviders: { google: {
		clientId: process.env.GOOGLE_CLIENT_ID,
		clientSecret: process.env.GOOGLE_CLIENT_SECRET
	} },
	session: {
		expiresIn: 3600 * 24 * 7,
		updateAge: 3600 * 24
	},
	baseURL: process.env.PUBLIC_APP_URL
});
//#endregion
//#region src/modules/auth/openapi.ts
let _schema;
const getSchema = async () => _schema ??= auth.api.generateOpenAPISchema();
const OpenAPI = {
	getPaths: (prefix = "/api/auth") => getSchema().then(({ paths }) => {
		const reference = Object.create(null);
		for (const path of Object.keys(paths)) {
			const key = prefix + path;
			reference[key] = paths[path];
			for (const method of Object.keys(paths[path])) {
				const operation = reference[key][method];
				operation.tags = ["Auth"];
			}
		}
		return reference;
	}),
	components: getSchema().then(({ components }) => components)
};
//#endregion
//#region src/plugins.ts
const cors$1 = new Elysia({ name: "cors" }).use(cors({
	origin: (request) => {
		const origin = request.headers.get("origin");
		if (!origin) return true;
		if (process.env.NODE_ENV !== "production") {
			if (origin.startsWith("exp://") || origin.startsWith("http://localhost") || origin.startsWith("http://127.0.0.1") || /^http:\/\/192\.168\.\d+\.\d+/.test(origin) || /^http:\/\/10\.\d+\.\d+\.\d+/.test(origin)) return true;
		}
		if (process.env.ALLOWED_ORIGINS) {
			if (process.env.ALLOWED_ORIGINS.split(",").map((o) => o.trim()).includes(origin)) return true;
		}
		return false;
	},
	methods: [
		"GET",
		"POST",
		"PUT",
		"PATCH",
		"DELETE",
		"OPTIONS"
	],
	credentials: true,
	allowedHeaders: ["Content-Type", "Authorization"]
}));
new Elysia({ name: "openapi" }).use(openapi({
	path: "/docs",
	specPath: "/docs/json",
	provider: "scalar",
	documentation: {
		info: {
			title: "CSquare Connect API",
			version: "1.0.0",
			description: "Backend API for shuttle, mess, faculty and search modules."
		},
		components: await OpenAPI.components,
		paths: await OpenAPI.getPaths()
	}
}));
//#endregion
//#region src/modules/auth/index.ts
const authController = new Elysia$1({
	name: "auth",
	prefix: "/auth",
	tags: ["Auth"]
}).all("/*", async ({ request }) => {
	return await auth.handler(request);
});
//#endregion
//#region src/common/http.ts
const SuccessEnvelope = (data, message) => ({
	success: true,
	message,
	data
});
const ErrorEnvelope = (message) => ({
	success: false,
	message
});
const MetaSchema = t.Object({
	updatedAt: t.String(),
	version: t.String()
});
const toIso = (value) => {
	if (value instanceof Date) return value.toISOString();
	if (typeof value === "string") {
		const parsed = new Date(value);
		if (!Number.isNaN(parsed.getTime())) return parsed.toISOString();
		return value;
	}
	return null;
};
//#endregion
//#region src/modules/competition/model.ts
const CompetitionItemSchema = t.Object({
	websiteUrl: t.String(),
	title: t.String(),
	applyLink: t.String(),
	deadline: t.String()
});
//#endregion
//#region src/modules/competition/service.ts
const COMPETITIONS = [
	{
		websiteUrl: "https://www.droneexpo.in/",
		title: "Drone Expo 2026",
		applyLink: "https://www.droneexpo.in/visitor-registration",
		deadline: "2026-04-17"
	},
	{
		websiteUrl: "https://www.ursc.gov.in/IRoC-U2026/events.jsp#skipmaincontent",
		title: "ISRO Robotics Challenge 2026",
		applyLink: "https://www.ursc.gov.in/IRoC-U2026/events.jsp#skipmaincontent",
		deadline: "2026-04-02"
	},
	{
		websiteUrl: "https://www.safmc.com.sg/about-the-competition/",
		title: "Singapore Amazing Flying Machine Competition",
		applyLink: "https://www.safmc.com.sg/registration/",
		deadline: "2026-02-27"
	},
	{
		websiteUrl: "https://roboclub.technoxian.com/",
		title: "Technoxian World Robotics Championship 10.0",
		applyLink: "https://roboclub.technoxian.com/",
		deadline: "2026-04-07"
	}
];
var CompetitionService = class {
	async getCompetitions() {
		return COMPETITIONS;
	}
};
const competitionService = new CompetitionService();
//#endregion
//#region src/modules/competition/index.ts
const competitionController = new Elysia$1({ prefix: "/competitions" }).get("/", async () => {
	return SuccessEnvelope(await competitionService.getCompetitions(), "Competitions retrieved successfully");
}, {
	response: { 200: t.Object({
		success: t.Literal(true),
		message: t.String(),
		data: t.Array(CompetitionItemSchema)
	}) },
	detail: {
		summary: "Get competitions list",
		tags: ["Competitions"]
	}
});
//#endregion
//#region src/modules/auth/auth-plugin.ts
const authPlugin = new Elysia$1({ name: "auth-plugin" }).macro({ auth: { async resolve({ status, request: { headers } }) {
	const session = await auth.api.getSession({ headers });
	if (!session) return status(401, ErrorEnvelope("Unauthorized Access"));
	return {
		user: session.user,
		session: session.session
	};
} } });
//#endregion
//#region src/modules/colab/model.ts
const ColabTypeSchema = t.Union([t.Literal("project"), t.Literal("job")]);
const ColabRequestTypeSchema = t.Union([t.Literal("join"), t.Literal("invite")]);
const ColabRequestStatusSchema = t.Union([
	t.Literal("pending"),
	t.Literal("accepted"),
	t.Literal("rejected"),
	t.Literal("cancelled"),
	t.Literal("expired")
]);
const ColabCreateFormSchema = t.Object({
	title: t.String({
		minLength: 3,
		maxLength: 120
	}),
	description: t.String({
		minLength: 10,
		maxLength: 2e3
	}),
	type: ColabTypeSchema,
	requirements: t.Optional(t.String({ maxLength: 2e3 })),
	maxMembers: t.Optional(t.String()),
	startDate: t.Optional(t.String()),
	endDate: t.Optional(t.String()),
	isActive: t.Optional(t.String()),
	image: t.Optional(t.File({
		type: "image",
		maxSize: "10m"
	}))
});
const ColabUpdateFormSchema = t.Object({
	title: t.Optional(t.String({
		minLength: 3,
		maxLength: 120
	})),
	description: t.Optional(t.String({
		minLength: 10,
		maxLength: 2e3
	})),
	type: t.Optional(ColabTypeSchema),
	requirements: t.Optional(t.String({ maxLength: 2e3 })),
	maxMembers: t.Optional(t.String()),
	startDate: t.Optional(t.String()),
	endDate: t.Optional(t.String()),
	isActive: t.Optional(t.String()),
	image: t.Optional(t.File({
		type: "image",
		maxSize: "10m"
	}))
});
const ColabListQuerySchema = t.Object({
	type: t.Optional(ColabTypeSchema),
	isActive: t.Optional(t.Boolean()),
	createdBy: t.Optional(t.String())
});
const ColabItemSchema = t.Object({
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
	joinedCount: t.Integer()
});
const ColabDetailSchema = ColabItemSchema;
t.Object({
	colabId: t.String(),
	userId: t.String(),
	joinedAt: t.String()
});
const ColabRequestCreateSchema = t.Object({
	colabId: t.String(),
	recipientId: t.Optional(t.String()),
	message: t.Optional(t.String({ maxLength: 1e3 })),
	expiresAt: t.Optional(t.String())
});
const ColabRequestDecisionSchema = t.Object({ requestId: t.String() });
const ColabRequestSchema = t.Object({
	id: t.String(),
	colabId: t.String(),
	requesterId: t.String(),
	recipientId: t.String(),
	type: ColabRequestTypeSchema,
	status: ColabRequestStatusSchema,
	message: t.String(),
	expiresAt: t.Union([t.String(), t.Null()]),
	createdAt: t.String(),
	updatedAt: t.String()
});
//#endregion
//#region src/db/turso/index.ts
const db = drizzle$1({ connection: {
	url: process.env.TURSO_DB_URL,
	authToken: process.env.TURSO_DB_KEY
} });
//#endregion
//#region src/modules/colab/service.ts
var ColabService = class {
	async list(filters) {
		const joinedCount = db$1.select({
			colabId: colabMember.colabId,
			joinedCount: count(colabMember.userId).as("joined_count")
		}).from(colabMember).groupBy(colabMember.colabId).as("joined_count");
		return db$1.select({
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
			joinedCount: sql`coalesce(${joinedCount.joinedCount}, 0)`.mapWith(Number).as("joined_count")
		}).from(colab).leftJoin(joinedCount, eq(joinedCount.colabId, colab.id)).where(and(filters.type ? eq(colab.type, filters.type) : void 0, filters.isActive !== void 0 ? eq(colab.isActive, filters.isActive) : void 0, filters.createdBy ? eq(colab.createdBy, filters.createdBy) : void 0)).orderBy(desc(colab.createdAt));
	}
	async getById(id) {
		const joinedCount = db$1.select({
			colabId: colabMember.colabId,
			joinedCount: count(colabMember.userId).as("joined_count")
		}).from(colabMember).groupBy(colabMember.colabId).as("joined_count");
		return (await db$1.select({
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
			joinedCount: sql`coalesce(${joinedCount.joinedCount}, 0)`.mapWith(Number).as("joined_count")
		}).from(colab).leftJoin(joinedCount, eq(joinedCount.colabId, colab.id)).where(eq(colab.id, id)).limit(1))[0] ?? null;
	}
	async create(userId, payload, imageUrl) {
		const id = randomUUID();
		const [row] = await db$1.insert(colab).values({
			id,
			imageUrl: imageUrl ?? null,
			title: payload.title,
			description: payload.description,
			type: payload.type,
			requirements: payload.requirements ?? "",
			maxMembers: payload.maxMembers ?? null,
			startDate: payload.startDate ? new Date(payload.startDate) : null,
			endDate: payload.endDate ? new Date(payload.endDate) : null,
			isActive: payload.isActive ?? true,
			createdBy: userId
		}).returning();
		return row;
	}
	async update(id, userId, payload, imageUrl) {
		const [row] = await db$1.update(colab).set({
			title: payload.title,
			description: payload.description,
			type: payload.type,
			requirements: payload.requirements,
			maxMembers: payload.maxMembers,
			startDate: payload.startDate ? new Date(payload.startDate) : void 0,
			endDate: payload.endDate ? new Date(payload.endDate) : void 0,
			isActive: payload.isActive,
			imageUrl: imageUrl ?? void 0
		}).where(and(eq(colab.id, id), eq(colab.createdBy, userId))).returning();
		return row ?? null;
	}
	async remove(id, userId) {
		return (await db$1.delete(colab).where(and(eq(colab.id, id), eq(colab.createdBy, userId))).returning({ id: colab.id }))[0] ?? null;
	}
	async createJoinRequest(userId, payload) {
		const target = (await db$1.select({
			id: colab.id,
			createdBy: colab.createdBy
		}).from(colab).where(eq(colab.id, payload.colabId)).limit(1))[0];
		if (!target) return null;
		const id = randomUUID();
		const [row] = await db$1.insert(colabRequest).values({
			id,
			colabId: payload.colabId,
			requesterId: userId,
			recipientId: target.createdBy,
			type: colabRequestTypeEnum.enumValues[0],
			status: colabRequestStatusEnum.enumValues[0],
			message: payload.message ?? "",
			expiresAt: payload.expiresAt ? new Date(payload.expiresAt) : null
		}).returning();
		return row;
	}
	async createInviteRequest(userId, payload) {
		if (!payload.recipientId) return null;
		const id = randomUUID();
		const [row] = await db$1.insert(colabRequest).values({
			id,
			colabId: payload.colabId,
			requesterId: userId,
			recipientId: payload.recipientId,
			type: colabRequestTypeEnum.enumValues[1],
			status: colabRequestStatusEnum.enumValues[0],
			message: payload.message ?? "",
			expiresAt: payload.expiresAt ? new Date(payload.expiresAt) : null
		}).returning();
		return row;
	}
	async listRequests(userId) {
		return db$1.select().from(colabRequest).where(and(eq(colabRequest.recipientId, userId), eq(colabRequest.status, colabRequestStatusEnum.enumValues[0]))).orderBy(desc(colabRequest.createdAt));
	}
	async acceptRequest(userId, requestId) {
		const [requestRow] = await db$1.select().from(colabRequest).where(and(eq(colabRequest.id, requestId), eq(colabRequest.recipientId, userId))).limit(1);
		if (!requestRow || requestRow.status !== colabRequestStatusEnum.enumValues[0]) return null;
		await db$1.transaction(async (tx) => {
			await tx.update(colabRequest).set({ status: colabRequestStatusEnum.enumValues[1] }).where(eq(colabRequest.id, requestId));
			await tx.insert(colabMember).values({
				colabId: requestRow.colabId,
				userId: requestRow.type === colabRequestTypeEnum.enumValues[0] ? requestRow.requesterId : requestRow.recipientId
			}).onConflictDoNothing();
		});
		return requestRow;
	}
	async rejectRequest(userId, requestId) {
		return (await db$1.update(colabRequest).set({ status: colabRequestStatusEnum.enumValues[2] }).where(and(eq(colabRequest.id, requestId), eq(colabRequest.recipientId, userId))).returning())[0] ?? null;
	}
};
const colabService = new ColabService();
//#endregion
//#region src/services/image.service.ts
v2.config({
	cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
	api_key: process.env.CLOUDINARY_API_KEY,
	api_secret: process.env.CLOUDINARY_API_SECRET,
	secure: true
});
const imageService = { async optimizeAndUpload(fileBuffer, options) {
	const { maxWidth = 1920, maxHeight = 1080, quality = 85, folder = "colab" } = options || {};
	const meta = await metadata(fileBuffer);
	let optimizedBuffer = fileBuffer;
	if (meta.width > maxWidth || meta.height > maxHeight) optimizedBuffer = await toWebp(await resize(fileBuffer, {
		width: Math.min(meta.width, maxWidth),
		height: Math.min(meta.height, maxHeight),
		fit: "inside"
	}), { quality });
	else optimizedBuffer = await toWebp(fileBuffer, { quality });
	return new Promise((resolve, reject) => {
		v2.uploader.upload_stream({
			folder,
			format: "webp",
			transformation: [{ quality: "auto" }, { fetch_format: "auto" }]
		}, (error, result) => {
			if (error) return reject(error);
			resolve(result?.secure_url || "");
		}).end(optimizedBuffer);
	});
} };
//#endregion
//#region src/modules/colab/index.ts
const ColabIdParamsSchema = t.Object({ id: t.String() });
const colabController = new Elysia$1({ prefix: "/colabs" }).use(authPlugin).get("/", async ({ query }) => {
	return SuccessEnvelope((await colabService.list({
		type: query.type,
		isActive: query.isActive,
		createdBy: query.createdBy
	})).map((item) => ({
		...item,
		startDate: toIso(item.startDate) ?? null,
		endDate: toIso(item.endDate) ?? null,
		createdAt: toIso(item.createdAt) ?? "",
		updatedAt: toIso(item.updatedAt) ?? ""
	})), "Colabs retrieved successfully");
}, {
	query: ColabListQuerySchema,
	response: { 200: t.Object({
		success: t.Literal(true),
		message: t.String(),
		data: t.Array(ColabItemSchema)
	}) },
	detail: {
		summary: "List colabs",
		tags: ["Colab"]
	}
}).get("/:id", async ({ params, status: setStatus }) => {
	const data = await colabService.getById(params.id);
	if (!data) return setStatus(404, ErrorEnvelope("Colab not found"));
	return SuccessEnvelope({
		...data,
		startDate: toIso(data.startDate) ?? null,
		endDate: toIso(data.endDate) ?? null,
		createdAt: toIso(data.createdAt) ?? "",
		updatedAt: toIso(data.updatedAt) ?? ""
	}, "Colab retrieved successfully");
}, {
	params: ColabIdParamsSchema,
	response: {
		200: t.Object({
			success: t.Literal(true),
			message: t.String(),
			data: ColabDetailSchema
		}),
		404: t.Object({
			success: t.Literal(false),
			message: t.String()
		})
	},
	detail: {
		summary: "Get colab detail",
		tags: ["Colab"]
	}
}).post("/", async ({ body, user }) => {
	let imageUrl = null;
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
		maxMembers: body.maxMembers ? parseInt(body.maxMembers) : void 0,
		startDate: body.startDate,
		endDate: body.endDate,
		isActive: body.isActive ? body.isActive === "true" : void 0
	}, imageUrl);
	return SuccessEnvelope({
		...data,
		startDate: toIso(data.startDate) ?? null,
		endDate: toIso(data.endDate) ?? null,
		createdAt: toIso(data.createdAt) ?? "",
		updatedAt: toIso(data.updatedAt) ?? "",
		joinedCount: 0
	}, "Colab created successfully");
}, {
	auth: true,
	body: ColabCreateFormSchema,
	response: { 200: t.Object({
		success: t.Literal(true),
		message: t.String(),
		data: ColabItemSchema
	}) },
	detail: {
		summary: "Create colab with image upload",
		tags: ["Colab"]
	}
}).patch("/:id", async ({ params, body, user, status: setStatus }) => {
	let imageUrl = void 0;
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
		maxMembers: body.maxMembers ? parseInt(body.maxMembers) : void 0,
		startDate: body.startDate,
		endDate: body.endDate,
		isActive: body.isActive ? body.isActive === "true" : void 0
	}, imageUrl);
	if (!data) return setStatus(404, ErrorEnvelope("Colab not found"));
	return SuccessEnvelope({
		...data,
		startDate: toIso(data.startDate) ?? null,
		endDate: toIso(data.endDate) ?? null,
		createdAt: toIso(data.createdAt) ?? "",
		updatedAt: toIso(data.updatedAt) ?? "",
		joinedCount: 0
	}, "Colab updated successfully");
}, {
	auth: true,
	params: ColabIdParamsSchema,
	body: ColabUpdateFormSchema,
	response: {
		200: t.Object({
			success: t.Literal(true),
			message: t.String(),
			data: ColabItemSchema
		}),
		404: t.Object({
			success: t.Literal(false),
			message: t.String()
		})
	},
	detail: {
		summary: "Update colab with image upload",
		tags: ["Colab"]
	}
}).delete("/:id", async ({ params, user, status: setStatus }) => {
	const data = await colabService.remove(params.id, user.id);
	if (!data) return setStatus(404, ErrorEnvelope("Colab not found"));
	return SuccessEnvelope(data, "Colab deleted successfully");
}, {
	auth: true,
	params: ColabIdParamsSchema,
	response: {
		200: t.Object({
			success: t.Literal(true),
			message: t.String(),
			data: t.Object({ id: t.String() })
		}),
		404: t.Object({
			success: t.Literal(false),
			message: t.String()
		})
	},
	detail: {
		summary: "Delete colab",
		tags: ["Colab"]
	}
}).post("/requests/join", async ({ body, user, status: setStatus }) => {
	const data = await colabService.createJoinRequest(user.id, body);
	if (!data) return setStatus(404, ErrorEnvelope("Colab not found"));
	return SuccessEnvelope({
		...data,
		createdAt: toIso(data.createdAt) ?? "",
		updatedAt: toIso(data.updatedAt) ?? "",
		expiresAt: toIso(data.expiresAt) ?? null
	}, "Join request created");
}, {
	auth: true,
	body: ColabRequestCreateSchema,
	response: {
		200: t.Object({
			success: t.Literal(true),
			message: t.String(),
			data: ColabRequestSchema
		}),
		404: t.Object({
			success: t.Literal(false),
			message: t.String()
		})
	},
	detail: {
		summary: "Create join request",
		tags: ["Colab"]
	}
}).post("/requests/invite", async ({ body, user, status: setStatus }) => {
	const data = await colabService.createInviteRequest(user.id, body);
	if (!data) return setStatus(400, ErrorEnvelope("Invalid invite request"));
	return SuccessEnvelope({
		...data,
		createdAt: toIso(data.createdAt) ?? "",
		updatedAt: toIso(data.updatedAt) ?? "",
		expiresAt: toIso(data.expiresAt) ?? null
	}, "Invite request created");
}, {
	auth: true,
	body: ColabRequestCreateSchema,
	response: {
		200: t.Object({
			success: t.Literal(true),
			message: t.String(),
			data: ColabRequestSchema
		}),
		400: t.Object({
			success: t.Literal(false),
			message: t.String()
		})
	},
	detail: {
		summary: "Create invite request",
		tags: ["Colab"]
	}
}).get("/requests", async ({ user }) => {
	return SuccessEnvelope((await colabService.listRequests(user.id)).map((item) => ({
		...item,
		createdAt: toIso(item.createdAt) ?? "",
		updatedAt: toIso(item.updatedAt) ?? "",
		expiresAt: toIso(item.expiresAt) ?? null
	})), "Requests retrieved successfully");
}, {
	auth: true,
	response: { 200: t.Object({
		success: t.Literal(true),
		message: t.String(),
		data: t.Array(ColabRequestSchema)
	}) },
	detail: {
		summary: "List incoming requests",
		tags: ["Colab"]
	}
}).post("/requests/accept", async ({ body, user, status: setStatus }) => {
	const data = await colabService.acceptRequest(user.id, body.requestId);
	if (!data) return setStatus(404, ErrorEnvelope("Request not found"));
	return SuccessEnvelope({
		...data,
		createdAt: toIso(data.createdAt) ?? "",
		updatedAt: toIso(data.updatedAt) ?? "",
		expiresAt: toIso(data.expiresAt) ?? null
	}, "Request accepted");
}, {
	auth: true,
	body: ColabRequestDecisionSchema,
	response: {
		200: t.Object({
			success: t.Literal(true),
			message: t.String(),
			data: ColabRequestSchema
		}),
		404: t.Object({
			success: t.Literal(false),
			message: t.String()
		})
	},
	detail: {
		summary: "Accept request",
		tags: ["Colab"]
	}
}).post("/requests/reject", async ({ body, user, status: setStatus }) => {
	const data = await colabService.rejectRequest(user.id, body.requestId);
	if (!data) return setStatus(404, ErrorEnvelope("Request not found"));
	return SuccessEnvelope({
		...data,
		createdAt: toIso(data.createdAt) ?? "",
		updatedAt: toIso(data.updatedAt) ?? "",
		expiresAt: toIso(data.expiresAt) ?? null
	}, "Request rejected");
}, {
	auth: true,
	body: ColabRequestDecisionSchema,
	response: {
		200: t.Object({
			success: t.Literal(true),
			message: t.String(),
			data: ColabRequestSchema
		}),
		404: t.Object({
			success: t.Literal(false),
			message: t.String()
		})
	},
	detail: {
		summary: "Reject request",
		tags: ["Colab"]
	}
});
//#endregion
//#region src/modules/developer/model.ts
const WeekTypeSchema$1 = t.Union([t.Literal("odd"), t.Literal("even")]);
const SetWeekTypeBodySchema = t.Object({ weekType: WeekTypeSchema$1 });
const WeekConfigResponseSchema = t.Object({
	referenceDate: t.String(),
	weekType: WeekTypeSchema$1
});
//#endregion
//#region src/db/turso/schema.ts
const facultyTable = sqliteTable("faculty", {
	id: integer$1().primaryKey({ autoIncrement: true }),
	name: text$1().notNull(),
	slug: text$1().notNull(),
	imageUrl: text$1("image_url").notNull().default(""),
	department: text$1().notNull().default(""),
	designation: text$1().notNull().default(""),
	email: text$1().notNull().default(""),
	biosketch: text$1().notNull().default(""),
	teaching: text$1().notNull().default(""),
	office: text$1().notNull().default(""),
	publications: text$1().notNull().default(""),
	additionalInformation: text$1("additional_information").notNull().default(""),
	createdAt: integer$1("created_at", { mode: "timestamp" }).notNull().$defaultFn(() => /* @__PURE__ */ new Date()),
	updatedAt: integer$1("updated_at", { mode: "timestamp" }).notNull().$defaultFn(() => /* @__PURE__ */ new Date())
}, (table) => [uniqueIndex("faculty_slug_unique").on(table.slug)]);
const messTable = sqliteTable("mess", {
	id: integer$1().primaryKey({ autoIncrement: true }),
	weekType: text$1("week_type").notNull(),
	day: text$1().notNull(),
	meals: text$1({ mode: "json" }).$type().notNull(),
	createdAt: integer$1("created_at", { mode: "timestamp" }).notNull().$defaultFn(() => /* @__PURE__ */ new Date()),
	updatedAt: integer$1("updated_at", { mode: "timestamp" }).notNull().$defaultFn(() => /* @__PURE__ */ new Date())
});
const shuttleTable = sqliteTable("shuttle", {
	id: integer$1().primaryKey({ autoIncrement: true }),
	from: text$1().notNull(),
	to: text$1().notNull(),
	time: text$1().notNull(),
	via: text$1({ mode: "json" }).$type().notNull().default([]),
	days: text$1({ mode: "json" }).$type().notNull().default([]),
	isOutsideTrip: integer$1("is_outside_trip", { mode: "boolean" }).notNull().default(false),
	isMultipleBuses: integer$1("is_multiple_buses", { mode: "boolean" }).notNull().default(false),
	createdAt: integer$1("created_at", { mode: "timestamp" }).notNull().$defaultFn(() => /* @__PURE__ */ new Date()),
	updatedAt: integer$1("updated_at", { mode: "timestamp" }).notNull().$defaultFn(() => /* @__PURE__ */ new Date())
});
const messWeekConfigTable = sqliteTable("mess_week_config", {
	id: integer$1().primaryKey({ autoIncrement: true }),
	referenceDate: text$1("reference_date").notNull(),
	weekType: text$1("week_type").notNull(),
	createdAt: integer$1("created_at", { mode: "timestamp" }).notNull().$defaultFn(() => /* @__PURE__ */ new Date()),
	updatedAt: integer$1("updated_at", { mode: "timestamp" }).notNull().$defaultFn(() => /* @__PURE__ */ new Date())
});
const equipmentTable = sqliteTable("equipment", {
	id: integer$1().primaryKey({ autoIncrement: true }),
	name: text$1().notNull(),
	imageUrl: text$1("image_url").notNull().default(""),
	make: text$1().notNull().default(""),
	model: text$1().notNull().default(""),
	type: text$1().notNull().default(""),
	description: text$1().notNull().default(""),
	createdAt: integer$1("created_at", { mode: "timestamp" }).notNull().$defaultFn(() => /* @__PURE__ */ new Date()),
	updatedAt: integer$1("updated_at", { mode: "timestamp" }).notNull().$defaultFn(() => /* @__PURE__ */ new Date())
});
//#endregion
//#region src/modules/developer/service.ts
var DeveloperService = class {
	async setWeekType(weekType) {
		const now = (/* @__PURE__ */ new Date()).toISOString().split("T")[0];
		const existing = await db.select().from(messWeekConfigTable).limit(1);
		if (existing.length > 0) return (await db.update(messWeekConfigTable).set({
			referenceDate: now,
			weekType,
			updatedAt: /* @__PURE__ */ new Date()
		}).where(eq(messWeekConfigTable.id, existing[0].id)).returning())[0];
		return (await db.insert(messWeekConfigTable).values({
			referenceDate: now,
			weekType
		}).returning())[0];
	}
	async getWeekConfig() {
		return (await db.select().from(messWeekConfigTable).limit(1))[0] ?? null;
	}
};
const developerService = new DeveloperService();
//#endregion
//#region src/modules/mess/service.ts
const WEEK_REFERENCE_UTC = /* @__PURE__ */ new Date("2026-01-05T00:00:00.000Z");
const normalizeWeekType = (value) => value.toLowerCase() === "even" ? "even" : "odd";
var MessService = class {
	weekConfigCache = void 0;
	invalidateWeekConfigCache() {
		this.weekConfigCache = void 0;
	}
	async getWeekConfig() {
		if (this.weekConfigCache === void 0) {
			const rows = await db.select({
				referenceDate: messWeekConfigTable.referenceDate,
				weekType: messWeekConfigTable.weekType
			}).from(messWeekConfigTable).limit(1);
			this.weekConfigCache = rows[0] ?? null;
		}
		return this.weekConfigCache;
	}
	async getMenu(filters) {
		return db.select({
			id: messTable.id,
			weekType: messTable.weekType,
			day: messTable.day,
			meals: messTable.meals
		}).from(messTable).where(filters.weekType ? and(eq(messTable.weekType, filters.weekType)) : void 0).orderBy(messTable.weekType, messTable.day);
	}
	calculateWeekType(date, refDate, baseType) {
		const diffMs = date.getTime() - refDate.getTime();
		const diffWeeks = Math.floor(diffMs / (10080 * 60 * 1e3));
		if (Math.abs(diffWeeks) % 2 === 0) return baseType;
		return baseType === "odd" ? "even" : "odd";
	}
	async calculateCurrentWeek(date = /* @__PURE__ */ new Date()) {
		const config = await this.getWeekConfig();
		if (config) {
			const refDate = /* @__PURE__ */ new Date(config.referenceDate + "T00:00:00.000Z");
			return this.calculateWeekType(date, refDate, config.weekType);
		}
		return this.calculateWeekType(date, WEEK_REFERENCE_UTC, "odd");
	}
	getCurrentDay(date = /* @__PURE__ */ new Date()) {
		return [
			"sunday",
			"monday",
			"tuesday",
			"wednesday",
			"thursday",
			"friday",
			"saturday"
		][date.getUTCDay()] ?? "monday";
	}
	async getTodayMenu() {
		const now = /* @__PURE__ */ new Date();
		const calculatedWeek = await this.calculateCurrentWeek(now);
		const day = this.getCurrentDay(now);
		const rows = await db.select({
			id: messTable.id,
			meals: messTable.meals
		}).from(messTable).where(and(eq(messTable.weekType, calculatedWeek), eq(messTable.day, day))).limit(1);
		return {
			date: now.toISOString().slice(0, 10),
			calculatedWeek,
			day,
			meals: rows[0]?.meals ?? {}
		};
	}
	async getMessMetadata() {
		const updatedAt = (await db.select({ updatedAt: messTable.updatedAt }).from(messTable).orderBy(desc(messTable.updatedAt)).limit(1))[0]?.updatedAt ?? null;
		const total = (await db.select({ total: sql`count(${messTable.id})` }).from(messTable))[0]?.total ?? 0;
		const calculatedWeek = await this.calculateCurrentWeek();
		return {
			updatedAt,
			version: `mess-${total}`,
			calculatedWeek
		};
	}
	mapMenuWeekType(value) {
		return normalizeWeekType(value);
	}
};
const messService = new MessService();
//#endregion
//#region src/modules/developer/index.ts
const developerController = new Elysia$1({ prefix: "/developer" }).onBeforeHandle(({ request: { headers }, status }) => {
	const apiKey = headers.get("x-api-key");
	const expectedApiKey = process.env.API_KEY;
	if (!expectedApiKey) return status(500, ErrorEnvelope("API key not configured on server"));
	if (apiKey !== expectedApiKey) return status(401, ErrorEnvelope("Invalid API key"));
}).post("/mess/week-type", async ({ body }) => {
	const result = await developerService.setWeekType(body.weekType);
	messService.invalidateWeekConfigCache();
	return SuccessEnvelope({
		referenceDate: result.referenceDate,
		weekType: result.weekType
	}, "Mess week type configuration saved");
}, {
	body: SetWeekTypeBodySchema,
	response: { 200: t.Object({
		success: t.Literal(true),
		message: t.String(),
		data: WeekConfigResponseSchema
	}) },
	detail: {
		summary: "Set mess week type reference",
		description: "Sets the current date as the reference point for mess week type calculation. The provided week type (odd/even) will be assigned to the current week, and all future weeks will alternate from this reference.",
		tags: ["Developer"]
	}
});
//#endregion
//#region src/modules/faculty/model.ts
const FacultyListQuerySchema = t.Object({ department: t.Optional(t.String()) });
const FacultySlugParamsSchema = t.Object({ slug: t.String({ minLength: 1 }) });
const FacultyListItemSchema = t.Object({
	id: t.Number(),
	slug: t.String(),
	name: t.String(),
	designation: t.String(),
	department: t.String(),
	imageUrl: t.String()
});
const FacultyDetailSchema = t.Object({
	id: t.Number(),
	slug: t.String(),
	name: t.String(),
	imageUrl: t.String(),
	department: t.String(),
	designation: t.String(),
	email: t.String(),
	biosketch: t.String(),
	teaching: t.String(),
	office: t.String(),
	publications: t.String(),
	additionalInformation: t.String()
});
//#endregion
//#region src/modules/faculty/service.ts
var FacultyService = class {
	async getFacultyList(filters) {
		return db.select({
			id: facultyTable.id,
			slug: facultyTable.slug,
			name: facultyTable.name,
			designation: facultyTable.designation,
			department: facultyTable.department,
			imageUrl: facultyTable.imageUrl
		}).from(facultyTable).where(filters.department ? and(eq(facultyTable.department, filters.department)) : void 0).orderBy(facultyTable.name);
	}
	async getFacultyBySlug(slug) {
		return (await db.select({
			id: facultyTable.id,
			slug: facultyTable.slug,
			name: facultyTable.name,
			imageUrl: facultyTable.imageUrl,
			department: facultyTable.department,
			designation: facultyTable.designation,
			email: facultyTable.email,
			biosketch: facultyTable.biosketch,
			teaching: facultyTable.teaching,
			office: facultyTable.office,
			publications: facultyTable.publications,
			additionalInformation: facultyTable.additionalInformation
		}).from(facultyTable).where(eq(facultyTable.slug, slug)).limit(1))[0] ?? null;
	}
	async getFacultyMetadata() {
		const updatedAt = (await db.select({ updatedAt: facultyTable.updatedAt }).from(facultyTable).orderBy(desc(facultyTable.updatedAt)).limit(1))[0]?.updatedAt ?? null;
		return {
			updatedAt,
			version: updatedAt ? updatedAt.toISOString().slice(0, 10) : "0"
		};
	}
};
const facultyService = new FacultyService();
//#endregion
//#region src/modules/faculty/index.ts
const facultyController = new Elysia$1({ prefix: "/faculty" }).get("/", async ({ query }) => {
	return SuccessEnvelope(await facultyService.getFacultyList({ department: query.department }), "Faculty list retrieved successfully");
}, {
	query: FacultyListQuerySchema,
	response: { 200: t.Object({
		success: t.Literal(true),
		message: t.String(),
		data: t.Array(FacultyListItemSchema)
	}) },
	detail: {
		summary: "Get faculty list",
		tags: ["Faculty"]
	}
}).get("/metadata", async () => {
	const data = await facultyService.getFacultyMetadata();
	return SuccessEnvelope({
		updatedAt: toIso(data.updatedAt) ?? "",
		version: data.version
	}, "Faculty metadata retrieved");
}, {
	response: { 200: t.Object({
		success: t.Literal(true),
		message: t.String(),
		data: MetaSchema
	}) },
	detail: {
		summary: "Get faculty metadata",
		tags: ["Faculty"]
	}
}).get("/:slug", async ({ params, status }) => {
	const data = await facultyService.getFacultyBySlug(params.slug);
	if (!data) return status(404, ErrorEnvelope("Faculty profile not found"));
	return SuccessEnvelope(data, "Faculty profile retrieved successfully");
}, {
	params: FacultySlugParamsSchema,
	response: {
		200: t.Object({
			success: t.Literal(true),
			message: t.String(),
			data: FacultyDetailSchema
		}),
		404: t.Object({
			success: t.Literal(false),
			message: t.String()
		})
	},
	detail: {
		summary: "Get faculty profile by slug",
		tags: ["Faculty"]
	}
});
//#endregion
//#region src/modules/mess/model.ts
const WeekTypeSchema = t.Union([t.Literal("odd"), t.Literal("even")]);
const WeekTypeQuerySchema = t.Object({ weekType: t.Optional(WeekTypeSchema) });
const MealSchema = t.Object({
	breakfast: t.Optional(t.Array(t.String())),
	lunch: t.Optional(t.Array(t.String())),
	snacks: t.Optional(t.Array(t.String())),
	dinner: t.Optional(t.Array(t.String()))
});
const MessMenuItemSchema = t.Object({
	id: t.Number(),
	weekType: WeekTypeSchema,
	day: t.String(),
	meals: MealSchema
});
const MessMetadataResponseSchema = t.Object({
	updatedAt: t.String(),
	version: t.String(),
	calculatedWeek: WeekTypeSchema
});
const MessTodaySchema = t.Object({
	date: t.String(),
	calculatedWeek: WeekTypeSchema,
	day: t.String(),
	meals: MealSchema
});
//#endregion
//#region src/modules/mess/index.ts
const messController = new Elysia$1({ prefix: "/mess" }).get("/menu", async ({ query }) => {
	return SuccessEnvelope((await messService.getMenu({ weekType: query.weekType })).map((item) => ({
		id: item.id,
		weekType: messService.mapMenuWeekType(item.weekType),
		day: item.day,
		meals: item.meals
	})), "Mess menu retrieved successfully");
}, {
	query: WeekTypeQuerySchema,
	response: { 200: t.Object({
		success: t.Literal(true),
		message: t.String(),
		data: t.Array(MessMenuItemSchema)
	}) },
	detail: {
		summary: "Get mess menu",
		tags: ["Mess"]
	}
}).get("/menu/today", async ({ status }) => {
	const data = await messService.getTodayMenu();
	if (!Object.keys(data.meals).length) return status(404, ErrorEnvelope("Mess menu for today was not found"));
	return SuccessEnvelope(data, "Today's menu retrieved");
}, {
	response: {
		200: t.Object({
			success: t.Literal(true),
			message: t.String(),
			data: MessTodaySchema
		}),
		404: t.Object({
			success: t.Literal(false),
			message: t.String()
		})
	},
	detail: {
		summary: "Get today mess menu",
		tags: ["Mess"]
	}
}).get("/metadata", async () => {
	const data = await messService.getMessMetadata();
	return SuccessEnvelope({
		updatedAt: toIso(data.updatedAt) ?? "",
		version: data.version,
		calculatedWeek: data.calculatedWeek
	}, "Mess metadata retrieved");
}, {
	response: { 200: t.Object({
		success: t.Literal(true),
		message: t.String(),
		data: MessMetadataResponseSchema
	}) },
	detail: {
		summary: "Get mess metadata",
		tags: ["Mess"]
	}
}).get("/week-types", () => {
	return SuccessEnvelope(["odd", "even"], "Available week types retrieved");
}, {
	response: { 200: t.Object({
		success: t.Literal(true),
		message: t.String(),
		data: t.Array(WeekTypeSchema)
	}) },
	detail: {
		summary: "Get allowed week types",
		tags: ["Mess"]
	}
});
//#endregion
//#region src/modules/search/model.ts
const SearchCategorySchema = t.Union([
	t.Literal("equipment"),
	t.Literal("faculty"),
	t.Literal("schedule")
]);
const SearchQuerySchema = t.Object({
	q: t.Optional(t.String()),
	category: t.Optional(SearchCategorySchema),
	limit: t.Optional(t.Numeric({
		minimum: 1,
		maximum: 100
	}))
});
const SearchSuggestionsQuerySchema = t.Object({
	q: t.Optional(t.String()),
	limit: t.Optional(t.Numeric({
		minimum: 1,
		maximum: 20
	}))
});
const SearchItemSchema = t.Object({
	id: t.String(),
	category: SearchCategorySchema,
	title: t.String(),
	subtitle: t.String(),
	description: t.String(),
	imageUrl: t.String(),
	metadata: t.Record(t.String(), t.String())
});
const SearchResponseDataSchema = t.Object({
	query: t.String(),
	category: t.Union([SearchCategorySchema, t.Null()]),
	totalCount: t.Number(),
	results: t.Array(SearchItemSchema)
});
//#endregion
//#region src/modules/search/service.ts
const scoreText = (value, query, highWeight, mediumWeight) => {
	const v = value.toLowerCase();
	const q = query.toLowerCase();
	if (v === q) return highWeight;
	if (v.includes(q)) return mediumWeight;
	return 0;
};
const rankAndLimit = (items, limit) => items.filter((item) => item.score > 0).sort((a, b) => b.score - a.score || a.title.localeCompare(b.title)).slice(0, limit).map(({ score: _score, ...item }) => item);
const termToSlug = (value) => value.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");
var SearchService = class {
	async search(filters) {
		if (!filters.q.trim()) return {
			query: filters.q,
			category: filters.category ?? null,
			totalCount: 0,
			results: []
		};
		const buckets = [];
		if (!filters.category || filters.category === "equipment") {
			const equipmentRows = await db.select({
				id: equipmentTable.id,
				name: equipmentTable.name,
				imageUrl: equipmentTable.imageUrl,
				make: equipmentTable.make,
				model: equipmentTable.model,
				type: equipmentTable.type,
				description: equipmentTable.description
			}).from(equipmentTable).where(or(like(equipmentTable.name, `%${filters.q}%`), like(equipmentTable.make, `%${filters.q}%`), like(equipmentTable.model, `%${filters.q}%`), like(equipmentTable.type, `%${filters.q}%`), like(equipmentTable.description, `%${filters.q}%`))).limit(filters.limit * 3);
			for (const row of equipmentRows) {
				const score = scoreText(row.name, filters.q, 120, 80) + scoreText(`${row.make} ${row.model}`.trim(), filters.q, 90, 60) + scoreText(row.description, filters.q, 30, 15);
				buckets.push({
					id: `equipment-${row.id}`,
					category: "equipment",
					title: row.name,
					subtitle: [row.make, row.model].filter(Boolean).join(" ").trim(),
					description: row.description,
					imageUrl: row.imageUrl,
					metadata: {
						make: row.make,
						model: row.model,
						toolType: row.type
					},
					score
				});
			}
		}
		if (!filters.category || filters.category === "faculty") {
			const facultyRows = await db.select({
				id: facultyTable.id,
				slug: facultyTable.slug,
				name: facultyTable.name,
				designation: facultyTable.designation,
				department: facultyTable.department,
				imageUrl: facultyTable.imageUrl,
				biosketch: facultyTable.biosketch
			}).from(facultyTable).where(or(like(facultyTable.name, `%${filters.q}%`), like(facultyTable.department, `%${filters.q}%`), like(facultyTable.designation, `%${filters.q}%`), like(facultyTable.biosketch, `%${filters.q}%`))).limit(filters.limit * 3);
			for (const row of facultyRows) {
				const score = scoreText(row.name, filters.q, 120, 80) + scoreText(row.designation, filters.q, 70, 45) + scoreText(row.biosketch, filters.q, 25, 10);
				buckets.push({
					id: `faculty-${row.slug || row.id}`,
					category: "faculty",
					title: row.name,
					subtitle: row.designation,
					description: row.biosketch,
					imageUrl: row.imageUrl,
					metadata: {
						slug: row.slug,
						department: row.department
					},
					score
				});
			}
		}
		if (!filters.category || filters.category === "schedule") {
			const matchedDay = [
				"monday",
				"tuesday",
				"wednesday",
				"thursday",
				"friday",
				"saturday",
				"sunday"
			].find((day) => day.includes(filters.q.toLowerCase()));
			const shuttleRows = await db.select({
				id: shuttleTable.id,
				from: shuttleTable.from,
				to: shuttleTable.to,
				time: shuttleTable.time,
				via: shuttleTable.via,
				days: shuttleTable.days,
				isOutsideTrip: shuttleTable.isOutsideTrip,
				isMultipleBuses: shuttleTable.isMultipleBuses
			}).from(shuttleTable).where(and(or(like(shuttleTable.from, `%${filters.q}%`), like(shuttleTable.to, `%${filters.q}%`), like(shuttleTable.time, `%${filters.q}%`)), ...matchedDay ? [like(shuttleTable.days, `%${matchedDay}%`)] : [])).limit(filters.limit * 2);
			for (const row of shuttleRows) {
				const score = scoreText(`${row.from} ${row.to} ${row.time}`, filters.q, 110, 75) + scoreText(row.via.join(" "), filters.q, 45, 25);
				buckets.push({
					id: `schedule-shuttle-${row.id}`,
					category: "schedule",
					title: `${row.from} -> ${row.to}`,
					subtitle: row.time,
					description: row.via.length ? `Via ${row.via.join(", ")}` : "Direct shuttle",
					imageUrl: "",
					metadata: {
						kind: "shuttle",
						isOutsideTrip: String(row.isOutsideTrip),
						isMultipleBuses: String(row.isMultipleBuses),
						days: row.days.join(",")
					},
					score
				});
			}
			const weekType = filters.q.toLowerCase().includes("even") ? "even" : filters.q.toLowerCase().includes("odd") ? "odd" : null;
			const messRows = await db.select({
				id: messTable.id,
				weekType: messTable.weekType,
				day: messTable.day
			}).from(messTable).where(and(or(like(messTable.day, `%${filters.q}%`), like(messTable.weekType, `%${filters.q}%`)), ...weekType ? [eq(messTable.weekType, weekType)] : [])).limit(filters.limit);
			for (const row of messRows) {
				const score = scoreText(`${row.weekType} ${row.day}`, filters.q, 90, 55);
				buckets.push({
					id: `schedule-mess-${row.id}`,
					category: "schedule",
					title: `Mess menu - ${row.day}`,
					subtitle: `${row.weekType} week`,
					description: "Mess schedule item",
					imageUrl: "",
					metadata: {
						kind: "mess",
						weekType: row.weekType,
						day: row.day
					},
					score
				});
			}
		}
		const ranked = rankAndLimit(buckets, filters.limit);
		return {
			query: filters.q,
			category: filters.category ?? null,
			totalCount: ranked.length,
			results: ranked
		};
	}
	async suggestions(query, limit) {
		if (!query.trim()) return [
			"Shuttle schedule",
			"Mess menu today",
			"Faculty directory",
			"3D printer",
			"CNC router"
		].slice(0, limit);
		const [equipmentRows, facultyRows, shuttleRows] = await Promise.all([
			db.select({ term: equipmentTable.name }).from(equipmentTable).where(like(equipmentTable.name, `${query}%`)).limit(limit),
			db.select({ term: facultyTable.name }).from(facultyTable).where(like(facultyTable.name, `${query}%`)).limit(limit),
			db.select({
				from: shuttleTable.from,
				to: shuttleTable.to
			}).from(shuttleTable).where(or(like(shuttleTable.from, `${query}%`), like(shuttleTable.to, `${query}%`))).limit(limit)
		]);
		const set = /* @__PURE__ */ new Set();
		for (const row of equipmentRows) if (row.term) set.add(row.term);
		for (const row of facultyRows) if (row.term) set.add(row.term);
		for (const row of shuttleRows) set.add(`${row.from} to ${row.to}`);
		if (set.size < limit) set.add(termToSlug(query).replace(/-/g, " "));
		return Array.from(set).filter(Boolean).slice(0, limit);
	}
};
const searchService = new SearchService();
//#endregion
//#region src/modules/search/index.ts
const searchController = new Elysia$1({ prefix: "/search" }).get("/", async ({ query }) => {
	const q = (query.q ?? "").trim();
	const limit = query.limit ?? 20;
	return SuccessEnvelope(await searchService.search({
		q,
		category: query.category,
		limit
	}), q ? `Search results for "${q}"` : "Empty query");
}, {
	query: SearchQuerySchema,
	response: { 200: t.Object({
		success: t.Literal(true),
		message: t.String(),
		data: SearchResponseDataSchema
	}) },
	detail: {
		summary: "Search across faculty, equipment and schedules",
		tags: ["Search"]
	}
}).get("/suggestions", async ({ query }) => {
	const q = (query.q ?? "").trim();
	const limit = query.limit ?? 8;
	return SuccessEnvelope(await searchService.suggestions(q, limit), q ? `Suggestions for "${q}"` : "Popular suggestions");
}, {
	query: SearchSuggestionsQuerySchema,
	response: { 200: t.Object({
		success: t.Literal(true),
		message: t.String(),
		data: t.Array(t.String())
	}) },
	detail: {
		summary: "Search query suggestions",
		tags: ["Search"]
	}
});
//#endregion
//#region src/modules/shuttle/model.ts
const ShuttleQuerySchema = t.Object({
	day: t.Optional(t.String()),
	from: t.Optional(t.String()),
	to: t.Optional(t.String())
});
const ShuttleItemSchema = t.Object({
	id: t.Number(),
	from: t.String(),
	to: t.String(),
	time: t.String(),
	via: t.Array(t.String()),
	days: t.Array(t.String()),
	isOutsideTrip: t.Boolean(),
	isMultipleBuses: t.Boolean()
});
//#endregion
//#region src/modules/shuttle/service.ts
var ShuttleService = class {
	async getShuttles(filters) {
		const clauses = [];
		if (filters.day) clauses.push(like(shuttleTable.days, `%${filters.day.toLowerCase()}%`));
		if (filters.from) clauses.push(eq(shuttleTable.from, filters.from));
		if (filters.to) clauses.push(eq(shuttleTable.to, filters.to));
		return db.select({
			id: shuttleTable.id,
			from: shuttleTable.from,
			to: shuttleTable.to,
			time: shuttleTable.time,
			via: shuttleTable.via,
			days: shuttleTable.days,
			isOutsideTrip: shuttleTable.isOutsideTrip,
			isMultipleBuses: shuttleTable.isMultipleBuses
		}).from(shuttleTable).where(clauses.length > 0 ? and(...clauses) : void 0).orderBy(shuttleTable.time, shuttleTable.from, shuttleTable.to);
	}
	async getShuttleMetadata() {
		const latestRows = await db.select({ updatedAt: shuttleTable.updatedAt }).from(shuttleTable).orderBy(desc(shuttleTable.updatedAt)).limit(1);
		const countRows = await db.select({ total: sql`count(${shuttleTable.id})` }).from(shuttleTable);
		return {
			updatedAt: latestRows[0]?.updatedAt ?? null,
			version: `shuttle-${countRows[0]?.total ?? 0}`
		};
	}
};
const shuttleService = new ShuttleService();
//#endregion
//#region src/modules/shuttle/index.ts
const shuttleController = new Elysia$1({ prefix: "/shuttles" }).get("/", async ({ query }) => {
	return SuccessEnvelope(await shuttleService.getShuttles({
		day: query.day,
		from: query.from,
		to: query.to
	}), "Shuttles retrieved successfully");
}, {
	query: ShuttleQuerySchema,
	response: { 200: t.Object({
		success: t.Literal(true),
		message: t.String(),
		data: t.Array(ShuttleItemSchema)
	}) },
	detail: {
		summary: "Get shuttle schedules",
		tags: ["Shuttles"]
	}
}).get("/metadata", async () => {
	const data = await shuttleService.getShuttleMetadata();
	return SuccessEnvelope({
		updatedAt: toIso(data.updatedAt) ?? "",
		version: data.version
	}, "Shuttle metadata retrieved");
}, {
	response: { 200: t.Object({
		success: t.Literal(true),
		message: t.String(),
		data: MetaSchema
	}) },
	detail: {
		summary: "Get shuttle metadata",
		tags: ["Shuttles"]
	}
});
//#endregion
//#region src/modules/index.ts
const apiRouter = new Elysia({
	name: "api",
	prefix: "/api"
}).get("/", () => {
	return SuccessEnvelope({ ok: true }, "CSquare Connect API is healthy");
}, { detail: {
	summary: "Health check endpoint",
	tags: ["General"]
} }).use(authController).use(developerController).group("/v1", (v1) => v1.use(colabController).use(facultyController).use(messController).use(shuttleController).use(competitionController).use(searchController));
//#endregion
//#region src/index.ts
var src_default = new Elysia$1().get("/", () => {
	return { status: "ok" };
}).use(cors$1).use(apiRouter);
//#endregion
export { src_default as default };
