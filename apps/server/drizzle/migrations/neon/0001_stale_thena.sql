CREATE TYPE "public"."colab_request_status" AS ENUM('pending', 'accepted', 'rejected', 'cancelled', 'expired');--> statement-breakpoint
CREATE TYPE "public"."colab_request_type" AS ENUM('join', 'invite');--> statement-breakpoint
CREATE TYPE "public"."colab_type" AS ENUM('project', 'job');--> statement-breakpoint
CREATE TABLE "colab" (
	"id" text PRIMARY KEY NOT NULL,
	"image_url" text,
	"title" text NOT NULL,
	"description" text NOT NULL,
	"type" "colab_type" NOT NULL,
	"requirements" text DEFAULT '' NOT NULL,
	"max_members" integer,
	"start_date" timestamp,
	"end_date" timestamp,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_by" text NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "colab_member" (
	"colab_id" text NOT NULL,
	"user_id" text NOT NULL,
	"joined_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "colab_member_colab_id_user_id_pk" PRIMARY KEY("colab_id","user_id")
);
--> statement-breakpoint
CREATE TABLE "colab_request" (
	"id" text PRIMARY KEY NOT NULL,
	"colab_id" text NOT NULL,
	"requester_id" text NOT NULL,
	"recipient_id" text NOT NULL,
	"type" "colab_request_type" NOT NULL,
	"status" "colab_request_status" DEFAULT 'pending' NOT NULL,
	"message" text DEFAULT '' NOT NULL,
	"expires_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "colab" ADD CONSTRAINT "colab_created_by_user_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "colab_member" ADD CONSTRAINT "colab_member_colab_id_colab_id_fk" FOREIGN KEY ("colab_id") REFERENCES "public"."colab"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "colab_member" ADD CONSTRAINT "colab_member_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "colab_request" ADD CONSTRAINT "colab_request_colab_id_colab_id_fk" FOREIGN KEY ("colab_id") REFERENCES "public"."colab"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "colab_request" ADD CONSTRAINT "colab_request_requester_id_user_id_fk" FOREIGN KEY ("requester_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "colab_request" ADD CONSTRAINT "colab_request_recipient_id_user_id_fk" FOREIGN KEY ("recipient_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "colab_created_by_idx" ON "colab" USING btree ("created_by");--> statement-breakpoint
CREATE INDEX "colab_type_idx" ON "colab" USING btree ("type");--> statement-breakpoint
CREATE INDEX "colab_active_idx" ON "colab" USING btree ("is_active");--> statement-breakpoint
CREATE INDEX "colab_member_colab_idx" ON "colab_member" USING btree ("colab_id");--> statement-breakpoint
CREATE INDEX "colab_member_user_idx" ON "colab_member" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "colab_request_colab_idx" ON "colab_request" USING btree ("colab_id");--> statement-breakpoint
CREATE INDEX "colab_request_requester_idx" ON "colab_request" USING btree ("requester_id");--> statement-breakpoint
CREATE INDEX "colab_request_recipient_idx" ON "colab_request" USING btree ("recipient_id");--> statement-breakpoint
CREATE INDEX "colab_request_status_idx" ON "colab_request" USING btree ("status");