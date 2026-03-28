import { Elysia } from 'elysia';
import { openapi } from '@elysiajs/openapi';

import { facultyController } from './modules/faculty/faculty.controller';
import { messController } from './modules/mess/mess.controller';
import { searchController } from './modules/search/search.controller';
import { shuttleController } from './modules/shuttle/shuttle.controller';

const app = new Elysia()
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
        { name: 'Faculty' },
        { name: 'Mess' },
        { name: 'Shuttles' },
        { name: 'Search' },
      ],
    },
  }))
  .group('/api/v1', (api) =>
    api
      .get('/', () => ({
        success: true,
        message: 'Innovation Lab API is healthy',
      }))
      .use(facultyController)
      .use(messController)
      .use(shuttleController)
      .use(searchController),
  )
  .listen(3000);

console.log(`Innovation Lab API running at http://${app.server?.hostname}:${app.server?.port}`);
