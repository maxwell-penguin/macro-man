from sqlalchemy import Integer, Float, Date, ForeignKey, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class DailyLog(Base):
    __tablename__ = "daily_logs"
    __table_args__ = (UniqueConstraint("user_id", "date"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    date: Mapped[Date] = mapped_column(Date, nullable=False)
    calories_in: Mapped[float] = mapped_column(Float, nullable=True)
    calories_burned: Mapped[float] = mapped_column(Float, nullable=True)
    net: Mapped[float] = mapped_column(Float, nullable=True)
