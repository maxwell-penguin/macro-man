from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class MealCreate(BaseModel):
    name: str
    qty: Optional[float] = None
    calories: Optional[float] = None
    protein_g: Optional[float] = None
    carbs_g: Optional[float] = None
    fat_g: Optional[float] = None
    logged_at: Optional[datetime] = None


class MealUpdate(BaseModel):
    name: Optional[str] = None
    qty: Optional[float] = None
    calories: Optional[float] = None
    protein_g: Optional[float] = None
    carbs_g: Optional[float] = None
    fat_g: Optional[float] = None


class MealOut(BaseModel):
    id: int
    user_id: int
    logged_at: datetime
    source: str
    name: str
    qty: Optional[float] = None
    calories: Optional[float] = None
    protein_g: Optional[float] = None
    carbs_g: Optional[float] = None
    fat_g: Optional[float] = None
