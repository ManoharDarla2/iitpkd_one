# Elysia with Bun runtime

## Getting Started

To get started with this template, simply paste this command into your terminal:

```bash
bun create elysia ./elysia-example
```

## Development

To start the development server run:

```bash
bun run dev
```

Open http://localhost:3000/ with your browser to see the result.

## Database Setup (Neon + Drizzle)

1. Set `DATABASE_URL` in `.env` for the app runtime connection.
2. Set `DATABASE_URL_MIGRATIONS` to your direct Neon connection string for migrations.
   If you do not set it, Drizzle will fall back to `DATABASE_URL`.
3. Generate SQL migrations:

```bash
bun run db:generate
```

4. Apply migrations:

```bash
bun run db:migrate
```

5. Seed data from `scripts/data`:

```bash
bun run db:seed
```
