# Quickstart

1. `cp .env.example .env`
2. Laisse `TUNNEL_PROVIDER=none` dans `.env` tant que tu n’as pas un jeton Cloudflare valide
3. Renseigne `CLOUDFLARE_TUNNEL_TOKEN` seulement si tu veux activer Cloudflare
4. `make start`
5. Regarde les logs centralisés avec `make logs`
6. Regarde OpenClaw avec `make logs-openclaw`
7. Ouvre `http://127.0.0.1:6080` pour VNC si le port est forwardé

Notes:
- `make start` lance la pile complète
- Cloudflare se lance automatiquement quand le token est présent et valide
- OpenClaw génère sa config locale au démarrage
- Colab reste séparé pour GPU/RAM
