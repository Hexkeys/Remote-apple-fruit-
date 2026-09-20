#!/bin/bash
set -e
export DISPLAY=:1
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"
PORT="${PORT:-8080}"
RESOLUTION="${RESOLUTION:-1280x800x24}"
Xvfb "$DISPLAY" -screen 0 "$RESOLUTION" -nolisten tcp -ac &
XVFB_PID=$!
sleep 2
fluxbox >/tmp/fluxbox.log 2>&1 &
WM_PID=$!
sleep 1
VNC_ARGS=(-display "$DISPLAY" -forever -shared -rfbport 5900 -noxdamage -noxfixes -cursor arrow -quiet)
if [ -n "${VNC_PASSWORD:-}" ]; then
  mkdir -p /root/.vnc
  x11vnc -storepasswd "$VNC_PASSWORD" /root/.vnc/passwd
  VNC_ARGS+=(-rfbauth /root/.vnc/passwd)
else
  echo "WARNING: VNC_PASSWORD is not set."
  VNC_ARGS+=(-nopw)
fi
x11vnc "${VNC_ARGS[@]}" &
VNC_PID=$!
sleep 1
xterm -title "Remote Device Terminal" -geometry 100x30+20+20 &
XTERM_PID=$!
thunar --daemon >/tmp/thunar.log 2>&1 || true
websockify --web=/usr/share/novnc/ "$PORT" localhost:5900 &
NOVNC_PID=$!
cleanup(){ kill "$XTERM_PID" "$VNC_PID" "$WM_PID" "$XVFB_PID" "$NOVNC_PID" 2>/dev/null || true; exit 0; }
trap cleanup SIGTERM SIGINT
while true; do
  if ! kill -0 "$XVFB_PID" 2>/dev/null || ! kill -0 "$VNC_PID" 2>/dev/null || ! kill -0 "$NOVNC_PID" 2>/dev/null; then cleanup; fi
  sleep 5
done
