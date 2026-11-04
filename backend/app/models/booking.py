from datetime import datetime, date, timezone
from sqlalchemy import Column, Integer, String, Float, Date, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.db.database import Base

class Booking(Base):
    __tablename__ = "bookings"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    car_id = Column(Integer, ForeignKey("cars.id"), nullable=False)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    total_days = Column(Integer, nullable=False)
    total_price = Column(Float, nullable=False)
    pickup_location = Column(String(100), nullable=False)
    status = Column(String(20), default="confirmed")  # pending, confirmed, cancelled, completed
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    # Relationships
    user = relationship("User", back_populates="bookings")
    car = relationship("Car", back_populates="bookings")

    # Helper properties for easy serialization with user details
    @property
    def user_name(self) -> str:
        return self.user.name if self.user else ""

    @property
    def user_email(self) -> str:
        return self.user.email if self.user else ""

    @property
    def user_phone(self) -> str:
        return (self.user.phone or "") if self.user else ""

    @property
    def user_avatar(self) -> str:
        return (self.user.avatar_url or "") if self.user else ""
