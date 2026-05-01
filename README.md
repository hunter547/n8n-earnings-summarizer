# NQ Earnings & Macro Digest

Twice-daily Telegram digest for Nasdaq-100 futures bias: 9:15 AM ET (pre-market) and 5:45 PM ET (post-close), Mon–Fri.

Pulls from Finnhub (earnings + news), SEC EDGAR (8-K filings for top-10 NQ constituents), FRED (Fed/macro), TreasuryDirect (auctions), EIA (petroleum inventories), MarketAux (news), and Yahoo Finance (VIX, VVIX, DXY, 10Y, NQ, ES). Summarizes with Claude Sonnet 4.6 and pushes to Telegram.

## 1. Get API keys

All free tiers — no card required for any of these:

| Service | Where | Why |
|---|---|---|
| Finnhub | https://finnhub.io/register | Earnings calendar + general news |
| FRED | https://fred.stlouisfed.org/docs/api/api_key.html | Fed/CPI/PCE/jobs series |
| EIA | https://www.eia.gov/opendata/register.php | Weekly petroleum status |
| MarketAux | https://www.marketaux.com/account/dashboard | US news with entity tagging |
| Anthropic | https://console.anthropic.com/settings/keys | Claude summarization (paid, ~pennies/run) |

## 2. Set up Telegram

1. DM `@BotFather` on Telegram, send `/newbot`, follow prompts. Copy the bot token.
2. Send any message to your new bot (so it can DM you).
3. Visit `https://api.telegram.org/bot<TOKEN>/getUpdates` and copy the `chat.id` value (it's an integer, may be negative).

## 3. Configure

```bash
cp .env.example .env
# Fill in all keys. Generate the encryption key:
openssl rand -hex 32
# Paste output as N8N_ENCRYPTION_KEY
```

## 4. Start

```bash
docker compose up -d
docker compose logs -f n8n
```

Open http://localhost:5678 and log in with the basic auth creds you set.

## 5. Import workflows

In the n8n UI:

1. Click **Workflows** → **Import from File**
2. Import `workflows/premarket.json`
3. Repeat for `workflows/postclose.json`

### Create the Postgres credential

Both workflows reference a credential named **Postgres (n8n DB)**. Create it once:

1. **Credentials** → **New** → **Postgres**
2. Name: `Postgres (n8n DB)`
3. Host: `postgres`, Port: `5432`, Database: `n8n` (or whatever you set in `.env`)
4. User/Password: match `.env`
5. Save

Then open each workflow, click the two Postgres nodes (`Load Seen IDs`, `Persist Seen`), and confirm the credential is selected.

### Activate

Toggle each workflow to **Active** (top-right). They'll fire on their cron.

## 6. Test before waiting for the cron

Open `NQ Pre-Market Digest`, click **Execute Workflow**. You should get a Telegram message within ~30s.

If it fails:
- **No items / empty digest** → check `Fetch All Sources` node output, likely a missing API key.
- **Postgres error** → credential not bound or DB not reachable.
- **Telegram 400** → MarkdownV2 escape issue, check `Format Telegram` output.
- **Claude error** → check `ANTHROPIC_API_KEY` and that the model ID `claude-sonnet-4-6` is current.

## Files

```
docker-compose.yml      # n8n + postgres
.env.example            # all secrets/keys
db/init-db.sql          # seen_items dedup table
workflows/
  premarket.json        # 9:15 ET digest
  postclose.json        # 17:45 ET digest
```

## Costs

- Infra: $0 (local Docker)
- All data sources: free tier
- Claude: ~$0.01–0.03 per run (Sonnet 4.6, ~3k input + ~1k output tokens). 2 runs/day × 21 trading days ≈ **<$2/month**.

## Tweaking

- **Tickers**: edit the `tickers` value in the `Config` node of each workflow.
- **Window**: `windowHours` in `Config` controls how far back items are pulled.
- **Cadence**: edit the cron expression in the Schedule node.
- **Prompt**: edit the `Build Prompt` Code node — the section structure and "BIAS READ" framing live there.
