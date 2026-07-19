# Threads Skill

A standalone CLI tool for managing Threads.com posts via the Meta Graph API.

## Setup

### 1. Get a Threads Access Token

1. Go to [Meta Developers](https://developers.facebook.com/) and log in
2. Click **My Apps** → **Create App**
3. Choose **Business** type → fill in app name → **Create App**
4. In the left sidebar, click **Add Use Case** → select **Threads** → **Add**
5. Go to [Graph API Explorer](https://developers.facebook.com/tools/explorer/)
6. In the dropdown, select your newly created app
7. Click **Generate Access Token**
8. Check these permissions:
   - `threads_basic`
   - `threads_content_publish`
   - `threads_manage_insights`
   - `threads_manage_replies`
   - `threads_read_replies`
   - `threads_manage_mentions`
   - `threads_keyword_search`
9. Click **Generate Access Token** → authorize with your Threads account
10. Copy the generated token

### 2. Get your User ID

Run this with your token (replace `YOUR_TOKEN`):

```bash
curl -s "https://graph.threads.net/v1.0/me?fields=id,username&access_token=YOUR_TOKEN"
```

Response:
```json
{
  "id": "17841463932479189",
  "username": "your_username"
}
```

Copy the `id` value.

### 3. Configure

```bash
cp .env.example .env
```

Edit `.env` and fill in your values:

```
THREADS_ACCESS_TOKEN=EAADd...
THREADS_USER_ID=17841463932479189
```

### 4. Run

```bash
chmod +x scripts/threads.sh
./scripts/threads.sh profile
```

## Commands

| Command | Description |
|---------|-------------|
| `profile` | Get your profile info |
| `posts [limit]` | List your posts |
| `thread <id>` | Get a specific post |
| `create <text>` | Create a text post |
| `create <text> <img_url>` | Create an image post |
| `replies <id>` | Get replies to a post |
| `reply <id> <text>` | Reply to a post |
| `insights <id>` | Get post insights |
| `mentions [limit]` | Get mentions |
| `search <query>` | Search posts by keyword |
| `hide <reply_id>` | Hide a reply |
| `unhide <reply_id>` | Unhide a reply |

## Token expired?

Tokens expire after 1 hour (short-lived) or 60 days (long-lived).

To refresh:
1. Go back to [Graph API Explorer](https://developers.facebook.com/tools/explorer/)
2. Select your app
3. Generate a new token
4. Update your `.env`
