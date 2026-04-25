import 'dotenv/config';
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  out: './drizzle/migrations/neon',
  schema: './src/db/neon/schema.ts',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.NEON_DB_URL_MIGRATIONS ?? process.env.NEON_DB_URL!,
  },
});
