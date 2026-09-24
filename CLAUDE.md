# Cal-AI Workout App — Project Context

This file is the source of truth for the project. Read this in full before making changes. Prompts given during development will reference this file instead of re-explaining the project each time.

## What this app does

A photo-first calorie and workout tracker:
1. User takes a photo of food → vision model identifies items and estimates macros → user confirms/edits → logged to their daily diary.
2. User logs exercise (manual entry, MET-based calorie burn estimate).
3. App computes daily net calories (intake vs. TDEE + exercise burn) so the user always knows their current surplus/deficit relative to their goal (cut/maintain/bulk).

The core value prop is friction: logging a meal should take one photo + one confirm tap, not manual macro lookup.

## Tech stack

- **Mobile**: Native SwiftUI, iOS 17+. Project defined via **XcodeGen** (`project.yml`) — not a hand-edited `.xcodeproj`. Local persistence via **SwiftData** for offline draft caching.
- **Backend**: FastAPI (Python), SQLAlchemy + Alembic migrations, Postgres, Redis (caching / rate-limiting vision API calls).
- **Vision/AI**: Claude or GPT-4V, structured JSON output, turning a food photo into itemized macros with a confidence score. Nutritionix/USDA FoodData Central as an optional cross-check in a later phase.
- **Auth**: JWT off the FastAPI backend (or Supabase Auth if we want to skip building this ourselves — not yet decided).
- **No third-party Swift dependencies** until there's a concrete reason to add one.

## Repo structure

```
cal-ai-app/
  apps/
    mobile/               # SwiftUI app
      project.yml          # XcodeGen spec — edit this, not the .xcodeproj
      Sources/
        App/                # App entry point, root TabView
        Features/           # Camera, Diary, Exercise, Dashboard, Profile
        Networking/          # URLSession APIClient + Codable models
        Persistence/          # SwiftData models (offline drafts)
    api/                  # FastAPI backend
      app/
        routers/            # auth, meals, exercises, users, daily_summary
        models/              # SQLAlchemy models
        schemas/              # Pydantic schemas
      alembic/               # migrations
  infra/
    docker-compose.yml    # postgres + redis
  README.md
  CLAUDE.md               # this file
```

## Data model

```sql
users(id, email, weight_kg, height_cm, age, sex, activity_level, goal, target_rate)
meals(id, user_id, logged_at, photo_url, source enum[photo,manual])
meal_items(id, meal_id, name, qty, calories, protein_g, carbs_g, fat_g, confidence)
exercises(id, user_id, logged_at, type, duration_min, calories_burned, source enum[manual,healthkit])
daily_logs(id, user_id, date, calories_in, calories_burned, net, UNIQUE(user_id, date))
weight_logs(id, user_id, date, weight_kg)
```

## Core calorie math

- `BMR` (Mifflin-St Jeor): `10×kg + 6.25×cm − 5×age + 5` (male) or `−161` (female)
- `TDEE` = `BMR × activity_multiplier` (1.2 sedentary → 1.9 very active)
- `Net` = `calories_consumed − (TDEE + calories_burned_from_exercise)`
- Negative net relative to the user's target rate = deficit (cutting); positive = surplus (bulking)

## Development phases

- **Phase 0 — Scaffold**: monorepo, FastAPI skeleton with `/health`, Postgres + Redis via docker-compose, SwiftUI skeleton with stub TabView (Camera, Diary, Exercise, Dashboard, Profile), XcodeGen-generated project builds and runs on simulator, app can hit `/health` over localhost. No business logic yet.
- **Phase 1 — Manual core loop** *(current)*: manual meal entry, manual exercise entry, TDEE calculation from profile inputs, dashboard showing net calories. Prove the loop end-to-end before adding AI.
- **Phase 2 — Photo → macros**: `/meals/scan` endpoint, vision LLM integration, confirm/edit screen before saving to the diary.
- **Phase 3 — Refinement**: nutrition-API cross-check for accuracy, portion-size estimation, streaks/history, charts.
- **Phase 4 — Polish**: HealthKit sync (steps, active energy, workouts), push reminders, MET-based exercise calorie table.

Update the "current" marker above as phases complete.

## Git workflow

- `main` — always deployable
- `develop` — integration branch
- `feature/<scope>-<short-desc>` — e.g. `feature/api-meal-scan`, `feature/mobile-camera-capture`
- Conventional commits: `feat:`, `fix:`, `chore:`, `refactor:`
- PR from feature branch into `develop`; merge once it builds and the relevant health checks pass.

## Working conventions

- Backend and mobile are developed in the same PR when a feature spans both (e.g. Phase 1's TDEE calc needs a new API endpoint and a new SwiftUI screen) — don't split a single feature across branches.
- Don't add business logic ahead of the current phase. Each phase should be shippable and testable before starting the next.
- Keep `Sources/Networking` Codable structs in sync with the FastAPI Pydantic schemas by hand for now — revisit codegen once the schema stabilizes.
