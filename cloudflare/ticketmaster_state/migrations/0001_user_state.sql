CREATE TABLE IF NOT EXISTS user_state (
  uid TEXT PRIMARY KEY NOT NULL,
  edited_texts_json TEXT NOT NULL DEFAULT '{}',
  tickets_json TEXT NOT NULL DEFAULT '[]',
  updated_at INTEGER NOT NULL
);
