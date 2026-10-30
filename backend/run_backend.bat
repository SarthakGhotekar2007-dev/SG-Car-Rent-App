@echo off
title SG Car Rent Backend Server
echo Starting SG Car Rent FastAPI Backend Server...
echo Swagger UI will be available at: http://localhost:8000/docs
echo.
call venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
pause
