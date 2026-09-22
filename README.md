# Remote Apple Fruit — Remote Device

This project provides a lightweight remote Linux desktop, not a remote browser.

A Linux desktop runs in Docker and is controlled from a normal web browser through noVNC.

## What you get

- A virtual Linux desktop
- Terminal through xterm
- File manager through Thunar
- Mouse and keyboard control
- Remote display through noVNC and WebSockets
- Docker-based deployment

## Architecture

- Linux display: Xvfb
- Window manager: Fluxbox
- Desktop apps: xterm and Thunar
- VNC server: x11vnc
- Web client: noVNC
- WebSocket bridge: websockify

## Run locally

    docker compose up --build

Then open:

    http://localhost:8080

Set a real VNC password before exposing the service publicly.

## Render

The included `render.yaml` deploys the Docker image as a web service.

Set the `VNC_PASSWORD` environment variable in Render to a strong password.

The free Render plan can sleep when idle, so reconnecting after inactivity can take some time.

## Configuration

- `PORT`: HTTP/noVNC port, default 8080
- `VNC_PASSWORD`: password for the VNC session
- `RESOLUTION`: virtual display size, default `1280x800x24`

## Important security note

The VNC session gives interactive access to the remote desktop. Use a strong password and HTTPS. Do not expose an unauthenticated VNC server to the public internet.

## GitHub Pages

The `docs/` folder can be used as a separate launcher page, but GitHub Pages cannot run the Linux desktop itself. The actual remote device must run on a Docker-capable host.

