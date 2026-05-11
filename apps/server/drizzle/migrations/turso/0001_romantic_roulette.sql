CREATE TABLE `mess_week_config` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`reference_date` text NOT NULL,
	`week_type` text NOT NULL,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL
);
