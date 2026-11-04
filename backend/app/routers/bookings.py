from typing import List
from datetime import date
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import and_
from app.db.database import get_db
from app.models.booking import Booking
from app.models.car import Car
from app.models.user import User
from app.models.notification import Notification
from app.schemas.booking import BookingCreate, BookingOut
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/bookings", tags=["Bookings"])

@router.post("", response_model=BookingOut, status_code=status.HTTP_201_CREATED)
def create_booking(
    booking_in: BookingCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Create a new car booking.
    Calculates total days & total price securely on the backend.
    Checks date order and booking overlap.
    """
    # 1. Check if car exists and is active
    car = db.query(Car).filter(Car.id == booking_in.car_id).first()
    if not car:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Car with ID {booking_in.car_id} does not exist"
        )
    if not car.is_available:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This car is currently not available for rental"
        )

    # 2. Validate dates
    if booking_in.start_date >= booking_in.end_date:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Start date must be before end date"
        )

    # 3. Check for booking conflicts/overlap
    overlap = db.query(Booking).filter(
        Booking.car_id == booking_in.car_id,
        Booking.status.in_(["pending", "confirmed"]),
        and_(
            Booking.start_date <= booking_in.end_date,
            Booking.end_date >= booking_in.start_date
        )
    ).first()
    if overlap:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="This car is already booked for the selected dates. Please choose another date range."
        )

    # 4. Calculate total rental days and backend-calculated total price
    total_days = (booking_in.end_date - booking_in.start_date).days
    if total_days <= 0:
        total_days = 1
    total_price = round(float(total_days * car.price_per_day), 2)

    # 5. Create new booking record
    new_booking = Booking(
        user_id=current_user.id,
        car_id=car.id,
        start_date=booking_in.start_date,
        end_date=booking_in.end_date,
        total_days=total_days,
        total_price=total_price,
        pickup_location=booking_in.pickup_location.strip(),
        status="confirmed"
    )
    db.add(new_booking)
    db.commit()
    db.refresh(new_booking)

    # Automatically add booking confirmation notification
    try:
        booking_notif = Notification(
            user_id=current_user.id,
            title="Booking Confirmed! 🚗",
            message=f"Your booking for {car.brand} {car.name} ({booking_in.start_date} to {booking_in.end_date}) is confirmed at {booking_in.pickup_location}.",
            type="booking"
        )
        db.add(booking_notif)
        db.commit()
    except Exception:
        pass

    return new_booking

@router.get("/my", response_model=List[BookingOut])
def get_my_bookings(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Retrieve all bookings placed by the currently logged-in user"""
    bookings = db.query(Booking).options(
        joinedload(Booking.user),
        joinedload(Booking.car)
    ).filter(
        Booking.user_id == current_user.id
    ).order_by(Booking.id.desc()).all()
    return bookings

@router.get("/{booking_id}", response_model=BookingOut)
def get_booking_by_id(
    booking_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Retrieve details for a specific booking (only owner or admin)"""
    booking = db.query(Booking).options(
        joinedload(Booking.user),
        joinedload(Booking.car)
    ).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Booking with ID {booking_id} not found"
        )
    if booking.user_id != current_user.id and current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to view this booking"
        )
    return booking

@router.patch("/{booking_id}/cancel", response_model=BookingOut)
def cancel_booking(
    booking_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Cancel a booking if it belongs to the user and is still cancellable"""
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    if booking.user_id != current_user.id and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Unauthorized to cancel this booking")

    if booking.status in ["cancelled", "completed"]:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot cancel a booking that is already {booking.status}"
        )

    booking.status = "cancelled"
    db.commit()
    db.refresh(booking)

    # Automatically add cancellation notification
    try:
        car_info = f"{booking.car.brand} {booking.car.name}" if booking.car else "car"
        cancel_notif = Notification(
            user_id=booking.user_id,
            title="Booking Cancelled ⚠️",
            message=f"Booking #{booking.id} for {car_info} has been cancelled.",
            type="booking"
        )
        db.add(cancel_notif)
        db.commit()
    except Exception:
        pass

    return booking
