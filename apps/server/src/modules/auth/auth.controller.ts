import { Elysia } from 'elysia';
import { auth } from './index';

export const authController = new Elysia({
  name: "module.auth.controller",
  prefix: "/auth",
  tags: ["Auth"],
}).all("/*", ({ request }) => auth.handler(request), {
  detail: {
    summary: "Handle Better Auth routes",
    description: "Proxy all Better Auth handlers",
  },
});