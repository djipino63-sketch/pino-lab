# Quickstart

1. `cp .env.example .env`
2. Renseigne `CLOUDFLARE_TUNNEL_TOKEN` dans `.env`
3. `bash start.sh`
4. Ouvre `http://127.0.0.1:6080` pour VNC si le port est forwardé
5. Regarde OpenClaw avec `bash scripts/compose.sh logs -f openclaw`

Notes:
- `bash start.sh` lance la pile complète
- Cloudflare est le tunnel par défaut
- Colab reste séparé pour GPU/RAM
