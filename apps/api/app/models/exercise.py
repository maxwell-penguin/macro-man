import enum

from sqlalchemy import Integer, String, Float, DateTime, ForeignKey, Enum
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class ExerciseSource(str, enum.Enum):
    manual = "manual"
    healthkit = "healthkit"


class Exercise(Base):
    __tablename__ = "exercises"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    logged_at: Mapped[DateTime] = mapped_column(DateTime, nullable=False)
    type: Mapped[str] = mapped_column(String, nullable=False)
    duration_min: Mapped[float] = mapped_column(Float, nullable=True)
    calories_burned: Mapped[float] = mapped_column(Float, nullable=True)
    source: Mapped[ExerciseSource] = mapped_column(Enum(ExerciseSource), nullable=False)
