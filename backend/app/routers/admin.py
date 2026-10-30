from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.models.car import Car
from app.models.category import Category
from app.models.booking import Booking
from app.models.user import User
from app.models.notification import Notification
from app.schemas.car import CarCreate, CarUpdate, CarDetailOut, CarOut
from app.schemas.booking import BookingOut, BookingStatusUpdate
from app.core.dependencies import get_current_admin

router = APIRouter(prefix="/admin", tags=["Admin"])

@router.post("/cars", response_model=CarDetailOut, status_code=status.HTTP_201_CREATED)
def admin_add_car(
    car_in: CarCreate,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Add a new car to the fleet (Admin only)"""
    category = db.query(Category).filter(Category.id == car_in.category_id).first()
    if not category:
        raise HTTPException(status_code=400, detail=f"Category ID {car_in.category_id} does not exist")

    new_car = Car(
        name=car_in.name.strip(),
        brand=car_in.brand.strip(),
        category_id=car_in.category_id,
        price_per_day=car_in.price_per_day,
        image_url=car_in.image_url.strip(),
        transmission=car_in.transmission,
        fuel_type=car_in.fuel_type,
        seats=car_in.seats,
        is_available=car_in.is_available,
        is_featured=car_in.is_featured,
        rating=car_in.rating,
        description=car_in.description
    )
    db.add(new_car)
    db.commit()
    db.refresh(new_car)
    return new_car

@router.put("/cars/{car_id}", response_model=CarDetailOut)
def admin_replace_car(
    car_id: int,
    car_in: CarCreate,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Completely update all information for a car (Admin only)"""
    car = db.query(Car).filter(Car.id == car_id).first()
    if not car:
        raise HTTPException(status_code=404, detail="Car not found")

    category = db.query(Category).filter(Category.id == car_in.category_id).first()
    if not category:
        raise HTTPException(status_code=400, detail="Category does not exist")

    for field, val in car_in.model_dump().items():
        setattr(car, field, val)

    db.commit()
    db.refresh(car)
    return car

@router.patch("/cars/{car_id}", response_model=CarDetailOut)
def admin_update_car_partial(
    car_id: int,
    car_in: CarUpdate,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Partially update car fields (Admin only)"""
    car = db.query(Car).filter(Car.id == car_id).first()
    if not car:
        raise HTTPException(status_code=404, detail="Car not found")

    update_data = car_in.model_dump(exclude_unset=True)
    if "category_id" in update_data:
        cat = db.query(Category).filter(Category.id == update_data["category_id"]).first()
        if not cat:
            raise HTTPException(status_code=400, detail="Target category does not exist")

    for field, val in update_data.items():
        setattr(car, field, val)

    db.commit()
    db.refresh(car)
    return car

@router.delete("/cars/{car_id}")
def admin_delete_car(
    car_id: int,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Delete a car from the system (Admin only)"""
    car = db.query(Car).filter(Car.id == car_id).first()
    if not car:
        raise HTTPException(status_code=404, detail="Car not found")

    db.delete(car)
    db.commit()
    return {"message": f"Car '{car.name}' (ID: {car_id}) deleted successfully"}

@router.get("/bookings", response_model=List[BookingOut])
def admin_get_all_bookings(
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """View all bookings across all users in the system (Admin only)"""
    bookings = db.query(Booking).order_by(Booking.id.desc()).all()
    return bookings

@router.patch("/bookings/{booking_id}/status", response_model=BookingOut)
def admin_update_booking_status(
    booking_id: int,
    status_update: BookingStatusUpdate,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Update status for any booking (pending, confirmed, cancelled, completed)"""
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")

    valid_statuses = ["pending", "confirmed", "cancelled", "completed"]
    if status_update.status not in valid_statuses:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid status. Must be one of: {', '.join(valid_statuses)}"
        )

    booking.status = status_update.status
    db.commit()
    db.refresh(booking)

    # Notify user of booking status change
    try:
        status_label = status_update.status.capitalize()
        status_notif = Notification(
            user_id=booking.user_id,
            title=f"Booking Status: {status_label} 📋",
            message=f"Your booking #{booking.id} status was updated to '{status_label}' by SG Car Rent.",
            type="booking"
        )
        db.add(status_notif)
        db.commit()
    except Exception:
        pass

    return booking
