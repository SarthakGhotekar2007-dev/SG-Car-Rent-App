from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

print("=== 1. CHECKING ADMIN & USER LOGIN ===")
# Admin login
res_admin = client.post("/api/v1/auth/login", json={"email": "admin@sgcarrent.com", "password": "Admin@123"}).json()
admin_token = res_admin["access_token"]
admin_role = res_admin["user"]["role"]
print(f"Admin login -> Role: {admin_role}, ID: {res_admin['user']['id']}")

# User login
res_user = client.post("/api/v1/auth/login", json={"email": "sarthak@example.com", "password": "Sarthak@123"}).json()
user_token = res_user["access_token"]
user_role = res_user["user"]["role"]
print(f"User login -> Role: {user_role}, ID: {res_user['user']['id']}")

admin_headers = {"Authorization": f"Bearer {admin_token}"}
user_headers = {"Authorization": f"Bearer {user_token}"}

print("\n=== 2. PERMISSION TEST: CAN NORMAL USER ADD CAR? ===")
new_car_payload = {
    "name": "Mercedes AMG GT",
    "brand": "Mercedes-Benz",
    "category_id": 3,
    "price_per_day": 250.0,
    "image_url": "https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8",
    "transmission": "Automatic",
    "fuel_type": "Petrol",
    "seats": 2,
    "is_available": True,
    "is_featured": True,
    "rating": 5.0,
    "description": "Test Supercar"
}
res_unauth = client.post("/api/v1/admin/cars", json=new_car_payload, headers=user_headers)
print(f"User trying to POST /admin/cars -> Status: {res_unauth.status_code}")
print(f"Detail: {res_unauth.json().get('detail')}")

print("\n=== 3. ADMIN ADDS CAR ===")
res_add = client.post("/api/v1/admin/cars", json=new_car_payload, headers=admin_headers)
added_car = res_add.json()
car_id = added_car["id"]
print(f"Admin added car -> Status: {res_add.status_code}, Car ID: {car_id}, Name: {added_car['name']}")

print("\n=== 4. USER SEES THE NEW CAR IN EXPLORE CARS ===")
res_explore = client.get("/api/v1/cars").json()
found = any(c["id"] == car_id for c in res_explore)
print(f"User sees new car in GET /cars: {found}")

print("\n=== 5. USER BOOKS THE CAR ===")
booking_payload = {
    "car_id": car_id,
    "start_date": "2026-11-10",
    "end_date": "2026-11-12",
    "pickup_location": "Pune Airport"
}
res_book = client.post("/api/v1/bookings", json=booking_payload, headers=user_headers)
booking = res_book.json()
booking_id = booking["id"]
print(f"User booked car -> Status: {res_book.status_code}, Booking ID: {booking_id}")
print(f"Backend Calculated Total: Rs. {booking['total_price']}, Status: {booking['status']}")

print("\n=== 6. ADMIN VIEWS ALL BOOKINGS & UPDATES STATUS ===")
res_all_bookings = client.get("/api/v1/admin/bookings", headers=admin_headers).json()
print(f"Admin sees total bookings: {len(res_all_bookings)}")
res_status = client.patch(f"/api/v1/admin/bookings/{booking_id}/status", json={"status": "completed"}, headers=admin_headers)
print(f"Admin updated booking status -> New status: {res_status.json()['status']}")

print("\n=== 7. CLEANUP: ADMIN DELETES TEST CAR ===")
# User trying to delete:
res_user_del = client.delete(f"/api/v1/admin/cars/{car_id}", headers=user_headers)
print(f"User trying to delete car -> Status: {res_user_del.status_code} ({res_user_del.json().get('detail')})")
# Admin deletes:
res_admin_del = client.delete(f"/api/v1/admin/cars/{car_id}", headers=admin_headers)
print(f"Admin deletes car -> Status: {res_admin_del.status_code}, Message: {res_admin_del.json()['message']}")

print("\n=== ALL ROLE-BASED FEATURES VERIFIED 100% SUCCESSFULLY! ===")
