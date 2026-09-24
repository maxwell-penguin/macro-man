from datetime import date, datetime
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.meal import Meal, MealItem, MealSource
from app.schemas.meal import MealCreate, MealUpdate, MealOut

router = APIRouter(prefix="/meals", tags=["meals"])


def _to_out(meal: Meal) -> MealOut:
    item = meal.items[0] if meal.items else None
    return MealOut(
        id=meal.id,
        user_id=meal.user_id,
        logged_at=meal.logged_at,
        source=meal.source.value,
        name=item.name if item else "",
        qty=item.qty if item else None,
        calories=item.calories if item else None,
        protein_g=item.protein_g if item else None,
        carbs_g=item.carbs_g if item else None,
        fat_g=item.fat_g if item else None,
    )


@router.post("", response_model=MealOut)
def create_meal(body: MealCreate, user_id: int = 1, db: Session = Depends(get_db)):
    meal = Meal(user_id=user_id, logged_at=body.logged_at or datetime.utcnow(), source=MealSource.manual)
    meal.items = [
        MealItem(
            name=body.name,
            qty=body.qty,
            calories=body.calories,
            protein_g=body.protein_g,
            carbs_g=body.carbs_g,
            fat_g=body.fat_g,
        )
    ]
    db.add(meal)
    db.commit()
    db.refresh(meal)
    return _to_out(meal)


@router.get("", response_model=List[MealOut])
def list_meals(date: Optional[date] = None, user_id: int = 1, db: Session = Depends(get_db)):
    target_date = date or datetime.utcnow().date()
    meals = (
        db.query(Meal)
        .filter(Meal.user_id == user_id, func.date(Meal.logged_at) == target_date)
        .order_by(Meal.logged_at)
        .all()
    )
    return [_to_out(m) for m in meals]


@router.get("/{meal_id}", response_model=MealOut)
def get_meal(meal_id: int, db: Session = Depends(get_db)):
    meal = db.get(Meal, meal_id)
    if not meal:
        raise HTTPException(status_code=404, detail="Meal not found")
    return _to_out(meal)


@router.put("/{meal_id}", response_model=MealOut)
def update_meal(meal_id: int, body: MealUpdate, db: Session = Depends(get_db)):
    meal = db.get(Meal, meal_id)
    if not meal:
        raise HTTPException(status_code=404, detail="Meal not found")
    item = meal.items[0] if meal.items else None
    if not item:
        raise HTTPException(status_code=404, detail="Meal has no item to update")
    for field, value in body.model_dump(exclude_unset=True).items():
        setattr(item, field, value)
    db.commit()
    db.refresh(meal)
    return _to_out(meal)


@router.delete("/{meal_id}", status_code=204)
def delete_meal(meal_id: int, db: Session = Depends(get_db)):
    meal = db.get(Meal, meal_id)
    if not meal:
        raise HTTPException(status_code=404, detail="Meal not found")
    db.delete(meal)
    db.commit()
