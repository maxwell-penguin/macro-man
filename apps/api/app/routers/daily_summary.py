from datetime import date as date_type

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.calorie_math import tdee as compute_tdee, net_calories
from app.database import get_db
from app.models.daily_log import DailyLog
from app.models.exercise import Exercise
from app.models.meal import Meal, MealItem
from app.models.user import User
from app.schemas.daily_summary import DailySummaryOut

router = APIRouter(prefix="/daily-summary", tags=["daily-summary"])


@router.get("/{date}", response_model=DailySummaryOut)
def get_daily_summary(date: date_type, user_id: int = 1, db: Session = Depends(get_db)):
    user = db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    missing = [
        field
        for field in ("weight_kg", "height_cm", "age", "sex", "activity_level")
        if getattr(user, field) is None
    ]
    if missing:
        raise HTTPException(status_code=400, detail=f"Profile incomplete, missing: {', '.join(missing)}")

    calories_in = (
        db.query(func.coalesce(func.sum(MealItem.calories), 0.0))
        .join(Meal, Meal.id == MealItem.meal_id)
        .filter(Meal.user_id == user_id, func.date(Meal.logged_at) == date)
        .scalar()
    )
    calories_burned = (
        db.query(func.coalesce(func.sum(Exercise.calories_burned), 0.0))
        .filter(Exercise.user_id == user_id, func.date(Exercise.logged_at) == date)
        .scalar()
    )

    tdee_value = compute_tdee(user.weight_kg, user.height_cm, user.age, user.sex, user.activity_level)
    net = net_calories(calories_in, tdee_value, calories_burned)
    status = "deficit" if net < 0 else "surplus" if net > 0 else "maintenance"

    log = db.query(DailyLog).filter(DailyLog.user_id == user_id, DailyLog.date == date).first()
    if not log:
        log = DailyLog(user_id=user_id, date=date)
        db.add(log)
    log.calories_in = calories_in
    log.calories_burned = calories_burned
    log.net = net
    db.commit()

    return DailySummaryOut(
        date=date,
        calories_in=calories_in,
        calories_burned=calories_burned,
        tdee=tdee_value,
        net=net,
        status=status,
    )
