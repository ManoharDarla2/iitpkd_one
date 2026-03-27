import { t } from 'elysia';

export const SuccessEnvelope = <T>(data: T, message: string) => ({
  success: true,
  message,
  data,
});

export const ErrorEnvelope = (message: string) => ({
  success: false,
  message,
});

export const MetaSchema = t.Object({
  updatedAt: t.String(),
  version: t.String(),
});

export const toIso = (value: unknown): string | null => {
  if (value instanceof Date) {
    return value.toISOString();
  }

  if (typeof value === 'string') {
    const parsed = new Date(value);
    if (!Number.isNaN(parsed.getTime())) {
      return parsed.toISOString();
    }

    return value;
  }

  return null;
};
