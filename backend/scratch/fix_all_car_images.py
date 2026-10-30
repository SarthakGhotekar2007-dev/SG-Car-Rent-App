import sys
import os
import re
import json
import urllib.request
import urllib.parse

sys.path.insert(0, r"c:\flutter practice\sg car rent app\backend")
from app.db.database import SessionLocal
from app.models.car import Car

# Precise Wikipedia articles matching the real vehicles
wiki_article_map = {
    'Tesla Model S': 'Tesla_Model_S',
    'BMW M4 Competition': 'BMW_M4',
    'Porsche Taycan': 'Porsche_Taycan',
    'Mercedes AMG GT': 'Mercedes-AMG_GT',
    'Range Rover Velar': 'Range_Rover_Velar',
    'Mercedes-Benz C-Class': 'Mercedes-Benz_C-Class',
    'Hyundai Creta SX': 'Hyundai_Creta',
    'Toyota Fortuner 4x4': 'Toyota_Fortuner',
    'Mahindra Thar 4x4': 'Mahindra_Thar',
    'Mahindra Scorpio-N': 'Mahindra_Scorpio',
    'Mahindra Scorpio S11': 'Mahindra_Scorpio',
    'Mahindra XUV700 AX7': 'Mahindra_XUV700',
    'Mahindra Bolero': 'Mahindra_Bolero',
    'Mahindra Bolero Neo': 'Mahindra_Bolero_Neo',
    'Tata Safari Dark Edition': 'Tata_Safari',
    'Toyota Innova Crysta': 'Toyota_Innova',
    'Toyota Innova Hycross': 'Toyota_Innova',
    'Maruti Suzuki Ertiga': 'Suzuki_Ertiga',
    'Maruti Suzuki XL6': 'Suzuki_XL7',
    'Kia Carens Luxury': 'Kia_Carens',
    'Toyota Rumion': 'Toyota_Rumion',
    'Kia Carnival Limousine': 'Kia_Carnival',
    'Hyundai Verna Turbo': 'Hyundai_Accent',
    'Honda City ZX': 'Honda_City',
    'Maruti Suzuki Dzire': 'Suzuki_Dzire',
    'Honda Amaze VX': 'Honda_Amaze',
    'Hyundai Aura': 'Hyundai_Aura',
    'Volkswagen Virtus GT': 'Volkswagen_Virtus',
    'Skoda Slavia Style': 'Škoda_Slavia',
    'Maruti Suzuki Swift': 'Suzuki_Swift',
    'Maruti Suzuki Baleno': 'Suzuki_Baleno_(2015)',
    'Maruti Suzuki Wagon R': 'Maruti_Suzuki_Wagon_R',
    'Hyundai Grand i10 Nios': 'Hyundai_Grand_i10',
    'Tata Tiago': 'Tata_Tiago',
    'Maruti Suzuki Fronx': 'Suzuki_Fronx',
    'Force Traveller 12 Seater': 'Force_Traveller',
    'Force Traveller 17 Seater': 'Force_Traveller',
    'Force Traveller 20 Seater': 'Force_Traveller',
    'Force Traveller 26 Seater': 'Force_Traveller',
    'Force Urbania 10 Seater': 'Mercedes-Benz_Sprinter',
    'Force Urbania 13 Seater': 'Mercedes-Benz_Sprinter',
    'Force Urbania 17 Seater': 'Mercedes-Benz_Sprinter',
    'Tata Winger Luxury 12S': 'Tata_Winger',
    'Mercedes-Benz E-Class': 'Mercedes-Benz_E-Class',
    'Mercedes-Benz S-Class': 'Mercedes-Benz_S-Class',
    'BMW 3 Series Gran Limousine': 'BMW_3_Series',
    'BMW 5 Series': 'BMW_5_Series',
    'BMW 7 Series': 'BMW_7_Series',
    'Audi A4 Technology': 'Audi_A4',
    'Audi A6 Matrix': 'Audi_A6',
    'Audi A8 L Flagship': 'Audi_A8',
    'Jaguar XF Prestige': 'Jaguar_XF',
    'Mercedes-Benz GLS 450': 'Mercedes-Benz_GLS',
    'BMW X5 xDrive': 'BMW_X5',
    'BMW X7 M Sport': 'BMW_X7',
    'Audi Q7 Quattro': 'Audi_Q7',
    'Land Rover Defender 110': 'Land_Rover_Defender',
    'Range Rover Autobiography': 'Range_Rover',
    'Volvo XC90 Inscription': 'Volvo_XC90',
    'Toyota Vellfire VIP Lounge': 'Toyota_Alphard',
    'Kia Carnival Executive Lounge': 'Kia_Carnival'
}

def verify_url(url: str) -> bool:
    try:
        req = urllib.request.Request(
            url,
            headers={
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
                'Origin': 'http://localhost:56931'
            }
        )
        with urllib.request.urlopen(req, timeout=8) as resp:
            content_type = resp.headers.get('Content-Type', '')
            if resp.status == 200 and 'image' in content_type:
                return True
    except Exception as e:
        print(f"URL check failed for {url[:50]}: {e}")
    return False

def get_wiki_thumbnail(article: str):
    quoted = urllib.parse.quote(article)
    api_url = f"https://en.wikipedia.org/api/rest_v1/page/summary/{quoted}"
    req = urllib.request.Request(api_url, headers={'User-Agent': 'SGCarRent/1.0 (info@sgcarrent.com)'})
    try:
        with urllib.request.urlopen(req, timeout=8) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            src = data.get('thumbnail', {}).get('source')
            if src:
                # Strip utm params if present, keep pure valid thumbnail
                clean_src = src.split('?')[0]
                return clean_src
    except Exception as e:
        print(f"Error fetching wiki summary for {article}: {e}")
    return None

def main():
    db = SessionLocal()
    try:
        cars = db.query(Car).order_by(Car.id).all()
        print(f"Found {len(cars)} cars in database.")

        cache = {}
        updated_records = 0

        for car in cars:
            article = wiki_article_map.get(car.name)
            if not article:
                print(f"Skipping {car.name} - no mapping")
                continue

            if article in cache:
                img_url = cache[article]
            else:
                img_url = get_wiki_thumbnail(article)
                if img_url:
                    # Verify thumbnail returns 200
                    if verify_url(img_url):
                        cache[article] = img_url
                        print(f"Verified OK: {car.name} -> {img_url}")
                    else:
                        print(f"Verification failed for {car.name}")
                        img_url = None

            if img_url:
                car.image_url = img_url
                updated_records += 1
            else:
                print(f"WARNING: Could not update image for {car.name}")

        db.commit()
        print(f"\nSUCCESS: Successfully updated {updated_records}/{len(cars)} cars in database!")

        # Also let's print a few sample cars to verify
        print("\nVerification samples:")
        sample_names = ['Maruti Suzuki Wagon R', 'Maruti Suzuki Baleno', 'Hyundai Grand i10 Nios', 'Toyota Fortuner 4x4', 'Mahindra Thar 4x4']
        for s in db.query(Car).filter(Car.name.in_(sample_names)).all():
            print(f"- {s.name}: {s.image_url}")

    finally:
        db.close()

if __name__ == '__main__':
    main()
