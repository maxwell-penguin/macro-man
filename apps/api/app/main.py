from fastapi import FastAPI

from app.routers import users, meals, exercises, daily_summary

app = FastAPI(title="Cal-AI API")

app.include_router(users.router)
app.include_router(meals.router)
app.include_router(exercises.router)
app.include_router(daily_summary.router)


@app.get("/health")
def health():
    return {"status": "ok"}
