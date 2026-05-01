CREATE TABLE IF NOT EXISTS seen_items (
    source       TEXT NOT NULL,
    external_id  TEXT NOT NULL,
    seen_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (source, external_id)
);

CREATE INDEX IF NOT EXISTS seen_items_seen_at_idx
    ON seen_items (seen_at);

-- Housekeeping: items older than 14 days are no longer useful for dedup
-- (run manually or via a scheduled n8n cleanup workflow if desired):
--   DELETE FROM seen_items WHERE seen_at < NOW() - INTERVAL '14 days';
