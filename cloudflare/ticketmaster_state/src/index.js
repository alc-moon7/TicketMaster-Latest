import { createRemoteJWKSet, jwtVerify } from 'jose';

const firebaseJwks = createRemoteJWKSet(
  new URL(
    'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com',
  ),
);
const authorizationCache = new Map();
const authorizationCacheDurationMs = 5 * 60 * 1000;

const jsonHeaders = {
  'content-type': 'application/json; charset=utf-8',
  'cache-control': 'no-store',
  'access-control-allow-origin': '*',
  'access-control-allow-headers': 'authorization, content-type',
  'access-control-allow-methods': 'GET, PUT, OPTIONS',
};

const maxImageBytes = 10 * 1024 * 1024;
const maxStateBytes = 900 * 1024;

export default {
  async fetch(request, env) {
    try {
      if (request.method === 'OPTIONS') {
        return new Response(null, { status: 204, headers: jsonHeaders });
      }

      const url = new URL(request.url);
      if (request.method === 'GET' && url.pathname === '/health') {
        return json({ ok: true, storage: 'd1+r2' });
      }

      const authenticatedUser = await authenticate(request, env);
      if (!authenticatedUser) {
        return json({ error: 'Unauthorized' }, 401);
      }
      if (!(await isAuthorizedUser(authenticatedUser, env))) {
        return json({ error: 'Forbidden' }, 403);
      }
      const { uid } = authenticatedUser;

      if (url.pathname === '/v1/state' && request.method === 'GET') {
        return getState(env, uid);
      }
      if (url.pathname === '/v1/state/texts' && request.method === 'PUT') {
        return putTexts(request, env, uid);
      }
      if (url.pathname === '/v1/state/tickets' && request.method === 'PUT') {
        return putTickets(request, env, uid);
      }

      const imageMatch = url.pathname.match(
        /^\/v1\/state\/tickets\/(\d+)\/image$/,
      );
      if (imageMatch) {
        const ticketId = Number(imageMatch[1]);
        if (!Number.isSafeInteger(ticketId) || ticketId < 1) {
          return json({ error: 'Invalid ticket id' }, 400);
        }
        if (request.method === 'PUT') {
          return putImage(request, env, uid, ticketId);
        }
        if (request.method === 'GET') {
          return getImage(env, uid, ticketId);
        }
      }

      return json({ error: 'Not found' }, 404);
    } catch (error) {
      console.error(error);
      return json({ error: 'Internal server error' }, 500);
    }
  },
};

async function authenticate(request, env) {
  const authorization = request.headers.get('authorization') ?? '';
  if (!authorization.startsWith('Bearer ')) return null;
  const token = authorization.slice('Bearer '.length).trim();
  if (!token) return null;

  try {
    const issuer = `https://securetoken.google.com/${env.FIREBASE_PROJECT_ID}`;
    const { payload } = await jwtVerify(token, firebaseJwks, {
      issuer,
      audience: env.FIREBASE_PROJECT_ID,
      algorithms: ['RS256'],
    });
    if (
      typeof payload.sub !== 'string' ||
      payload.sub.length === 0 ||
      typeof payload.email !== 'string' ||
      payload.email.length === 0
    ) {
      return null;
    }
    return {
      uid: payload.sub,
      email: payload.email.trim().toLowerCase(),
      token,
    };
  } catch {
    return null;
  }
}

async function isAuthorizedUser(user, env) {
  const cached = authorizationCache.get(user.uid);
  if (cached && cached.expiresAt > Date.now()) {
    return cached.allowed;
  }

  let allowed = false;
  try {
    const documentUrl = new URL(
      `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/authorized_users/${encodeURIComponent(user.email)}`,
    );
    const response = await fetch(documentUrl, {
      headers: { authorization: `Bearer ${user.token}` },
    });
    if (response.ok) {
      const document = await response.json();
      allowed = document?.fields?.active?.booleanValue !== false;
    }
  } catch {
    allowed = false;
  }

  if (authorizationCache.size >= 1000) {
    authorizationCache.clear();
  }
  authorizationCache.set(user.uid, {
    allowed,
    expiresAt: Date.now() + authorizationCacheDurationMs,
  });
  return allowed;
}

async function getState(env, uid) {
  const row = await env.STATE_DB.prepare(
    `SELECT edited_texts_json, tickets_json, updated_at
       FROM user_state
      WHERE uid = ?1`,
  )
    .bind(uid)
    .first();

  if (!row) {
    return json({ exists: false, editedTexts: {}, tickets: [], updatedAt: null });
  }

  return json({
    exists: true,
    editedTexts: parseJson(row.edited_texts_json, {}),
    tickets: parseJson(row.tickets_json, []),
    updatedAt: row.updated_at,
  });
}

async function putTexts(request, env, uid) {
  const body = await readJson(request);
  const editedTexts = sanitizeEditedTexts(body?.editedTexts);
  if (!editedTexts) {
    return json({ error: 'Invalid edited text state' }, 400);
  }

  const serialized = JSON.stringify(editedTexts);
  if (serialized.length > maxStateBytes) {
    return json({ error: 'Edited text state is too large' }, 413);
  }

  const updatedAt = Date.now();
  await env.STATE_DB.prepare(
    `INSERT INTO user_state (uid, edited_texts_json, tickets_json, updated_at)
     VALUES (?1, ?2, '[]', ?3)
     ON CONFLICT(uid) DO UPDATE SET
       edited_texts_json = excluded.edited_texts_json,
       updated_at = excluded.updated_at`,
  )
    .bind(uid, serialized, updatedAt)
    .run();

  return json({ ok: true, updatedAt });
}

