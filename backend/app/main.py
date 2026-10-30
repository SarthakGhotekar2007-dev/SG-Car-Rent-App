from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.db.database import engine, Base, SessionLocal
from app.db.seed import seed_database
from app.routers import auth, cars, categories, bookings, favorites, users, admin, notifications

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifecycle manager: Auto-creates tables and seeds initial data on server startup"""
    # Create all database tables
    Base.metadata.create_all(bind=engine)
    
    # Pre-populate sample cars & categories if empty
    db = SessionLocal()
    try:
        seed_database(db)
    finally:
        db.close()
    
    yield

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Backend REST API for SG Car Rent mobile application built with FastAPI, SQLAlchemy & Supabase PostgreSQL.",
    version="1.0.0",
    lifespan=lifespan
)

# Enable CORS for Flutter (Web, Android Emulator, iOS Simulator, Physical Device)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount all feature routers under /api/v1
app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(cars.router, prefix=settings.API_V1_STR)
app.include_router(categories.router, prefix=settings.API_V1_STR)
app.include_router(bookings.router, prefix=settings.API_V1_STR)
app.include_router(favorites.router, prefix=settings.API_V1_STR)
app.include_router(users.router, prefix=settings.API_V1_STR)
app.include_router(admin.router, prefix=settings.API_V1_STR)
app.include_router(notifications.router, prefix=settings.API_V1_STR)

@app.get("/", tags=["Root"])
def root():
    return {
        "message": "Welcome to SG Car Rent API 🚗",
        "documentation": "/docs",
        "health": "/health",
        "version": "1.0.0"
    }

@app.get("/health", tags=["Root"])
def health_check():
    return {"status": "healthy", "service": "SG Car Rent Backend"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
