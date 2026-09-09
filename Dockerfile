FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/root

# Virtual display + window manager + browser + VNC + noVNC/websockify.
# NOTE: use Debian's "chromium" package, not Ubuntu's — Ubuntu's chromium-browser
# is a snap stub and does not work inside containers.
RUN apt-get update && apt-get install -y --no-install-recommends \
        xvfb \
        x11vnc \
        fluxbox \
        chromium \
        novnc \
        websockify \
        dbus-x11 \
        fonts-liberation \
        procps \
        ca-certificates \
        curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
COPY web/index.html /usr/share/novnc/index.html
RUN chmod +x /app/entrypoint.sh

# Render injects $PORT at runtime; 8080 is just the default for local runs.
EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]
