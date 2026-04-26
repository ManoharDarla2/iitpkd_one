CREATE TABLE `equipment` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`name` text NOT NULL,
	`image_url` text DEFAULT '' NOT NULL,
	`make` text DEFAULT '' NOT NULL,
	`model` text DEFAULT '' NOT NULL,
	`type` text DEFAULT '' NOT NULL,
	`description` text DEFAULT '' NOT NULL,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE `faculty` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`name` text NOT NULL,
	`slug` text NOT NULL,
	`image_url` text DEFAULT '' NOT NULL,
	`department` text DEFAULT '' NOT NULL,
	`designation` text DEFAULT '' NOT NULL,
	`email` text DEFAULT '' NOT NULL,
	`biosketch` text DEFAULT '' NOT NULL,
	`teaching` text DEFAULT '' NOT NULL,
	`office` text DEFAULT '' NOT NULL,
	`publications` text DEFAULT '' NOT NULL,
	`additional_information` text DEFAULT '' NOT NULL,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX `faculty_slug_unique` ON `faculty` (`slug`);--> statement-breakpoint
CREATE TABLE `mess` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`week_type` text NOT NULL,
	`day` text NOT NULL,
	`meals` text NOT NULL,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE `shuttle` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`from` text NOT NULL,
	`to` text NOT NULL,
	`time` text NOT NULL,
	`via` text DEFAULT '[]' NOT NULL,
	`days` text DEFAULT '[]' NOT NULL,
	`is_outside_trip` integer DEFAULT false NOT NULL,
	`is_multiple_buses` integer DEFAULT false NOT NULL,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL
);
