from typing import List, Optional
from datetime import date
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from sqlalchemy import or_, and_
from app.db.database import get_db
from app.models.car import Car
from app.models.category import Category
from app.models.booking import Booking
from app.schemas.car import CarOut, CarDetailOut

router = APIRouter(prefix="/cars", tags=["Cars"])

def enrich_car_out(car: Car) -> CarOut:
    return CarOut(
        id=car.id,
        name=car.name,
        brand=car.brand,
        category_id=car.category_id,
        category_name=car.category.name if car.category else None,
        price_per_day=car.price_per_day,
        image_url=car.image_url,
        transmission=car.transmission,
        fuel_type=car.fuel_type,
        seats=car.seats,
        is_available=car.is_available,
        is_featured=car.is_featured,
        rating=car.rating,
        description=car.description
    )

@router.get("", response_model=List[CarOut])
def get_all_cars(
    category_id: Optional[int] = None,
    brand: Optional[str] = None,
    is_available: Optional[bool] = True,
    max_price: Optional[float] = None,
    sort_by: Optional[str] = Query(None, description="price_asc, price_desc, or rating"),
    db: Session = Depends(get_db)
):
    """
    Get all cars with optional filters for category, brand, availability, and pricing.
    Used on Flutter Home Screen and Explore Screen.
    """
    query = db.query(Car)

    if category_id:
        query = query.filter(Car.category_id == category_id)
    if brand:
        query = query.filter(Car.brand.ilike(f"%{brand}%"))
    if is_available is not None:
        query = query.filter(Car.is_available == is_available)
    if max_price:
        query = query.filter(Car.price_per_day <= max_price)

    if sort_by == "price_asc":
        query = query.order_by(Car.price_per_day.asc())
    elif sort_by == "price_desc":
        query = query.order_by(Car.price_per_day.desc())
    elif sort_by == "rating":
        query = query.order_by(Car.rating.desc())
    else:
        query = query.order_by(Car.id.asc())

    cars = query.all()
    return [enrich_car_out(c) for c in cars]

# Declared BEFORE /cars/{car_id} to prevent path conflict
@router.get("/featured", response_model=List[CarOut])
def get_featured_cars(db: Session = Depends(get_db)):
    """Fetch featured cars to showcase on the Flutter Home Screen banner/carousel"""
    cars = db.query(Car).filter(Car.is_featured == True, Car.is_available == True).all()
    return [enrich_car_out(c) for c in cars]

# Declared BEFORE /cars/{car_id} to prevent path conflict
@router.get("/search", response_model=List[CarOut])
def search_cars(
    name: Optional[str] = Query(None, description="Search term for car name or brand"),
    category_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    """Search cars by keyword in name or brand, with optional category filter"""
    query = db.query(Car)
    if name:
        search_pattern = f"%{name}%"
        query = query.filter(
            or_(Car.name.ilike(search_pattern), Car.brand.ilike(search_pattern))
        )
    if category_id:
        query = query.filter(Car.category_id == category_id)

    cars = query.all()
    return [enrich_car_out(c) for c in cars]

@router.get("/{car_id}", response_model=CarDetailOut)
def get_car_by_id(car_id: int, db: Session = Depends(get_db)):
    """Fetch complete details, specs, and category for a single car"""
    car = db.query(Car).filter(Car.id == car_id).first()
    if not car:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Car with ID {car_id} not found"
        )
    return CarDetailOut(
        id=car.id,
        name=car.name,
        brand=car.brand,
        category_id=car.category_id,
        category_name=car.category.name if car.category else None,
        price_per_day=car.price_per_day,
        image_url=car.image_url,
        transmission=car.transmission,
        fuel_type=car.fuel_type,
        seats=car.seats,
        is_available=car.is_available,
        is_featured=car.is_featured,
        rating=car.rating,
        description=car.description,
        category=car.category,
        created_at=car.created_at
    )

@router.get("/{car_id}/availability")
def check_car_availability(
    car_id: int,
    start_date: date = Query(..., description="Desired start date (YYYY-MM-DD)"),
    end_date: date = Query(..., description="Desired end date (YYYY-MM-DD)"),
    db: Session = Depends(get_db)
):
    """Check if a car is available for rent during the specified date range"""
    car = db.query(Car).filter(Car.id == car_id).first()
    if not car:
        raise HTTPException(status_code=404, detail="Car not found")
    if not car.is_available:
        return {"car_id": car_id, "is_available": False, "reason": "Car is marked as temporarily unavailable"}

    if start_date >= end_date:
        raise HTTPException(status_code=400, detail="Start date must be before end date")

    # Check for overlapping active bookings:
    # Overlap formula: (existing.start_date <= requested.end_date) AND (existing.end_date >= requested.start_date)
    overlap = db.query(Booking).filter(
        Booking.car_id == car_id,
        Booking.status.in_(["pending", "confirmed"]),
        and_(
            Booking.start_date <= end_date,
            Booking.end_date >= start_date
        )
    ).first()

    is_free = (overlap is None)
    return {
        "car_id": car_id,
        "start_date": start_date,
        "end_date": end_date,
        "is_available": is_free,
        "message": "Car is available for booking" if is_free else "Car is already booked for these dates"
    }
