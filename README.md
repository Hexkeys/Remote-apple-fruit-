# Remote Apple Fruit — Remote Linux Device

This project is now a remote Linux device, not a remote browser.

A lightweight Linux desktop runs in Docker and is controlled from a normal web browser through noVNC.

## Architecture
- Linux desktop: Xvfb + Fluxbox
- Apps: Terminal (xterm) and File Manager (Thunar)
- Remote display/control: x11vnc + noVNC + WebSocket bridge
- Frontend: GitHub Pages launcher
- Backend: Docker-capable VPS or other host

GitHub Pages cannot run the Linux device itself; it only hosts the static launcher.

## Run locally

    docker compose up --build

Then open http://localhost:8080.

## Configuration
- PORT: HTTP/noVNC port, default 8080
- VNC_PASSWORD: password for the VNC session; set this before exposing the service
- RESOLUTION: virtual display size, default 1280x800x24

## Hosting
For a useful remote device, use a Docker-capable VPS with at least 2 GB RAM. More RAM/CPU allows more desktop applications and smoother operation.

## GitHub Pages
The docs/ folder contains a static launcher. Set REMOTE_DEVICE_URL in docs/index.html to the HTTPS URL of your device server, then deploy the Pages workflow.

Because GitHub Pages is HTTPS, the backend should also be HTTPS so the browser can establish a secure WebSocket connection.

## Security
Always set a strong VNC_PASSWORD. Do not expose an unauthenticated remote desktop to the public internet. For public deployment, use HTTPS and an authentication layer.