async function putTickets(request, env, uid) {
  const body = await readJson(request);
  const tickets = sanitizeTickets(body?.tickets);
  if (!tickets) {
    return json({ error: 'Invalid ticket state' }, 400);
  }

  const serialized = JSON.stringify(tickets);
  if (serialized.length > maxStateBytes) {
    return json({ error: 'Ticket state is too large' }, 413);
  }

  const previousRow = await env.STATE_DB.prepare(
    'SELECT tickets_json FROM user_state WHERE uid = ?1',
  )
    .bind(uid)
    .first();
  const previousTickets = parseJson(previousRow?.tickets_json, []);

  const updatedAt = Date.now();
  await env.STATE_DB.prepare(
    `INSERT INTO user_state (uid, edited_texts_json, tickets_json, updated_at)
     VALUES (?1, '{}', ?2, ?3)
     ON CONFLICT(uid) DO UPDATE SET
       tickets_json = excluded.tickets_json,
       updated_at = excluded.updated_at`,
  )
    .bind(uid, serialized, updatedAt)
    .run();

  const retainedImages = new Set(
    tickets.filter((ticket) => ticket.hasImage).map((ticket) => ticket.id),
  );
  const imageIdsToDelete = new Set(
    previousTickets
      .map((ticket) => Number(ticket?.id))
      .filter((id) => Number.isSafeInteger(id) && !retainedImages.has(id)),
  );
  for (const ticket of tickets) {
    if (!ticket.hasImage) imageIdsToDelete.add(ticket.id);
  }
  await Promise.all(
    [...imageIdsToDelete].map((id) => env.IMAGES.delete(imageKey(uid, id))),
  );

  return json({ ok: true, updatedAt });
}

async function putImage(request, env, uid, ticketId) {
  const declaredLength = Number(request.headers.get('content-length'));
  if (Number.isFinite(declaredLength) && declaredLength > maxImageBytes) {
    return json({ error: 'Image is too large' }, 413);
  }

  const bytes = await request.arrayBuffer();
  if (bytes.byteLength === 0 || bytes.byteLength > maxImageBytes) {
    return json({ error: 'Image is empty or too large' }, 413);
  }

  await env.IMAGES.put(imageKey(uid, ticketId), bytes, {
    httpMetadata: {
      contentType:
        request.headers.get('content-type') ?? 'application/octet-stream',
    },
  });
  return json({ ok: true, size: bytes.byteLength });
}

async function getImage(env, uid, ticketId) {
  const object = await env.IMAGES.get(imageKey(uid, ticketId));
  if (!object) {
    return json({ error: 'Image not found' }, 404);
  }

  return new Response(object.body, {
    headers: {
      'content-type':
        object.httpMetadata?.contentType ?? 'application/octet-stream',
      'content-length': object.size.toString(),
      'cache-control': 'private, no-store',
      'access-control-allow-origin': '*',
    },
  });
}

function sanitizeEditedTexts(value) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return null;
  const entries = Object.entries(value);
  if (entries.length > 2000) return null;

  const result = {};
  for (const [key, text] of entries) {
    if (
      typeof key !== 'string' ||
      key.length === 0 ||
      key.length > 500 ||
      typeof text !== 'string' ||
      text.length > 100000
    ) {
      return null;
    }
    result[key] = text;
  }
  return result;
}

function sanitizeTickets(value) {
  if (!Array.isArray(value) || value.length > 100) return null;
  const result = [];
  const ids = new Set();

  for (const raw of value) {
    if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return null;
    const id = Number(raw.id);
    const ticketCount = Number(raw.ticketCount);
    if (
      !Number.isSafeInteger(id) ||
      id < 1 ||
      ids.has(id) ||
      !Number.isSafeInteger(ticketCount) ||
      ticketCount < 1 ||
      ticketCount > 100
    ) {
      return null;
    }
    ids.add(id);

    const cropRect = sanitizeCropRect(raw.cropRect);
    const hasImage = raw.hasImage === true;
    if (hasImage && !cropRect) return null;

    result.push({
      id,
      displayTitle: limitedString(raw.displayTitle, 500),
      displayVenue: limitedString(raw.displayVenue, 500),
      displayDateLabel: limitedString(raw.displayDateLabel, 500),
      searchKeywords: limitedString(raw.searchKeywords, 2000),
      ticketCount,
      hasImage,
      imageWidth: hasImage ? positiveNumber(raw.imageWidth) : null,
      imageHeight: hasImage ? positiveNumber(raw.imageHeight) : null,
      cropRect: hasImage ? cropRect : null,
    });
  }
  return result;
}

function sanitizeCropRect(value) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return null;
  const left = normalizedNumber(value.left);
  const top = normalizedNumber(value.top);
  const width = normalizedNumber(value.width, false);
  const height = normalizedNumber(value.height, false);
  if (left === null || top === null || width === null || height === null) return null;
  if (left + width > 1.000001 || top + height > 1.000001) return null;
  return { left, top, width, height };
}

function normalizedNumber(value, allowZero = true) {
  const number = Number(value);
  if (!Number.isFinite(number) || number < 0 || number > 1) return null;
  if (!allowZero && number === 0) return null;
  return number;
}

function positiveNumber(value) {
  const number = Number(value);
  return Number.isFinite(number) && number > 0 ? number : 1;
}

function limitedString(value, maxLength) {
  return typeof value === 'string' ? value.slice(0, maxLength) : '';
}

async function readJson(request) {
  const text = await request.text();
  if (text.length > maxStateBytes) return null;
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function imageKey(uid, ticketId) {
  return `users/${uid}/tickets/${ticketId}.bin`;
}

function parseJson(value, fallback) {
  if (typeof value !== 'string') return fallback;
  try {
    return JSON.parse(value);
  } catch {
    return fallback;
  }
}

function json(value, status = 200) {
  return new Response(JSON.stringify(value), { status, headers: jsonHeaders });
}
