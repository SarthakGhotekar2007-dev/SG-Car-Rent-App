import sys
import os

sys.path.insert(0, r"c:\flutter practice\sg car rent app\backend")
from app.db.database import SessionLocal
from app.models.car import Car

db = SessionLocal()
cars = db.query(Car).all()
car_image_map = {c.name: c.image_url for c in cars}
db.close()

seed_path = r"c:\flutter practice\sg car rent app\backend\app\db\seed.py"
with open(seed_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
current_car_name = None

for line in lines:
    if '"name":' in line:
        # Extract car name
        parts = line.split('"name":')
        if len(parts) > 1:
            name_val = parts[1].strip().strip('",')
            current_car_name = name_val
    elif '"image_url":' in line and current_car_name in car_image_map:
        indent = line[:line.find('"image_url":')]
        new_url = car_image_map[current_car_name]
        line = f'{indent}"image_url": "{new_url}",\n'
    new_lines.append(line)

with open(seed_path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print("Updated backend/app/db/seed.py with all 61 working car images!")
