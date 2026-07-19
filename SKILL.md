---
name: threads-manager
description: Use when the user wants to manage, post, reply, search, or get insights from Threads.com (Meta). Covers creating posts, replying, hiding replies, getting insights, searching by keyword, viewing mentions. Trigger on keywords like threads, thread, post, reply, mention, insight.
---

# Threads Manager

Manage a Threads.com account via the Meta Graph API.

## Setup

1. Get access token from [Graph API Explorer](https://developers.facebook.com/tools/explorer/)
2. Set env vars in `threads-skill/.env`:
   ```
   THREADS_ACCESS_TOKEN=your_token
   THREADS_USER_ID=your_user_id
   ```

If the user doesn't have a token or .env, guide them through:
1. Create a Meta app at developers.facebook.com
2. Add Threads use case to the app
3. Generate token in Graph API Explorer with threads_basic + threads_content_publish scopes
4. Get user ID: `curl -s "https://graph.threads.net/v1.0/me?fields=id,username&access_token=TOKEN"`
5. Copy `.env.example` to `.env` and fill in values

See `threads-skill/README.md` for full step-by-step instructions.

## CLI usage

All commands via `threads-skill/scripts/threads.sh`:

```bash
./scripts/threads.sh profile                    # Get profile
./scripts/threads.sh posts 10                   # List posts
./scripts/threads.sh thread <id>                # Get single post
./scripts/threads.sh create "Hello!"            # Create text post
./scripts/threads.sh create "Hi" "" everyone    # With reply control
./scripts/threads.sh replies <id>               # Get replies
./scripts/threads.sh reply <id> "Nice!"         # Reply to post
./scripts/threads.sh insights <id>              # Get insights
./scripts/threads.sh mentions 10                # Get mentions
./scripts/threads.sh search "keyword" 10        # Search posts
./scripts/threads.sh hide <reply_id>            # Hide reply
./scripts/threads.sh unhide <reply_id>          # Unhide reply
```

## API reference

Base URL: `https://graph.threads.net/v1.0`

### Create post (two-step)

```bash
# Step 1: Create container
CONTAINER=$(curl -s -X POST \
  "https://graph.threads.net/v1.0/$THREADS_USER_ID/threads?media_type=TEXT&text=Hello&access_token=$THREADS_ACCESS_TOKEN")
CID=$(echo $CONTAINER | python3 -c "import sys,json;print(json.load(sys.stdin)['id'])")

# Step 2: Publish
sleep 2
curl -s -X POST \
  "https://graph.threads.net/v1.0/$THREADS_USER_ID/threads_publish?creation_id=$CID&access_token=$THREADS_ACCESS_TOKEN"
```

### Insights metrics

Valid: `views`, `likes`, `replies`, `reposts`, `quotes`, `clicks`, `shares`

**Do NOT use** `impressions` or `reach` — invalid for Threads.

### Reply control

Options: `everyone`, `accounts_you_follow`, `mentioned_only`, `parent_post_author_only`, `followers_only`

### Hide/unhide reply

```bash
curl -X POST -F "hide=true" -F "access_token=TOKEN" \
  "https://graph.threads.net/v1.0/{REPLY_ID}/manage_reply"
```

## Permissions

| Scope | Required for |
|-------|-------------|
| `threads_basic` | All endpoints |
| `threads_content_publish` | Creating posts |
| `threads_manage_insights` | Insights |
| `threads_manage_replies` | Hide/unhide replies |
| `threads_manage_mentions` | Mentions (needs advanced access for non-testers) |
| `threads_keyword_search` | Search (needs advanced access for public posts) |

## Limits

- 250 posts per 24h per user
- 2,200 search queries per 24h per user
- Text posts: 500 chars max
- Token expires: 1h (short), 60 days (long)

## Not supported by API

- Editing posts
- Deleting posts
