import { Elysia } from 'elysia';
import { auth as authService } from './auth';
import { ErrorEnvelope } from '../../common/http';

export const authController = new Elysia({
  name: "auth",
  prefix: "/auth",
  tags: ["Auth"],
}).all("/*", async ({ request }) => {
    const response = await authService.handler(request);
    return response;
})
  .macro({
        auth: {
            async resolve({ status, request: { headers } }) {
                const session = await authService.api.getSession({
                    headers
                })
                if (!session) return status(401, ErrorEnvelope('Unauthorized Access'));
                return {
                    user: session.user,
                    session: session.session
                }
            }
        }
    })