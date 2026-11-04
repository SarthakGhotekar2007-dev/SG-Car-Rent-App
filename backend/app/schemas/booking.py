from datetime import date, datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict
from app.schemas.car import CarOut

class BookingUserOut(BaseModel):
    id: int
    name: str
    email: str
    phone: Optional[str] = None
    avatar_url: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)

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
    user: Optional[BookingUserOut] = None
    user_name: Optional[str] = None
    user_email: Optional[str] = None
    user_phone: Optional[str] = None
    user_avatar: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)
