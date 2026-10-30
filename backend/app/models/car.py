from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from app.db.database import Base

class Car(Base):
    __tablename__ = "cars"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)  # e.g., "Tesla Model S"
    brand = Column(String(50), index=True, nullable=False)  # e.g., "Tesla"
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=False)
    price_per_day = Column(Float, nullable=False)  # e.g., 120.0
    image_url = Column(String(500), nullable=False)
    transmission = Column(String(20), default="Automatic")  # Automatic / Manual
    fuel_type = Column(String(20), default="Electric")  # Electric / Petrol / Diesel / Hybrid
    seats = Column(Integer, default=5)
    is_available = Column(Boolean, default=True)
    is_featured = Column(Boolean, default=False)
    rating = Column(Float, default=4.8)
    description = Column(Text, nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    # Relationships
    category = relationship("Category", back_populates="cars")
    bookings = relationship("Booking", back_populates="car", cascade="all, delete-orphan")
    favorites = relationship("Favorite", back_populates="car", cascade="all, delete-orphan")
