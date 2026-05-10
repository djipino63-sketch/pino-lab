SHELL := /usr/bin/env bash
.DEFAULT_GOAL := start

.PHONY: start up down bootstrap logs logs-openclaw logs-vnc logs-tunnel vnc tunnel

start:
	@bash ./start.sh

up:
	@bash ./scripts/compose.sh up -d kali openclaw

down:
	@bash ./scripts/compose.sh down

bootstrap:
	@START_STACK=0 bash ./scripts/start-codespaces.sh

logs:
	@mkdir -p logs
	@touch logs/start.log
	@tail -f logs/start.log

logs-openclaw:
	@bash ./scripts/compose.sh logs -f openclaw

logs-vnc:
	@mkdir -p logs
	@touch logs/vnc.log
	@tail -f logs/vnc.log

logs-tunnel:
	@mkdir -p logs
	@touch logs/tunnel.log
	@tail -f logs/tunnel.log

vnc:
	@bash ./scripts/start-vnc.sh

tunnel:
	@bash ./scripts/start-tunnel.sh
