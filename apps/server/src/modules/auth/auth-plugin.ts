import { Elysia } from 'elysia';
import { auth } from './auth';
import { ErrorEnvelope } from '../../common/http';

export const authPlugin = new Elysia({ name: 'auth-plugin' })
  .macro({
    auth: {
      async resolve({ status, request: { headers } }) {
        const session = await auth.api.getSession({ headers });
        if (!session) return status(401, ErrorEnvelope('Unauthorized Access'));
        return {
          user: session.user,
          session: session.session,
        };
      },
    },
  });
