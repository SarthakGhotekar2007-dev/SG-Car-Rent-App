# SG Car Rent - FastAPI Backend 🚗⚡

FastAPI आणि SQLAlchemy वापरून तयार केलेले REST API Backend, जे Supabase (PostgreSQL) सोबत अखंडपणे (seamlessly) काम करते.

---

## 🚀 How to Run the Backend

### 1. Terminal मध्ये backend फोल्डरमध्ये जा:
```powershell
cd "c:\flutter practice\sg car rent app\backend"
```

### 2. Virtual Environment ॲक्टिव्हेट करा (पर्यायी):
```powershell
.\venv\Scripts\Activate.ps1
```

### 3. FastAPI Server सुरू करा:
```powershell
.\venv\Scripts\uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 4. Interactive API Documentation (Swagger UI):
सर्व APIs टेस्ट करण्यासाठी ब्राउझरमध्ये उघडा:
👉 **[http://localhost:8000/docs](http://localhost:8000/docs)**  
किंवा ReDoc: **[http://localhost:8000/redoc](http://localhost:8000/redoc)**

---

## 🗄️ Supabase PostgreSQL सोबत कसे कनेक्ट करावे?

सध्या backend तात्पुरत्या **SQLite** डेटाबेसवर चालू आहे जेणेकरून तुम्ही लगेच टेस्ट करू शकता.
जेव्हा तुम्हाला Supabase कनेक्ट करायचे असेल:

1. [Supabase Dashboard](https://supabase.com) वर जाऊन नवीन प्रोजेक्ट तयार करा.
2. **Project Settings** -> **Database** -> **Connection string** (URI) कॉपी करा.
   - Example URI format:
     `postgresql://postgres.[your-project-ref]:[your-password]@aws-0-[region].pooler.supabase.com:6543/postgres`
3. [`backend/.env`](file:///c:/flutter practice/sg car rent app/backend/.env) फाईल उघडा आणि `DATABASE_URL` बदला:
   ```env
   DATABASE_URL=postgresql://postgres.xxx:mypassword@aws-0-ap-south-1.pooler.supabase.com:6543/postgres
   ```
4. Backend रीस्टार्ट करा — सर्व टेबल्स आणि सीड डेटा (Cars & Categories) Supabase मध्ये आपोआप तयार होतील!

---

## 📁 Project Architecture & Folder Structure

```
backend/
├── app/
│   ├── core/
│   │   ├── config.py         # Environment variables & Settings
│   │   ├── security.py       # Bcrypt password hashing & JWT tokens
│   │   └── dependencies.py   # Auth & Admin route guards
│   ├── db/
│   │   ├── database.py       # SQLAlchemy engine & session management
│   │   └── seed.py           # Initial data: Categories, Cars & Demo Users
│   ├── models/               # SQLAlchemy ORM Models
│   │   ├── user.py
│   │   ├── category.py
│   │   ├── car.py
│   │   ├── booking.py
│   │   └── favorite.py
│   ├── schemas/              # Pydantic Schemas (Request/Response validation)
│   │   ├── user.py
│   │   ├── category.py
│   │   ├── car.py
│   │   ├── booking.py
│   │   └── favorite.py
│   ├── routers/              # API Endpoints
│   │   ├── auth.py           # Register, Login, Me, Password Reset
│   │   ├── cars.py           # Cars list, details, search, availability
│   │   ├── categories.py     # Categories & filtered cars
│   │   ├── bookings.py       # Bookings create, my bookings, cancel
│   │   ├── favorites.py      # Wishlist add, remove, view
│   │   ├── users.py          # User profile view, update, delete
│   │   └── admin.py          # Admin fleet & booking management
│   └── main.py               # FastAPI App, CORS & Lifespan
├── requirements.txt
├── .env
└── .env.example
```

---

## 🔑 Pre-seeded Demo Accounts

| Role | Email | Password |
|---|---|---|
| **Admin** | `admin@sgcarrent.com` | `Admin@123` |
| **Demo User** | `sarthak@example.com` | `Sarthak@123` |
