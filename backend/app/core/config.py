import os
from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    PROJECT_NAME: str = "SG Car Rent API"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "sg-car-rent-super-secret-key-change-in-production-2026"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days

    # Supabase PostgreSQL URL or local fallback
    # In Supabase: Settings -> Database -> Connection string (URI)
    DATABASE_URL: str = "sqlite:///./sg_car_rent.db"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        extra = "allow"

settings = Settings()
