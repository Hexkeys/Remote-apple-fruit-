# Sandboxed Remote Browser (Render-ready)

A self-hosted "browser in the cloud": Chromium runs inside an isolated Docker
container, and you interact with it through your own browser via noVNC —
nothing the sites you visit do reaches your actual device. Useful for opening
untrusted links, testing suspicious URLs, or just keeping browsing off your
endpoint.

## How it works
- `Xvfb` creates a virtual display inside the container.
- `Chromium` renders into that virtual display.
- `x11vnc` shares the display over VNC.
- `websockify` + `noVNC` expose that VNC session as a plain web page, so no
  VNC client is needed — just a browser tab.

Everything is served on a single HTTP port, which is what Render (and most
PaaS platforms) expect from a web service.

## Deploy to Render
1. Push this folder to a new GitHub repo.
2. In Render: **New → Web Service** and connect the repo (it auto-detects the
   `Dockerfile`), or **New → Blueprint** to use the included `render.yaml`.
3. Set the `VNC_PASSWORD` environment variable to something strong. This is
   what protects the session — without it, anyone with your Render URL can
   use the browser.
4. Pick at least the **Starter** plan. Chromium plus a virtual display needs
   more RAM/CPU than the free tier's 512MB usually allows; on the free plan
   expect crash-looping.
5. Deploy. Once live, open the Render URL — it loads and auto-connects
   (prompting for your password if you set one).

## Configuration
All environment variables are optional except `VNC_PASSWORD`:

| Variable       | Purpose                                   | Default                    |
|----------------|--------------------------------------------|-----------------------------|
| `VNC_PASSWORD` | Protects the session — **set this**        | none (unprotected)          |
| `START_URL`    | Page Chromium opens on launch              | `https://www.google.com`    |
| `RESOLUTION`   | Virtual display size                       | `1280x800x24`                |

## Local testing
```bash
docker compose up --build
```
Then open http://localhost:8080.

## Security notes — read before exposing this publicly
- Chromium runs with `--no-sandbox` because container runtimes typically
  block the syscalls Chromium's own internal sandbox needs. The isolation
  here comes from the **container boundary**, not from Chromium — don't treat
  this as hardened against a determined attacker escaping the container.
- This is a single long-lived container: history, cookies, and downloads
  persist between visits until the service restarts. For real per-session
  isolation, redeploy/restart between uses, or extend this to spin up a
  fresh container per session.
- Always set `VNC_PASSWORD`. An open remote browser is effectively an open
  proxy — it can be abused to browse anonymously through your server.
- If you only need this for a known set of destinations, add egress
  filtering so the container can't reach arbitrary sites.
- For production-grade remote browser isolation (per-session containers,
  DLP, clipboard/file-transfer controls, audit logging), a purpose-built
  product (e.g. Menlo Security, Cloudflare Browser Isolation, Kasm
  Workspaces) will do more than this reference setup.

## Troubleshooting
- **Build fails to find `chromium`**: make sure the base image is Debian
  (`bookworm-slim`), not Ubuntu — Ubuntu's `chromium-browser` package is a
  snap stub that doesn't work in containers.
- **Service keeps restarting on Render**: almost always memory. Bump the
  plan or lower `RESOLUTION`.
- **Blank/black screen in the browser**: give it a few extra seconds on
  first load — Xvfb, Chromium, and the VNC bridge start in sequence.

## Repo layout
```
.
├── Dockerfile
├── entrypoint.sh
├── render.yaml
├── docker-compose.yml
├── web/
│   └── index.html
└── README.md
```
