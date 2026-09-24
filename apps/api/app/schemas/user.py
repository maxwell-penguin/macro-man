from typing import Optional

from pydantic import BaseModel


class UserProfileIn(BaseModel):
    email: Optional[str] = None
    weight_kg: Optional[float] = None
    height_cm: Optional[float] = None
    age: Optional[int] = None
    sex: Optional[str] = None
    activity_level: Optional[str] = None
    goal: Optional[str] = None
    target_rate: Optional[float] = None


class UserOut(BaseModel):
    id: int
    email: Optional[str] = None
    weight_kg: Optional[float] = None
    height_cm: Optional[float] = None
    age: Optional[int] = None
    sex: Optional[str] = None
    activity_level: Optional[str] = None
    goal: Optional[str] = None
    target_rate: Optional[float] = None

    class Config:
        from_attributes = True


class TDEEOut(BaseModel):
    bmr: float
    tdee: float
