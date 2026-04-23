import {
  boolean,
  integer,
  jsonb,
  pgTable,
  text,
  timestamp,
  uniqueIndex,
} from 'drizzle-orm/pg-core';

export const facultyTable = pgTable(
  'faculty',
  {
    id: integer().primaryKey().generatedAlwaysAsIdentity(),
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
    createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex('faculty_slug_unique').on(table.slug),
  ],
);

export const messTable = pgTable('mess', {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  weekType: text('week_type').notNull(),
  day: text().notNull(),
  meals: jsonb().$type<{
    breakfast?: string[];
    lunch?: string[];
    snacks?: string[];
    dinner?: string[];
  }>().notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
});

export const shuttleTable = pgTable('shuttle', {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  from: text().notNull(),
  to: text().notNull(),
  time: text().notNull(),
  via: text().array().notNull().default([]),
  days: text().array().notNull().default([]),
  isOutsideTrip: boolean('is_outside_trip').notNull().default(false),
  isMultipleBuses: boolean('is_multiple_buses').notNull().default(false),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
});

export const equipmentTable = pgTable('equipment', {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  name: text().notNull(),
  imageUrl: text('image_url').notNull().default(''),
  make: text().notNull().default(''),
  model: text().notNull().default(''),
  type: text().notNull().default(''),
  description: text().notNull().default(''),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
});
