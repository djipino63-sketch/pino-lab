SHELL := /usr/bin/env bash
.DEFAULT_GOAL := start

.PHONY: start up down bootstrap logs logs-openclaw logs-vnc logs-tunnel vnc tunnel openclaw-init openclaw-up openclaw

start:
	@bash ./start.sh

up:
	@bash ./start.sh

down:
	@pkill -f 'start-openclaw.sh|start-vnc.sh|start-tunnel.sh' >/dev/null 2>&1 || true

bootstrap:
	@START_STACK=0 bash ./scripts/start-codespaces.sh

openclaw-init:
	@bash ./scripts/init-openclaw.sh

openclaw-up:
	@bash ./scripts/init-openclaw.sh
	@bash ./scripts/start-openclaw.sh

openclaw: openclaw-up

logs:
	@mkdir -p logs
	@touch logs/start.log
	@tail -f logs/start.log

logs-openclaw:
	@mkdir -p logs
	@touch logs/openclaw.log
	@tail -f logs/openclaw.log

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
