import 'dotenv/config';
import { betterAuth } from 'better-auth';
import { drizzleAdapter } from 'better-auth/adapters/drizzle';

import { db } from '../../db/neon';
import * as schema from '../../db/neon/schema';

export const auth = betterAuth({
  database: drizzleAdapter(db, {
    provider: 'pg',
    schema
  }),
  trustedOrigins: [
    ...(process.env.NODE_ENV === 'development'
      ? ['http://localhost:3000']
      : []),
    process.env.PUBLIC_APP_URL!,
    process.env.PUBLIC_APP_URL!.replace(/\/$/, ''),
    ...(process.env.ALLOWED_ORIGINS?.split(',') ?? []),
    ...(process.env.MOBILE_APP_SCHEME
      ? [process.env.MOBILE_APP_SCHEME]
      : []),
  ],
      
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    },
  },
  session: {
    expiresIn: 60 * 60 * 24 * 7,
    updateAge: 60 * 60 * 24,
  },
  baseURL: process.env.PUBLIC_APP_URL || 'http://localhost:3000',
});