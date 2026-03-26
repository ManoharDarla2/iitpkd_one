CREATE TABLE "equipment" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "equipment_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"name" text NOT NULL,
	"image_url" text DEFAULT '' NOT NULL,
	"make" text DEFAULT '' NOT NULL,
	"model" text DEFAULT '' NOT NULL,
	"type" text DEFAULT '' NOT NULL,
	"description" text DEFAULT '' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "faculty" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "faculty_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"name" text NOT NULL,
	"slug" text NOT NULL,
	"image_url" text DEFAULT '' NOT NULL,
	"department" text DEFAULT '' NOT NULL,
	"designation" text DEFAULT '' NOT NULL,
	"email" text DEFAULT '' NOT NULL,
	"biosketch" text DEFAULT '' NOT NULL,
	"teaching" text DEFAULT '' NOT NULL,
	"office" text DEFAULT '' NOT NULL,
	"publications" text DEFAULT '' NOT NULL,
	"additional_information" text DEFAULT '' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "mess" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "mess_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"week_type" text NOT NULL,
	"day" text NOT NULL,
	"meals" jsonb NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "shuttle" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "shuttle_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"from" text NOT NULL,
	"to" text NOT NULL,
	"time" text NOT NULL,
	"via" text[] DEFAULT '{}' NOT NULL,
	"days" text[] DEFAULT '{}' NOT NULL,
	"is_outside_trip" boolean DEFAULT false NOT NULL,
	"is_multiple_buses" boolean DEFAULT false NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX "faculty_slug_unique" ON "faculty" USING btree ("slug");