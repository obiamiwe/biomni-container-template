# Biomni Deployment Template

A minimal, self-hosted deployment pattern for running a Flask app built on
top of the open-source [Biomni](https://github.com/snap-stanford/Biomni)
biomedical AI agent, behind SSO.

**This repo contains infrastructure only** — no application code. It
expects your own Flask app (built on the `biomni` Python package) in an
`app/` directory alongside these files.

## Stack

- **Caddy** — TLS termination and reverse proxy
- **OAuth2 Proxy** — SSO gate in front of the app (configured here for
  generic OIDC — Okta, Azure AD, Google Workspace, etc. all work)
- **Your app** — a Flask app using the `biomni` package, served via gunicorn

## Setup

1. Put your Flask app in `./app/` (see `Dockerfile` — it expects `app.py`,
   `biomni/`, `ui.html`, `static/`, and `pyproject.toml`; adjust as needed)
2. Copy `env/biomni.env.example` → `env/biomni.env` and fill in real values
3. Copy `env/oauth2-proxy.env.example` → `env/oauth2-proxy.env` and fill in
   your OIDC client ID/secret and a cookie secret
4. Edit `oauth2-proxy.cfg` — set `oidc_issuer_url`, `redirect_url`, and
   `email_domains` for your organization
5. Edit `Caddyfile` — set your real TLS cert paths (or switch to Caddy's
   automatic HTTPS if you don't have enterprise certs)
6. `mkdir -p certs caddy-data caddy-config`
7. `docker compose up -d --build`

## LLM backend

Defaults to AWS Bedrock (`LLM_SOURCE=Bedrock` in `biomni.env`) — requires an
IAM role with `bedrock:InvokeModel` permissions attached to whatever's
running the container (no AWS keys needed in the env file). Set
`LLM_SOURCE=Anthropic` and fill in `ANTHROPIC_API_KEY` to call the Anthropic
API directly instead.

**Note on newer Claude models via Bedrock:** some parameters valid on the
direct Anthropic API (e.g. `temperature`) are rejected by Bedrock for newer
model generations. Check your model's Bedrock model card before assuming a
parameter is supported.

## What's NOT in this repo

Application code, know-how/prompt customization, and any org-specific
secrets. This is deliberately just the container/networking/auth pattern —
build your own app on top of it.
