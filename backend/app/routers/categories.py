from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.models.category import Category
from app.models.car import Car
from app.schemas.category import CategoryOut
from app.schemas.car import CarOut

router = APIRouter(prefix="/categories", tags=["Categories"])

@router.get("", response_model=List[CategoryOut])
def get_categories(db: Session = Depends(get_db)):
    """Fetch all available car categories (SUV, Sedan, Luxury, Electric, etc.)"""
    categories = db.query(Category).order_by(Category.id.asc()).all()
    return categories

@router.get("/{category_id}/cars", response_model=List[CarOut])
def get_cars_by_category(category_id: int, db: Session = Depends(get_db)):
    """Fetch all available cars belonging to a specific category"""
    category = db.query(Category).filter(Category.id == category_id).first()
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Category with ID {category_id} not found"
        )
    cars = db.query(Car).filter(Car.category_id == category_id, Car.is_available == True).all()
    
    # Enrich with category name
    results = []
    for car in cars:
        car_dict = {
            "id": car.id,
            "name": car.name,
            "brand": car.brand,
            "category_id": car.category_id,
            "category_name": category.name,
            "price_per_day": car.price_per_day,
            "image_url": car.image_url,
            "transmission": car.transmission,
            "fuel_type": car.fuel_type,
            "seats": car.seats,
            "is_available": car.is_available,
            "is_featured": car.is_featured,
            "rating": car.rating,
            "description": car.description
        }
        results.append(CarOut(**car_dict))
    return results
