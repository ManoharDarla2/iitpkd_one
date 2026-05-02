import {cors as corsPlugin} from "@elysiajs/cors";
import { openapi as openaiPlugin } from '@elysiajs/openapi';
import Elysia from "elysia";
import { OpenAPI } from "./modules/auth/openapi";



export const cors = new Elysia({ name: "cors" }).use(
  corsPlugin({
    origin: (request) => {
      const origin = request.headers.get("origin");
            if (!origin) return true;

      if (process.env.NODE_ENV !== "production") {
        if (
          origin.startsWith("exp://") ||
          origin.startsWith("http://localhost") ||
          origin.startsWith("http://127.0.0.1") ||
          /^http:\/\/192\.168\.\d+\.\d+/.test(origin) ||
          /^http:\/\/10\.\d+\.\d+\.\d+/.test(origin)
        ) {
          return true;
        }
      }

            if (process.env.ALLOWED_ORIGINS) {
                const allowedOrigins = process.env.ALLOWED_ORIGINS.split(",").map((o) => o.trim());
                if (allowedOrigins.includes(origin)) {
                    return true;
                }
            }

            if (process.env.MOBILE_APP_SCHEME) {
                const mobileAppScheme = process.env.MOBILE_APP_SCHEME.trim();
                if (origin.startsWith(mobileAppScheme)) {
                    return true;
                }
            }

      return false;
    },
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    credentials: true,
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
);

export const openapi = new Elysia({ name: "openapi" }).use(
  openaiPlugin({
    path: '/docs',
    specPath: '/docs/json',
    provider: 'scalar',
    documentation: {
        info: {
        title: 'Innovation Lab API',
        version: '1.0.0',
        description: 'Backend API for shuttle, mess, faculty and search modules.',
        },
        components: await OpenAPI.components,
        paths: await OpenAPI.getPaths()
    },
}))
