from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.models.notification import Notification
from app.models.booking import Booking
from app.models.user import User
from app.schemas.notification import NotificationOut
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/notifications", tags=["Notifications"])

def add_notification_for_user(
    db: Session,
    user_id: int,
    title: str,
    message: str,
    notification_type: str = "system"
) -> Notification:
    """Helper utility to create a new notification record for any user"""
    notification = Notification(
        user_id=user_id,
        title=title,
        message=message,
        type=notification_type,
        is_read=False
    )
    db.add(notification)
    db.commit()
    db.refresh(notification)
    return notification

@router.get("", response_model=List[NotificationOut])
def get_user_notifications(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Retrieve all notifications for the authenticated user, ordered from newest to oldest.
    If the user has zero notifications yet, initial greeting and booking notifications
    are automatically seeded so the screen displays meaningful real data immediately.
    """
    notifications = db.query(Notification).filter(
        Notification.user_id == current_user.id
    ).order_by(Notification.id.desc()).all()

    # If first time viewing notifications, seed initial welcome & promo items
    if not notifications:
        # 1. Welcome Notification
        add_notification_for_user(
            db=db,
            user_id=current_user.id,
            title="Welcome to SG Car Rent! ",
            message=f"Hi {current_user.name.split()[0]}, thank you for joining SG Car Rent! Explore our luxury fleet and book your dream car anytime.",
            notification_type="system"
        )

        # 2. Check if user already placed any bookings, add confirmation alerts
        latest_booking = db.query(Booking).filter(
            Booking.user_id == current_user.id
        ).order_by(Booking.id.desc()).first()

        if latest_booking and latest_booking.car:
            add_notification_for_user(
                db=db,
                user_id=current_user.id,
                title="Booking Confirmed! ",
                message=f"Your reservation for {latest_booking.car.brand} {latest_booking.car.name} is confirmed for {latest_booking.start_date}.",
                notification_type="booking"
            )

        # 3. Promotional Offer Notification
        add_notification_for_user(
            db=db,
            user_id=current_user.id,
            title="Special Weekend Offer ",
            message="Enjoy 15% discount on electric and sports category cars this weekend. Apply code LUXURY15 at checkout.",
            notification_type="promotion"
        )

        # Re-fetch populated notifications
        notifications = db.query(Notification).filter(
            Notification.user_id == current_user.id
        ).order_by(Notification.id.desc()).all()

    return notifications

@router.put("/read-all")
def mark_all_notifications_as_read(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Mark all unread notifications for current user as read"""
    db.query(Notification).filter(
        Notification.user_id == current_user.id,
        Notification.is_read == False
    ).update({"is_read": True})
    db.commit()
    return {"message": "All notifications marked as read"}

@router.put("/{notification_id}/read", response_model=NotificationOut)
def mark_single_notification_as_read(
    notification_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Mark a specific notification as read"""
    notification = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == current_user.id
    ).first()

    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found"
        )

    notification.is_read = True
    db.commit()
    db.refresh(notification)
    return notification

@router.delete("/clear-all")
def clear_all_notifications(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete all notifications for current user"""
    db.query(Notification).filter(
        Notification.user_id == current_user.id
    ).delete()
    db.commit()
    return {"message": "All notifications cleared successfully"}

@router.delete("/{notification_id}")
def delete_single_notification(
    notification_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a single notification"""
    notification = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == current_user.id
    ).first()

    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found"
        )

    db.delete(notification)
    db.commit()
    return {"message": "Notification deleted successfully"}
