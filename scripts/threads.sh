#!/bin/bash
# Load .env from same directory as script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"

if [ -f "$ENV_FILE" ]; then
  set -a && source "$ENV_FILE" && set +a
else
  echo "❌ .env not found at $ENV_FILE"
  exit 1
fi

BASE="https://graph.threads.net/v1.0"
ACTION="${1:-help}"
shift 2>/dev/null

# URL-encode text, interpreting \n and \r\n as real newlines
urlencode_text() {
  python3 -c "
import sys, urllib.parse
t = sys.argv[1].replace(r'\r\n', '\n').replace(r'\n', '\n')
print(urllib.parse.quote(t, safe=''))
" "$1"
}

# Validate token before any action
if [ "$ACTION" != "help" ] && [ "$ACTION" != "setup" ]; then
  if [ -z "$THREADS_ACCESS_TOKEN" ] || [ "$THREADS_ACCESS_TOKEN" = "your_token_here" ]; then
    echo "❌ No access token configured."
    echo ""
    echo "Run setup first:"
    echo "  ./scripts/setup.sh"
    exit 1
  fi
  if [ -z "$THREADS_USER_ID" ] || [ "$THREADS_USER_ID" = "your_user_id_here" ]; then
    echo "❌ No user ID configured."
    echo ""
    echo "Run setup first:"
    echo "  ./scripts/setup.sh"
    exit 1
  fi
  # Validate token is still working
  VALIDATION=$(curl -s "https://graph.threads.net/v1.0/me?fields=id&access_token=$THREADS_ACCESS_TOKEN" 2>&1)
  if echo "$VALIDATION" | grep -q '"error"'; then
    echo "❌ Token is invalid or expired."
    echo ""
    echo "Run setup to get a new token:"
    echo "  ./scripts/setup.sh"
    exit 1
  fi
fi

case "$ACTION" in
  profile)
    curl -s "$BASE/$THREADS_USER_ID?fields=id,username,name,threads_profile_picture_url,threads_biography&access_token=$THREADS_ACCESS_TOKEN" | python3 -m json.tool
    ;;
  posts)
    LIMIT="${1:-10}"
    curl -s "$BASE/$THREADS_USER_ID/threads?fields=id,text,username,timestamp,media_type,permalink&limit=$LIMIT&access_token=$THREADS_ACCESS_TOKEN" | python3 -m json.tool
    ;;
  thread)
    [ -z "$1" ] && echo "Usage: $0 thread <thread_id>" && exit 1
    curl -s "$BASE/$1?fields=id,text,username,timestamp,media_type,permalink&access_token=$THREADS_ACCESS_TOKEN" | python3 -m json.tool
    ;;
  create)
    [ -z "$1" ] && echo "Usage: $0 create <text> [image_url] [reply_control]" && exit 1
    TEXT="$1"
    IMAGE="${2:-}"
    RC="${3:-everyone}"
    ENCODED=$(urlencode_text "$TEXT")
    PARAMS="media_type=TEXT&text=$ENCODED&reply_control=$RC"
    [ -n "$IMAGE" ] && PARAMS="media_type=IMAGE&image_url=$IMAGE&text=$ENCODED&reply_control=$RC"
    CONTAINER=$(curl -s -X POST "$BASE/$THREADS_USER_ID/threads?$PARAMS&access_token=$THREADS_ACCESS_TOKEN")
    CID=$(echo "$CONTAINER" | python3 -c "import sys,json;print(json.load(sys.stdin).get('id',''))")
    [ -z "$CID" ] && echo "$CONTAINER" | python3 -m json.tool && exit 1
    echo "📦 Container: $CID"
    sleep 2
    curl -s -X POST "$BASE/$THREADS_USER_ID/threads_publish?creation_id=$CID&access_token=$THREADS_ACCESS_TOKEN" | python3 -m json.tool
    ;;
  replies)
    [ -z "$1" ] && echo "Usage: $0 replies <thread_id>" && exit 1
    curl -s "$BASE/$1/replies?fields=id,text,username,timestamp&access_token=$THREADS_ACCESS_TOKEN" | python3 -m json.tool
    ;;
  reply)
    [ -z "$1" ] || [ -z "$2" ] && echo "Usage: $0 reply <thread_id> <text>" && exit 1
    TEXT="$2"
    ENCODED=$(urlencode_text "$TEXT")
    PARAMS="media_type=TEXT&reply_to_id=$1&text=$ENCODED"
    CONTAINER=$(curl -s -X POST "$BASE/$THREADS_USER_ID/threads?$PARAMS&access_token=$THREADS_ACCESS_TOKEN")
    CID=$(echo "$CONTAINER" | python3 -c "import sys,json;print(json.load(sys.stdin).get('id',''))")
    [ -z "$CID" ] && echo "$CONTAINER" | python3 -m json.tool && exit 1
    sleep 2
    curl -s -X POST "$BASE/$THREADS_USER_ID/threads_publish?creation_id=$CID&access_token=$THREADS_ACCESS_TOKEN" | python3 -m json.tool
    ;;
  insights)
    [ -z "$1" ] && echo "Usage: $0 insights <thread_id> [metrics]" && exit 1
    METRICS="${2:-views,likes,replies,reposts,quotes}"
    curl -s "$BASE/$1/insights?metric=$METRICS&access_token=$THREADS_ACCESS_TOKEN" | python3 -m json.tool
    ;;
  mentions)
    LIMIT="${1:-10}"
    curl -s "$BASE/$THREADS_USER_ID/mentions?fields=id,text,username,timestamp&limit=$LIMIT&access_token=$THREADS_ACCESS_TOKEN" | python3 -m json.tool
    ;;
  search)
    [ -z "$1" ] && echo "Usage: $0 search <query> [limit]" && exit 1
    LIMIT="${2:-10}"
    ENCODED=$(urlencode_text "$1")
    curl -s "$BASE/keyword_search?q=$ENCODED&fields=id,text,username,timestamp&limit=$LIMIT&access_token=$THREADS_ACCESS_TOKEN" | python3 -m json.tool
    ;;
  hide)
    [ -z "$1" ] && echo "Usage: $0 hide <reply_id>" && exit 1
    curl -s -X POST "$BASE/$1/manage_reply" -F "hide=true" -F "access_token=$THREADS_ACCESS_TOKEN" | python3 -m json.tool
    ;;
  unhide)
    [ -z "$1" ] && echo "Usage: $0 unhide <reply_id>" && exit 1
    curl -s -X POST "$BASE/$1/manage_reply" -F "hide=false" -F "access_token=$THREADS_ACCESS_TOKEN" | python3 -m json.tool
    ;;
  setup)
    exec "$(dirname "$0")/setup.sh"
    ;;
  help|*)
    echo "Threads API CLI"
    echo ""
    echo "Usage: $0 <command> [args]"
    echo ""
    echo "Commands:"
    echo "  setup                      Interactive setup wizard"
    echo "  profile                    Get profile info"
    echo "  posts [limit]              List your posts"
    echo "  thread <id>                Get a specific post"
    echo "  create <text> [img] [rc]   Create a post (rc=reply_control)"
  echo "                             Use \\n for newlines in text"
    echo "  replies <id>               Get replies to a post"
    echo "  reply <id> <text>          Reply to a post"
    echo "  insights <id> [metrics]    Get post insights"
    echo "  mentions [limit]           Get mentions"
    echo "  search <query> [limit]     Search posts by keyword"
    echo "  hide <reply_id>            Hide a reply"
    echo "  unhide <reply_id>          Unhide a reply"
    ;;
esac
