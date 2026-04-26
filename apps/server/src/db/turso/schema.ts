import { integer, sqliteTable, text, uniqueIndex } from 'drizzle-orm/sqlite-core';

export const facultyTable = sqliteTable(
  'faculty',
  {
    id: integer().primaryKey({ autoIncrement: true }),
    name: text().notNull(),
    slug: text().notNull(),
    imageUrl: text('image_url').notNull().default(''),
    department: text().notNull().default(''),
    designation: text().notNull().default(''),
    email: text().notNull().default(''),
    biosketch: text().notNull().default(''),
    teaching: text().notNull().default(''),
    office: text().notNull().default(''),
    publications: text().notNull().default(''),
    additionalInformation: text('additional_information').notNull().default(''),
    createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
    updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  },
  (table) => [uniqueIndex('faculty_slug_unique').on(table.slug)],
);

export const messTable = sqliteTable('mess', {
  id: integer().primaryKey({ autoIncrement: true }),
  weekType: text('week_type').notNull(),
  day: text().notNull(),
  meals: text({ mode: 'json' }).$type<{
    breakfast?: string[];
    lunch?: string[];
    snacks?: string[];
    dinner?: string[];
  }>().notNull(),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
});

export const shuttleTable = sqliteTable('shuttle', {
  id: integer().primaryKey({ autoIncrement: true }),
  from: text().notNull(),
  to: text().notNull(),
  time: text().notNull(),
  via: text({ mode: 'json' }).$type<string[]>().notNull().default([]),
  days: text({ mode: 'json' }).$type<string[]>().notNull().default([]),
  isOutsideTrip: integer('is_outside_trip', { mode: 'boolean' }).notNull().default(false),
  isMultipleBuses: integer('is_multiple_buses', { mode: 'boolean' }).notNull().default(false),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
});

export const equipmentTable = sqliteTable('equipment', {
  id: integer().primaryKey({ autoIncrement: true }),
  name: text().notNull(),
  imageUrl: text('image_url').notNull().default(''),
  make: text().notNull().default(''),
  model: text().notNull().default(''),
  type: text().notNull().default(''),
  description: text().notNull().default(''),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
});