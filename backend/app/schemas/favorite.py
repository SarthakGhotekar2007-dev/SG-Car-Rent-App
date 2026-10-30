from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict
from app.schemas.car import CarOut

class FavoriteOut(BaseModel):
    id: int
    user_id: int
    car_id: int
    created_at: datetime
    car: Optional[CarOut] = None

    model_config = ConfigDict(from_attributes=True)
