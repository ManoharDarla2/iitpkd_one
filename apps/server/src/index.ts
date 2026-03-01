import { Elysia, t } from 'elysia'
import { openapi } from '@elysiajs/openapi'

const app = new Elysia()
  .use(openapi())
  .get('/', () => 'hello')
  .post('/json', ({ body }) => body, {
    body: t.Object({
      hello: t.String()
    })
  })
  .listen(3000)

console.log(
  `🦊 Elysia is running at http://${app.server?.hostname}:${app.server?.port}`
);
