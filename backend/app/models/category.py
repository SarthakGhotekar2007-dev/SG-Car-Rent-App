from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from app.db.database import Base

class Category(Base):
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), unique=True, index=True, nullable=False)  # SUV, Sedan, Luxury, Electric
    slug = Column(String(50), unique=True, index=True, nullable=False)  # suv, sedan, luxury, electric
    description = Column(String(255), nullable=True)
    icon_name = Column(String(50), nullable=True)  # icon name for Flutter

    # Relationships
    cars = relationship("Car", back_populates="category", cascade="all, delete-orphan")
