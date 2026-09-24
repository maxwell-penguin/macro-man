from datetime import date, datetime
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.exercise import Exercise, ExerciseSource
from app.schemas.exercise import ExerciseCreate, ExerciseUpdate, ExerciseOut

router = APIRouter(prefix="/exercises", tags=["exercises"])


@router.post("", response_model=ExerciseOut)
def create_exercise(body: ExerciseCreate, user_id: int = 1, db: Session = Depends(get_db)):
    exercise = Exercise(
        user_id=user_id,
        logged_at=body.logged_at or datetime.utcnow(),
        type=body.type,
        duration_min=body.duration_min,
        calories_burned=body.calories_burned,
        source=ExerciseSource.manual,
    )
    db.add(exercise)
    db.commit()
    db.refresh(exercise)
    return exercise


@router.get("", response_model=List[ExerciseOut])
def list_exercises(date: Optional[date] = None, user_id: int = 1, db: Session = Depends(get_db)):
    target_date = date or datetime.utcnow().date()
    return (
        db.query(Exercise)
        .filter(Exercise.user_id == user_id, func.date(Exercise.logged_at) == target_date)
        .order_by(Exercise.logged_at)
        .all()
    )


@router.get("/{exercise_id}", response_model=ExerciseOut)
def get_exercise(exercise_id: int, db: Session = Depends(get_db)):
    exercise = db.get(Exercise, exercise_id)
    if not exercise:
        raise HTTPException(status_code=404, detail="Exercise not found")
    return exercise


@router.put("/{exercise_id}", response_model=ExerciseOut)
def update_exercise(exercise_id: int, body: ExerciseUpdate, db: Session = Depends(get_db)):
    exercise = db.get(Exercise, exercise_id)
    if not exercise:
        raise HTTPException(status_code=404, detail="Exercise not found")
    for field, value in body.model_dump(exclude_unset=True).items():
        setattr(exercise, field, value)
    db.commit()
    db.refresh(exercise)
    return exercise


@router.delete("/{exercise_id}", status_code=204)
def delete_exercise(exercise_id: int, db: Session = Depends(get_db)):
    exercise = db.get(Exercise, exercise_id)
    if not exercise:
        raise HTTPException(status_code=404, detail="Exercise not found")
    db.delete(exercise)
    db.commit()
