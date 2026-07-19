# Threads Management Skills

A lightweight CLI tool for managing your Threads.com account via the [Meta Graph API](https://developers.facebook.com/docs/threads).

## Features

- **Profile** — View your account info
- **Posts** — List, get, and create posts (text & image)
- **Replies** — Read and send replies
- **Insights** — Engagement metrics (views, likes, reposts, etc.)
- **Mentions** — Posts where you're tagged
- **Search** — Keyword search across public posts
- **Moderation** — Hide/unhide replies

## Quick Start

```bash
# Clone
git clone https://github.com/mrhustlex/Threads-Management-skills.git
cd Threads-Management-skills

# Configure
cp .env.example .env
# Edit .env with your token and user ID (see setup guide below)

# Run
./scripts/threads.sh profile
```

## Setup Guide

### Step 1 — Create a Meta App

1. Go to [developers.facebook.com](https://developers.facebook.com/) → **My Apps** → **Create App**
2. Select **Business** → name your app → **Create App**
3. In the sidebar, click **Add Use Case** → select **Threads** → **Add**

### Step 2 — Generate an Access Token

1. Open [Graph API Explorer](https://developers.facebook.com/tools/explorer/)
2. Select your app from the dropdown
3. Click **Generate Access Token**
4. Check all permissions:
   - `threads_basic`
   - `threads_content_publish`
   - `threads_manage_insights`
   - `threads_manage_replies`
   - `threads_read_replies`
   - `threads_manage_mentions`
   - `threads_keyword_search`
5. Authorize with your Threads account
6. Copy the token

### Step 3 — Get Your User ID

```bash
curl -s "https://graph.threads.net/v1.0/me?fields=id,username&access_token=YOUR_TOKEN"
```

```json
{ "id": "17841463932479189", "username": "your_username" }
```

Copy the `id` value.

### Step 4 — Configure `.env`

```bash
cp .env.example .env
```

```env
THREADS_ACCESS_TOKEN=EAADd...
THREADS_USER_ID=17841463932479189
```

## Commands

```
./scripts/threads.sh <command> [args]
```

| Command | Example | Description |
|---------|---------|-------------|
| `profile` | `./scripts/threads.sh profile` | View your profile |
| `posts` | `./scripts/threads.sh posts 5` | List posts (default: 10) |
| `thread` | `./scripts/threads.sh thread <id>` | Get a specific post |
| `create` | `./scripts/threads.sh create "Hello!"` | Create a text post |
| `create` | `./scripts/threads.sh create "Hi" "https://img.jpg"` | Create an image post |
| `replies` | `./scripts/threads.sh replies <id>` | Get replies to a post |
| `reply` | `./scripts/threads.sh reply <id> "Nice!"` | Reply to a post |
| `insights` | `./scripts/threads.sh insights <id>` | Get engagement metrics |
| `mentions` | `./scripts/threads.sh mentions` | Get posts mentioning you |
| `search` | `./scripts/threads.sh search "AI"` | Search by keyword |
| `hide` | `./scripts/threads.sh hide <reply_id>` | Hide a reply |
| `unhide` | `./scripts/threads.sh unhide <reply_id>` | Unhide a reply |

## Insights Metrics

Valid metrics for the `insights` command:

`views` · `likes` · `replies` · `reposts` · `quotes` · `clicks` · `shares`

> **Note:** `impressions` and `reach` are **not valid** for Threads.

## Reply Control

When creating posts, you can set who can reply:

| Value | Who can reply |
|-------|---------------|
| `everyone` | Anyone (default) |
| `accounts_you_follow` | People you follow |
| `mentioned_only` | People you @mentioned |
| `parent_post_author_only` | Author of the parent post |
| `followers_only` | Your followers |

## Permissions

| Scope | What it unlocks |
|-------|----------------|
| `threads_basic` | All endpoints (required) |
| `threads_content_publish` | Creating & publishing posts |
| `threads_manage_insights` | Reading insights |
| `threads_manage_replies` | Hide/unhide replies |
| `threads_read_replies` | Reading reply data |
| `threads_manage_mentions` | Mention endpoint |
| `threads_keyword_search` | Keyword search |

> **Note:** Mentions and search require [App Review](https://developers.facebook.com/docs/resp-protocol/app-review) approval for non-tester users.

## Rate Limits

| Limit | Count |
|-------|-------|
| Posts per 24h | 250 |
| Search queries per 24h | 2,200 |
| Max post length | 500 characters |
| Short-lived token | 1 hour |
| Long-lived token | 60 days |

## Token Expired?

1. Go to [Graph API Explorer](https://developers.facebook.com/tools/explorer/)
2. Select your app
3. Generate a new token
4. Update your `.env`

## Not Supported by API

- Editing posts
- Deleting posts

## License

MIT
