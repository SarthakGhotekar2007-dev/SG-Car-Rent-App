from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.models.favorite import Favorite
from app.models.car import Car
from app.models.user import User
from app.schemas.favorite import FavoriteOut
from app.schemas.car import CarOut
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/favorites", tags=["Favorites"])

@router.post("/{car_id}", status_code=status.HTTP_200_OK)
def add_to_favorites(
    car_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Add a car to current user's favorites without duplicates"""
    car = db.query(Car).filter(Car.id == car_id).first()
    if not car:
        raise HTTPException(status_code=404, detail="Car not found")

    existing = db.query(Favorite).filter(
        Favorite.user_id == current_user.id,
        Favorite.car_id == car_id
    ).first()

    if existing:
        return {"message": "Car is already in your favorites", "favorite_id": existing.id}

    new_favorite = Favorite(user_id=current_user.id, car_id=car_id)
    db.add(new_favorite)
    db.commit()
    db.refresh(new_favorite)
    return {"message": "Car added to favorites successfully", "favorite_id": new_favorite.id}

@router.get("", response_model=List[FavoriteOut])
def get_user_favorites(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Fetch all cars marked as favorite by the logged-in user"""
    favorites = db.query(Favorite).filter(
        Favorite.user_id == current_user.id
    ).order_by(Favorite.id.desc()).all()
    return favorites

@router.delete("/{car_id}")
def remove_from_favorites(
    car_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Remove a car from current user's favorites"""
    fav = db.query(Favorite).filter(
        Favorite.user_id == current_user.id,
        Favorite.car_id == car_id
    ).first()

    if not fav:
        raise HTTPException(status_code=404, detail="Car is not in your favorites")

    db.delete(fav)
    db.commit()
    return {"message": "Car removed from favorites successfully"}
