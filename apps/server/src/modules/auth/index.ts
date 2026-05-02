import { Elysia } from 'elysia';
import { auth as authService } from './auth';

export const authController = new Elysia({
  name: "auth",
  prefix: "/auth",
  tags: ["Auth"],
}).all("/*", ({ request }) => authService.handler(request));