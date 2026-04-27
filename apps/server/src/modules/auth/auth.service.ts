import { auth } from ".";

export class AuthService {
  async getSession(headers: Headers) {
    return auth.api.getSession({ headers });
  }
}

export const authService = new AuthService();
