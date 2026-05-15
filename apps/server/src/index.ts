import { Elysia } from 'elysia';
// import { corsPlugin, openapiPlugin } from './plugins';
// import { apiRouter } from './modules';

export default new Elysia()
.get('/', () => {
    return {
        status: 'ok'
    }
})
// .use(corsPlugin)
// .use(openapiPlugin)
// .use(apiRouter);