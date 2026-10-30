from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, DateTime, Boolean
from sqlalchemy.orm import relationship
from app.db.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    phone = Column(String(20), nullable=True)
    role = Column(String(20), default="user")  # "user" or "admin"
    bio = Column(String(255), nullable=True, default="")
    avatar_url = Column(String(500), nullable=True, default="")
    linkedin = Column(String(255), nullable=True, default="")
    github = Column(String(255), nullable=True, default="")
    language = Column(String(50), default="English")
    theme_mode = Column(String(20), default="dark")
    profile_visibility = Column(Boolean, default=True)
    show_online_status = Column(Boolean, default=True)
    allow_message_requests = Column(Boolean, default=True)
    two_factor_auth = Column(Boolean, default=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    # Relationships
    bookings = relationship("Booking", back_populates="user", cascade="all, delete-orphan")
    favorites = relationship("Favorite", back_populates="user", cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="user", cascade="all, delete-orphan")
