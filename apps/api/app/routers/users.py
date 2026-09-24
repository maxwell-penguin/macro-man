from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.calorie_math import tdee as compute_tdee, bmr as compute_bmr
from app.database import get_db
from app.models.user import User
from app.schemas.user import UserProfileIn, UserOut, TDEEOut

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/{user_id}", response_model=UserOut)
def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.put("/{user_id}", response_model=UserOut)
def upsert_user(user_id: int, body: UserProfileIn, db: Session = Depends(get_db)):
    user = db.get(User, user_id)
    if not user:
        user = User(id=user_id)
        db.add(user)
    for field, value in body.model_dump(exclude_unset=True).items():
        setattr(user, field, value)
    db.commit()
    db.refresh(user)
    return user


@router.get("/{user_id}/tdee", response_model=TDEEOut)
def get_tdee(user_id: int, db: Session = Depends(get_db)):
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
    return TDEEOut(
        bmr=compute_bmr(user.weight_kg, user.height_cm, user.age, user.sex),
        tdee=compute_tdee(user.weight_kg, user.height_cm, user.age, user.sex, user.activity_level),
    )
