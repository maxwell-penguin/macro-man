from datetime import date

from pydantic import BaseModel


class DailySummaryOut(BaseModel):
    date: date
    calories_in: float
    calories_burned: float
    tdee: float
    net: float
    status: str
