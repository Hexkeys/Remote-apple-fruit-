FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive HOME=/root DISPLAY=:1

RUN apt-get update && apt-get install -y --no-install-recommends \
        xvfb x11vnc fluxbox xterm thunar dbus-x11 novnc websockify \
        fonts-dejavu procps ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
COPY web/index.html /usr/share/novnc/index.html
RUN chmod +x /app/entrypoint.sh
EXPOSE 8080
ENTRYPOINT ["/app/entrypoint.sh"]
