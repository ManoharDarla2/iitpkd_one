import { Elysia } from 'elysia';
import { cors, openapi } from './plugins';
import { apiRouter } from './modules';

export const app = new Elysia()
.get('/', () => {
    return {
        status: 'ok'
    }
})
.use(cors)
.use(openapi)
.use(apiRouter);
