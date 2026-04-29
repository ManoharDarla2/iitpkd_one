import { Elysia } from 'elysia';
import { cors } from '@elysiajs/cors';
import { openapi } from '@elysiajs/openapi';

import { authController } from './modules/auth/auth.controller';
import { competitionController } from './modules/competition/competition.controller';
import { facultyController } from './modules/faculty/faculty.controller';
import { messController } from './modules/mess/mess.controller';
import { searchController } from './modules/search/search.controller';
import { shuttleController } from './modules/shuttle/shuttle.controller';

const port = Number(process.env.PORT ?? 3000);

const app = new Elysia()
  .use(cors({
    origin: process.env.NODE_ENV === 'development'
      ? ['http://localhost:4173']
      : [ 
        ...(process.env.ALLOWED_ORIGINS?.split(',') ?? []),
        ...(process.env.MOBILE_APP_SCHEME
        ? [process.env.MOBILE_APP_SCHEME]
        : []),
      ],
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    credentials: true,
    allowedHeaders: ['Content-Type', 'Authorization'],
  }))
  .use(openapi({
    path: '/docs',
    specPath: '/docs/json',
    provider: 'scalar',
    documentation: {
      info: {
        title: 'Innovation Lab API',
        version: '1.0.0',
        description: 'Backend API for shuttle, mess, faculty and search modules.',
      },
      tags: [
        { name: 'Auth' },
        { name: 'Faculty' },
        { name: 'Mess' },
        { name: 'Shuttles' },
        { name: 'Competitions' },
        { name: 'Search' },
      ],
    },
  }))
  .group('/api', (api) =>
    api
      // Authentication routes (login, register, etc.) that don't require authentication
      .use(authController)

      // Versioned API routes
      .group('/v1', (v1) =>
        v1
        .get('/', () => ({
          success: true,
          message: 'Innovation Lab API is healthy',
        }))
        .use(facultyController)
        .use(messController)
        .use(shuttleController)
        .use(competitionController)
        .use(searchController),
  ))
  .listen({
    port,
    hostname: '0.0.0.0',
  });

console.log(`Innovation Lab API running at http://${app.server?.hostname}:${app.server?.port}`);