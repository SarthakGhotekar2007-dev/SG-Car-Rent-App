from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict
from app.schemas.category import CategoryOut

class CarBase(BaseModel):
    name: str
    brand: str
    price_per_day: float
    image_url: str
    transmission: str = "Automatic"
    fuel_type: str = "Electric"
    seats: int = 5
    is_available: bool = True
    is_featured: bool = False
    rating: float = 4.8
    description: Optional[str] = None

class CarCreate(CarBase):
    category_id: int

class CarUpdate(BaseModel):
    name: Optional[str] = None
    brand: Optional[str] = None
    category_id: Optional[int] = None
    price_per_day: Optional[float] = None
    image_url: Optional[str] = None
    transmission: Optional[str] = None
    fuel_type: Optional[str] = None
    seats: Optional[int] = None
    is_available: Optional[bool] = None
    is_featured: Optional[bool] = None
    rating: Optional[float] = None
    description: Optional[str] = None

class CarOut(BaseModel):
    id: int
    name: str
    brand: str
    category_id: int
    category_name: Optional[str] = None
    price_per_day: float
    image_url: str
    transmission: str
    fuel_type: str
    seats: int
    is_available: bool
    is_featured: bool
    rating: float
    description: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)

class CarDetailOut(CarOut):
    category: Optional[CategoryOut] = None
    created_at: Optional[datetime] = None
