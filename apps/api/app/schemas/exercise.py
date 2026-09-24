from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class ExerciseCreate(BaseModel):
    type: str
    duration_min: Optional[float] = None
    calories_burned: Optional[float] = None
    logged_at: Optional[datetime] = None


class ExerciseUpdate(BaseModel):
    type: Optional[str] = None
    duration_min: Optional[float] = None
    calories_burned: Optional[float] = None


class ExerciseOut(BaseModel):
    id: int
    user_id: int
    logged_at: datetime
    type: str
    duration_min: Optional[float] = None
    calories_burned: Optional[float] = None
    source: str

    class Config:
        from_attributes = True
