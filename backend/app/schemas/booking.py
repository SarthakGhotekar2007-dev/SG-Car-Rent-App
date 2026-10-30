from datetime import date, datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict
from app.schemas.car import CarOut

class BookingCreate(BaseModel):
    car_id: int
    start_date: date
    end_date: date
    pickup_location: str = "Pune"

class BookingStatusUpdate(BaseModel):
    status: str  # pending, confirmed, cancelled, completed

class BookingOut(BaseModel):
    id: int
    user_id: int
    car_id: int
    start_date: date
    end_date: date
    total_days: int
    total_price: float
    pickup_location: str
    status: str
    created_at: datetime
    car: Optional[CarOut] = None

    model_config = ConfigDict(from_attributes=True)
