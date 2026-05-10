# Quickstart

1. `cp .env.example .env`
2. Renseigne `CLOUDFLARE_TUNNEL_TOKEN` dans `.env` si tu veux un tunnel Cloudflare
3. `make start`
4. Regarde les logs centralisés avec `make logs`
5. Regarde OpenClaw avec `make logs-openclaw`
6. Ouvre `http://127.0.0.1:6080` pour VNC si le port est forwardé

Notes:
- `make start` lance la pile complète
- Cloudflare se lance automatiquement quand le token est présent
- OpenClaw génère sa config locale au démarrage
- Colab reste séparé pour GPU/RAM
