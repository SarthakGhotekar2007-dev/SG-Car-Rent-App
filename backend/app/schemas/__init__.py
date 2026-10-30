from app.schemas.user import UserRegister, UserLogin, UserOut, UserUpdate, UserPreferencesUpdate, ChangePasswordRequest, Token
from app.schemas.category import CategoryCreate, CategoryOut
from app.schemas.car import CarCreate, CarOut, CarDetailOut, CarUpdate
from app.schemas.booking import BookingCreate, BookingOut, BookingStatusUpdate
from app.schemas.favorite import FavoriteOut
from app.schemas.notification import NotificationCreate, NotificationOut

__all__ = [
    "UserRegister", "UserLogin", "UserOut", "UserUpdate", "UserPreferencesUpdate", "ChangePasswordRequest", "Token",
    "CategoryCreate", "CategoryOut",
    "CarCreate", "CarOut", "CarDetailOut", "CarUpdate",
    "BookingCreate", "BookingOut", "BookingStatusUpdate",
    "FavoriteOut", "NotificationCreate", "NotificationOut"
]
