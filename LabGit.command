#!/bin/bash

SSH_HOST="10.15.49.221"
SSH_PORT="22112"

WEB_PORT="3000"
GIT_PORT="2222"

GITEA_URL="http://127.0.0.1:${WEB_PORT}/"

echo "======================================"
echo "          Lab Git Launcher"
echo "======================================"
echo

# --------------------------------------------------
# 1. 检查现有 Gitea tunnel 是否已经可用
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
        echo
        echo "Opening:"
        echo "$GITEA_URL"

        open "$GITEA_URL"
        exit 0
        ;;
esac


# --------------------------------------------------
# 2. Port check in
# --------------------------------------------------

if lsof -nP -iTCP:${WEB_PORT} -sTCP:LISTEN >/dev/null 2>&1; then
    echo "Error:"
    echo "Local port ${WEB_PORT} is already in use,"
    echo "but Gitea is not responding."
    echo
    echo "Run:"
    echo "lsof -nP -iTCP:${WEB_PORT} -sTCP:LISTEN"
    echo
    read -p "Press Enter to close..."
    exit 1
fi

if lsof -nP -iTCP:${GIT_PORT} -sTCP:LISTEN >/dev/null 2>&1; then
    echo "Error:"
    echo "Local port ${GIT_PORT} is already in use."
    echo
    echo "Run:"
    echo "lsof -nP -iTCP:${GIT_PORT} -sTCP:LISTEN"
    echo
    read -p "Press Enter to close..."
    exit 1
fi


# --------------------------------------------------
# 3. Input Username
# --------------------------------------------------

read -p "Subgpu SSH username: " SSH_USER

if [ -z "$SSH_USER" ]; then
    echo "SSH username cannot be empty."
    read -p "Press Enter to close..."
    exit 1
fi

echo
echo "Connecting to Lab Gitea..."
echo "Please enter your SSH password if prompted."
echo


# --------------------------------------------------
# 4. 建立 SSH tunnel
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

if [ $SSH_RESULT -ne 0 ]; then
    echo
    echo "Failed to establish SSH tunnel."
    read -p "Press Enter to close..."
    exit 1
fi


# --------------------------------------------------
# 5. 等待 Gitea 可访问
# --------------------------------------------------

echo
echo "Waiting for Gitea..."

for i in {1..10}; do

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

            open "$GITEA_URL"

            exit 0
            ;;
    esac

    sleep 1
done


echo
echo "SSH tunnel was created,"
echo "but Gitea did not respond."
echo
read -p "Press Enter to close..."
exit 1
