---
name: threads-manager
description: Use when the user wants to manage, post, reply, search, or get insights from Threads.com (Meta). Covers creating posts, replying, hiding replies, getting insights, searching by keyword, viewing mentions. Trigger on keywords like threads, thread, post, reply, mention, insight.
---

# Threads Manager

Manage a Threads.com account via the Meta Graph API.

## Setup

**Never paste your access token to the agent.** Run setup directly in your terminal:

```bash
cd threads-skill
./scripts/setup.sh
```

The script will:
1. Show step-by-step instructions to get a token from Graph API Explorer
2. Ask you to paste the token (only in your terminal, not in chat)
3. Validate the token against the API
4. Auto-detect your user ID
5. Write `.env` with secure permissions (600)

If `.env` already exists and is valid, the script will confirm and skip reconfiguration.

See `threads-skill/README.md` for manual setup instructions.

## CLI Usage

All commands via `threads-skill/scripts/threads.sh`:

```bash
./scripts/threads.sh profile                    # Get profile
./scripts/threads.sh token                      # Check token status
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

## API Reference

Base URL: `https://graph.threads.net/v1.0`

### Create Post (Two-Step)

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

### Hide/Unhide Reply

```bash
curl -X POST -F "hide=true" -F "access_token=TOKEN" \
  "https://graph.threads.net/v1.0/{REPLY_ID}/manage_reply"
```

## Permissions

| Scope | Required for |
|-------|-------------|
| `threads_basic` | All endpoints (required) |
| `threads_content_publish` | Creating posts |
| `threads_manage_insights` | Insights |
| `threads_manage_replies` | Hide/unhide replies |
| `threads_manage_mentions` | Mentions (needs advanced access) |
| `threads_keyword_search` | Search (needs advanced access) |

## Rate Limits

- 250 posts per 24h per user
- 2,200 search queries per 24h per user
- Text posts: 500 chars max
- Token expires: 1h (short), 60 days (long)

## Insights Metrics

Valid: `views`, `likes`, `replies`, `reposts`, `quotes`, `clicks`, `shares`

**Do NOT use** `impressions` or `reach` — invalid for Threads.

## Reply Control

Options: `everyone`, `accounts_you_follow`, `mentioned_only`, `parent_post_author_only`, `followers_only`

## API Limitations

The Threads API does not support:
- Editing posts
- Deleting posts

## License

MIT
