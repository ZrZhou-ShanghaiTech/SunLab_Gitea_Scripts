#!/usr/bin/env bash

SSH_HOST="10.15.49.221"
SSH_PORT="22"

WEB_PORT="3000"
GIT_PORT="2222"

GITEA_URL="http://127.0.0.1:${WEB_PORT}/"

echo "======================================"
echo "          Lab Git Launcher"
echo "======================================"
echo

# --------------------------------------------------
# 1. 检查依赖
# --------------------------------------------------

if ! command -v ssh >/dev/null 2>&1; then
    echo "Error: ssh command not found."
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl command not found."
    exit 1
fi

# --------------------------------------------------
# 2. 如果 Gitea 已经可访问，直接打开
# --------------------------------------------------

HTTP_CODE=$(curl \
    --silent \
    --output /dev/null \
    --write-out "%{http_code}" \
    --max-time 2 \
    "$GITEA_URL")

case "$HTTP_CODE" in
    200|301|302|303|307|308)
        echo "Lab Gitea is already connected."
        echo "Opening: $GITEA_URL"

        if command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$GITEA_URL" >/dev/null 2>&1 &
        else
            echo
            echo "Please open manually:"
            echo "$GITEA_URL"
        fi

        exit 0
        ;;
esac

# --------------------------------------------------
# 3. 检查本地端口占用
# --------------------------------------------------

if command -v ss >/dev/null 2>&1; then
    if ss -ltn | grep -q ":${WEB_PORT} "; then
        echo "Error: local port ${WEB_PORT} is already in use."
        echo "Run:"
        echo "  ss -ltnp | grep :${WEB_PORT}"
        exit 1
    fi

    if ss -ltn | grep -q ":${GIT_PORT} "; then
        echo "Error: local port ${GIT_PORT} is already in use."
        echo "Run:"
        echo "  ss -ltnp | grep :${GIT_PORT}"
        exit 1
    fi
else
    echo "Warning: ss command not found. Skipping port check."
fi

# --------------------------------------------------
# 4. 输入 SSH 用户名
# --------------------------------------------------

read -r -p "SSH username: " SSH_USER

if [ -z "$SSH_USER" ]; then
    echo "Error: SSH username cannot be empty."
    exit 1
fi

echo
echo "Connecting to Lab Gitea..."
echo "Please enter your SSH password if prompted."
echo

# --------------------------------------------------
# 5. 建立 SSH Tunnel
# --------------------------------------------------

ssh -fN \
    -p "$SSH_PORT" \
    -L 127.0.0.1:${WEB_PORT}:127.0.0.1:3000 \
    -L 127.0.0.1:${GIT_PORT}:127.0.0.1:2222 \
    -o ExitOnForwardFailure=yes \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    "${SSH_USER}@${SSH_HOST}"

SSH_RESULT=$?

if [ "$SSH_RESULT" -ne 0 ]; then
    echo
    echo "Failed to establish SSH tunnel."
    exit 1
fi

# --------------------------------------------------
# 6. 等待 Gitea 可访问
# --------------------------------------------------

echo
echo "Waiting for Gitea..."

for i in $(seq 1 10); do

    HTTP_CODE=$(curl \
        --silent \
        --output /dev/null \
        --write-out "%{http_code}" \
        --max-time 2 \
        "$GITEA_URL")

    case "$HTTP_CODE" in
        200|301|302|303|307|308)
            echo
            echo "Connected to Lab Gitea."
            echo
            echo "Web:"
            echo "  $GITEA_URL"
            echo
            echo "Git SSH:"
            echo "  ssh://git@127.0.0.1:${GIT_PORT}/"
            echo

            if command -v xdg-open >/dev/null 2>&1; then
                xdg-open "$GITEA_URL" >/dev/null 2>&1 &
            else
                echo "Please open manually:"
                echo "$GITEA_URL"
            fi

            exit 0
            ;;
    esac

    sleep 1
done

echo
echo "SSH tunnel was created, but Gitea did not respond."
echo "Please check:"
echo "  curl http://127.0.0.1:${WEB_PORT}"
exit 1