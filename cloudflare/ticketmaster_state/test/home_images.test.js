import { before, after, test } from 'node:test';
import assert from 'node:assert/strict';
import { generateKeyPair, exportJWK, SignJWT } from 'jose';
import worker from '../src/index.js';

const originalFetch = globalThis.fetch;
const project = 'state-backup-test';
const objects = new Map();
const rows = new Map();
const env = {
  FIREBASE_PROJECT_ID: project,
  STATE_DB: {
    prepare(sql) {
      return {
        bind(...values) { this.values = values; return this; },
        async first() { return rows.get(this.values[0]); },
        async run() {
          const [uid, serialized, updatedAt] = this.values;
          const row = rows.get(uid) ?? { edited_texts_json: '{}', tickets_json: '[]' };
          const field = sql.includes('tickets_json = excluded.tickets_json')
            ? 'tickets_json' : 'edited_texts_json';
          row[field] = serialized;
          row.updated_at = updatedAt;
          rows.set(uid, row);
        },
      };
    },
  },
  IMAGES: {
    async put(key, bytes) { objects.set(key, bytes); },
    async get(key) {
      const body = objects.get(key);
      return body ? { body, size: body.byteLength, httpMetadata: {} } : null;
    },
    async delete(key) { objects.delete(key); },
  },
};
let privateKey;

before(async () => {
  const keys = await generateKeyPair('RS256');
  privateKey = keys.privateKey;
  const jwk = { ...await exportJWK(keys.publicKey), kid: 'test-key', alg: 'RS256' };
  globalThis.fetch = async (url) => {
    if (String(url).includes('/jwk/')) {
      return Response.json({ keys: [jwk] });
    }
    if (String(url).includes('/authorized_users/')) {
      return Response.json({ fields: { active: { booleanValue: true } } });
    }
    throw new Error('Unexpected external request');
  };
});
after(() => { globalThis.fetch = originalFetch; });

async function request(uid, method, key, body, path = `/v1/state/home/${key}/image`) {
  const token = await new SignJWT({ email: `${uid}@example.test` })
    .setProtectedHeader({ alg: 'RS256', kid: 'test-key' })
    .setIssuer(`https://securetoken.google.com/${project}`)
    .setAudience(project).setSubject(uid).setIssuedAt().setExpirationTime('5m')
    .sign(privateKey);
  return worker.fetch(new Request(`https://test${path}`, {
    method, body, headers: { authorization: `Bearer ${token}` },
  }), env);
}

test('Home artwork round-trips and is isolated by authenticated UID', async () => {
  const bytes = new Uint8Array([1, 5, 9, 13]);
  assert.equal((await request('user-a', 'PUT', 'cGFkZGVk=', bytes)).status, 200);
  const restored = await request('user-a', 'GET', 'cGFkZGVk=');
  assert.deepEqual(new Uint8Array(await restored.arrayBuffer()), bytes);
  assert.equal((await request('user-b', 'GET', 'cGFkZGVk=')).status, 404);
  assert.equal((await request('user-b', 'DELETE', 'cGFkZGVk=')).status, 200);
  assert.equal((await request('user-a', 'GET', 'cGFkZGVk=')).status, 200);
});

test('Reset is idempotent and invalid/empty uploads are rejected', async () => {
  assert.equal((await request('user-a', 'DELETE', 'cGFkZGVk=')).status, 200);
  assert.equal((await request('user-a', 'GET', 'cGFkZGVk=')).status, 404);
  assert.equal((await request('user-a', 'DELETE', 'cGFkZGVk=')).status, 200);
  assert.equal((await request('user-a', 'PUT', 'empty', new Uint8Array())).status, 413);
  assert.equal((await request('user-a', 'PUT', 'bad.key', new Uint8Array([1]))).status, 404);
});

test('Missing credentials cannot read or alter artwork', async () => {
  const response = await worker.fetch(
    new Request('https://test/v1/state/home/shared-key/image'), env);
  assert.equal(response.status, 401);
});


test('Card counts and quantities above 100 are preserved within state size limits', async () => {
  const tickets = Array.from({ length: 101 }, (_, index) => ({
    id: index + 1, ticketCount: 101, hasImage: false,
    displayTitle: 'Event', displayVenue: 'Venue', displayDateLabel: 'Date',
    searchKeywords: 'event',
  }));
  const saved = await request('count-user', 'PUT', '', JSON.stringify({ tickets }),
    '/v1/state/tickets');
  assert.equal(saved.status, 200);
  const restored = await request('count-user', 'GET', '', undefined, '/v1/state');
  const state = await restored.json();
  assert.equal(state.tickets.length, 101);
  assert.equal(state.tickets[100].ticketCount, 101);
});
