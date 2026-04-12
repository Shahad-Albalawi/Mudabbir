# Mudabbir

Cross-platform personal finance app: Flutter client (`apps/frontend`) and Laravel API (`apps/backend`). Arabic-first UI with budgeting, goals, challenges, statistics, and an AI chatbot.

## Repository layout

| Path | Description |
|------|-------------|
| `apps/frontend` | Flutter app — run with `flutter pub get` then `flutter run` (see `apps/frontend/README.md`) |
| `apps/backend` | Laravel API — see `apps/backend/README.md`, `.env.example`, and `docs/` |
| `docs` | Deployment and setup notes |
| `.devcontainer/` | **Cursor / VS Code:** “Reopen in Container” → PHP 8.3 + Composer + `composer install` for `apps/backend` (needs Docker Desktop) |
| `scripts/run-backend-docker.ps1` | **Windows:** تشغيل الباكند عبر Docker من PowerShell بدون PHP محلي |

## Tech stack

Flutter / Dart · Laravel / PHP · SQLite (local) · REST

## Features (high level)

Expense tracking, goals, budgets, behavioral insights, server challenges, bilingual (Arabic / English) chatbot.
