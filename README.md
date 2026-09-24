# Cal-AI Workout App

Photo-first calorie and workout tracker. See [CLAUDE.md](./CLAUDE.md) for full project context, data model, and phase plan.

## Layout

- `apps/mobile` — SwiftUI app (XcodeGen; edit `project.yml`, not the `.xcodeproj`)
- `apps/api` — FastAPI backend
- `infra` — docker-compose for Postgres + Redis

## Running locally

### API

```bash
docker compose -f infra/docker-compose.yml up -d
cd apps/api
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
.venv/bin/alembic upgrade head
.venv/bin/uvicorn app.main:app --reload
```

`GET http://localhost:8000/health` should return `{"status": "ok"}`.

### Mobile

```bash
cd apps/mobile
xcodegen generate
open CalAI.xcodeproj
```

Build and run on a simulator. The Dashboard tab pings the API's `/health` endpoint.
