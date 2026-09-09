#!/bin/bash
# Starts a virtual display + sandboxed Chromium + VNC, exposed to a normal
# web browser via noVNC on a single HTTP port ($PORT).
set -e

export DISPLAY=:1
PORT="${PORT:-8080}"
RESOLUTION="${RESOLUTION:-1280x800x24}"
START_URL="${START_URL:-https://www.google.com}"

echo "==> Starting virtual display $DISPLAY ($RESOLUTION)"
Xvfb "$DISPLAY" -screen 0 "$RESOLUTION" -nolisten tcp &
XVFB_PID=$!
sleep 2

echo "==> Starting window manager"
fluxbox >/dev/null 2>&1 &
sleep 1

echo "==> Starting VNC server"
VNC_ARGS=(-display "$DISPLAY" -forever -shared -rfbport 5900 -noxdamage -noxfixes -quiet)
if [ -n "$VNC_PASSWORD" ]; then
  mkdir -p /root/.vnc
  x11vnc -storepasswd "$VNC_PASSWORD" /root/.vnc/passwd
  VNC_ARGS+=(-rfbauth /root/.vnc/passwd)
else
  echo "!! WARNING: VNC_PASSWORD is not set. Anyone with this URL can use the browser."
  echo "!! Set VNC_PASSWORD as an environment variable before going live."
  VNC_ARGS+=(-nopw)
fi
x11vnc "${VNC_ARGS[@]}" &
VNC_PID=$!
sleep 1

start_chromium() {
  chromium \
    --no-sandbox \
    --disable-gpu \
    --disable-dev-shm-usage \
    --disable-software-rasterizer \
    --disable-translate \
    --no-first-run \
    --window-position=0,0 \
    --start-maximized \
    "$START_URL" \
    >/tmp/chromium.log 2>&1 &
  CHROME_PID=$!
}

echo "==> Launching sandboxed Chromium -> $START_URL"
start_chromium

echo "==> Starting noVNC web bridge on port $PORT"
websockify --web=/usr/share/novnc/ "$PORT" localhost:5900 &
NOVNC_PID=$!

cleanup() {
  echo "==> Shutting down"
  kill "$CHROME_PID" "$VNC_PID" "$XVFB_PID" "$NOVNC_PID" 2>/dev/null
  exit 0
}
trap cleanup SIGTERM SIGINT

# Keep the session alive; restart Chromium if the tab/renderer crashes.
while true; do
  if ! kill -0 "$CHROME_PID" 2>/dev/null; then
    echo "==> Chromium exited, restarting..."
    start_chromium
  fi
  if ! kill -0 "$XVFB_PID" 2>/dev/null || ! kill -0 "$NOVNC_PID" 2>/dev/null; then
    echo "==> Core service died, exiting"
    cleanup
  fi
  sleep 5
done
