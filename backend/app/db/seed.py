from sqlalchemy.orm import Session
from app.models.category import Category
from app.models.car import Car
from app.models.user import User
from app.core.security import hash_password

categories_data = [
    {
        "name": "SUV",
        "slug": "suv",
        "description": "Powerful SUVs for rugged terrains, family outings, and highway drives",
        "icon_name": "airport_shuttle"
    },
    {
        "name": "Family / MUV",
        "slug": "family_muv",
        "description": "Spacious and comfortable multi-utility vehicles for tours and large families",
        "icon_name": "people_outline"
    },
    {
        "name": "Sedan",
        "slug": "sedan",
        "description": "Smooth, elegant, and fuel-efficient sedans for city and executive travel",
        "icon_name": "directions_car_filled"
    },
    {
        "name": "Hatchback",
        "slug": "hatchback",
        "description": "Compact, agile, and budget-friendly hatchbacks for convenient city commute",
        "icon_name": "time_to_leave"
    },
    {
        "name": "Tempo Traveller",
        "slug": "tempo_traveller",
        "description": "High-capacity passenger vans and travellers for group tours and pilgrimages",
        "icon_name": "directions_bus"
    },
    {
        "name": "Luxury Sedan",
        "slug": "luxury_sedan",
        "description": "Elite luxury sedans delivering supreme comfort, status, and VIP chauffeur experience",
        "icon_name": "star"
    },
    {
        "name": "Luxury SUV",
        "slug": "luxury_suv",
        "description": "Commanding flagship luxury SUVs blending ultra-luxury with peerless road presence",
        "icon_name": "terrain"
    },
    {
        "name": "Luxury MPV",
        "slug": "luxury_mpv",
        "description": "First-class luxury MPVs with airline-style lounge seats for VIP delegations",
        "icon_name": "airline_seat_recline_extra"
    },
]

# 2. Comprehensive Car Fleet
cars_data = [
    # ---------------- 1. SUV & Premium SUV ----------------
    {
        "name": "Toyota Fortuner 4x4",
        "brand": "Toyota",
        "category_slug": "suv",
        "price_per_day": 6500.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/66/2015_Toyota_Fortuner_%28New_Zealand%29.jpg/330px-2015_Toyota_Fortuner_%28New_Zealand%29.jpg",
        "transmission": "Automatic",
        "fuel_type": "Diesel",
        "seats": 7,
        "is_available": True,
        "is_featured": True,
        "rating": 4.9,
        "description": "The king of Indian roads. Imposing road presence, 2.8L diesel torque, and 4x4 capability for any terrain."
    },
    {
        "name": "Mahindra Thar 4x4",
        "brand": "Mahindra",
        "category_slug": "suv",
        "price_per_day": 4500.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/51/Mahindra_Thar_SUV_in_%22Red_Rage%22_color_at_Ashiana_Brahmanda%2C_East_Singbhum_India_%28Ank_Kumar%2C_Infosys_limited%29_02_%28cropped%29.jpg/330px-Mahindra_Thar_SUV_in_%22Red_Rage%22_color_at_Ashiana_Brahmanda%2C_East_Singbhum_India_%28Ank_Kumar%2C_Infosys_limited%29_02_%28cropped%29.jpg",
        "transmission": "Manual",
        "fuel_type": "Diesel",
        "seats": 4,
        "is_available": True,
        "is_featured": True,
        "rating": 4.8,
        "description": "Iconic off-roader with convertible/hardtop, high ground clearance, and unmatched adventure appeal."
    },
    {
        "name": "Mahindra Scorpio-N",
        "brand": "Mahindra",
        "category_slug": "suv",
        "price_per_day": 4800.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/5b/Mahindra_Scorpio_GLX_2.6_m-Hawk_2011_%2836756517492%29.jpg/330px-Mahindra_Scorpio_GLX_2.6_m-Hawk_2011_%2836756517492%29.jpg",
        "transmission": "Automatic",
        "fuel_type": "Diesel",
        "seats": 7,
        "is_available": True,
        "is_featured": False,
        "rating": 4.8,
        "description": "Big Daddy of SUVs. Modern styling, punchy mHawk diesel engine, and high seating stance."
    },
    {
        "name": "Mahindra Scorpio S11",
        "brand": "Mahindra",
        "category_slug": "suv",
        "price_per_day": 4000.0,
        "image_url": "https://th.bing.com/th/id/OIP.b5CKsrhokB8jSiPM7bdh4gHaEZ?w=272&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3.jpg",
        "transmission": "Manual",
        "fuel_type": "Diesel",
        "seats": 7,
        "is_available": True,
        "is_featured": False,
        "rating": 4.7,
        "description": "Rugged, raw power with commanding road respect and exceptional highway stability."
    },
    {
        "name": "Mahindra XUV700 AX7",
        "brand": "Mahindra",
        "category_slug": "suv",
        "price_per_day": 5500.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/ba/2021_Mahindra_XUV700_2.2_AX7_%28India%29_front_view.png/330px-2021_Mahindra_XUV700_2.2_AX7_%28India%29_front_view.png",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 7,
        "is_available": True,
        "is_featured": True,
        "rating": 4.9,
        "description": "Tech powerhouse with panoramic skyroof, ADAS features, dual digital screens, and supreme ride comfort."
    },
    {
        "name": "Mahindra Bolero",
        "brand": "Mahindra",
        "category_slug": "suv",
        "price_per_day": 3000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d7/Mahindra_Bolero_ZLX.jpg/330px-Mahindra_Bolero_ZLX.jpg",
        "transmission": "Manual",
        "fuel_type": "Diesel",
        "seats": 7,
        "is_available": True,
        "is_featured": False,
        "rating": 4.6,
        "description": "India's workhorse SUV. Dependable, economical, heavy-duty metal body, built for rural and mountain roads."
    },
    {
        "name": "Mahindra Bolero Neo",
        "brand": "Mahindra",
        "category_slug": "suv",
        "price_per_day": 3200.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/5b/Mahindra_TUV_300_Chennai_2016_%282%29.JPG/330px-Mahindra_TUV_300_Chennai_2016_%282%29.JPG",
        "transmission": "Manual",
        "fuel_type": "Diesel",
        "seats": 7,
        "is_available": True,
        "is_featured": False,
        "rating": 4.6,
        "description": "Modern Bolero with stylish headlamps, comfortable cabin, and rear-wheel-drive toughness."
    },
    {
        "name": "Tata Safari Dark Edition",
        "brand": "Tata",
        "category_slug": "suv",
        "price_per_day": 5200.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/3d/Tata_Safari_II_front_-_PSM_2009.jpg/330px-Tata_Safari_II_front_-_PSM_2009.jpg",
        "transmission": "Automatic",
        "fuel_type": "Diesel",
        "seats": 7,
        "is_available": True,
        "is_featured": False,
        "rating": 4.8,
        "description": "Majestic flagship SUV with Land Rover-derived D8 platform, captain seats, and sinister dark styling."
    },
    {
        "name": "Hyundai Creta SX",
        "brand": "Hyundai",
        "category_slug": "suv",
        "price_per_day": 3500.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/2/21/2024_Hyundai_Creta_1.5_MPi_SX%28O%29_%28India%29_front_view.png/330px-2024_Hyundai_Creta_1.5_MPi_SX%28O%29_%28India%29_front_view.png",
        "transmission": "Automatic",
        "fuel_type": "Diesel",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.7,
        "description": "Smooth driving dynamics, panoramic sunroof, ventilated front seats, and best-in-class comfort."
    },

    # ---------------- 2. Family & Tourist Cars (MUV) ----------------
    {
        "name": "Toyota Innova Crysta",
        "brand": "Toyota",
        "category_slug": "family_muv",
        "price_per_day": 5000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/36/Toyota_Innova_Zenix_2.0_V_%28III%29_%E2%80%93_f_22032025.jpg/330px-Toyota_Innova_Zenix_2.0_V_%28III%29_%E2%80%93_f_22032025.jpg",
        "transmission": "Manual",
        "fuel_type": "Diesel",
        "seats": 7,
        "is_available": True,
        "is_featured": True,
        "rating": 4.9,
        "description": "The gold standard for long-distance family touring in India. Unmatched reliability and ride comfort."
    },
    {
        "name": "Toyota Innova Hycross",
        "brand": "Toyota",
        "category_slug": "family_muv",
        "price_per_day": 6000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/36/Toyota_Innova_Zenix_2.0_V_%28III%29_%E2%80%93_f_22032025.jpg/330px-Toyota_Innova_Zenix_2.0_V_%28III%29_%E2%80%93_f_22032025.jpg",
        "transmission": "Automatic",
        "fuel_type": "Hybrid",
        "seats": 7,
        "is_available": True,
        "is_featured": True,
        "rating": 5.0,
        "description": "Next-gen hybrid MPV with ottoman captain seats, ultra-silent electric-hybrid drive, and huge panoramic roof."
    },
    {
        "name": "Maruti Suzuki Ertiga",
        "brand": "Maruti Suzuki",
        "category_slug": "family_muv",
        "price_per_day": 3200.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f9/Suzuki_Ertiga_NC_FL_1.5_GLX_Hybrid_Snow_White_Pearl.jpg/330px-Suzuki_Ertiga_NC_FL_1.5_GLX_Hybrid_Snow_White_Pearl.jpg",
        "transmission": "Manual",
        "fuel_type": "Petrol",
        "seats": 7,
        "is_available": True,
        "is_featured": False,
        "rating": 4.7,
        "description": "Budget-friendly 7-seater MPV with great fuel economy, chilled AC vents for all rows, and ample legroom."
    },
    {
        "name": "Maruti Suzuki XL6",
        "brand": "Maruti Suzuki",
        "category_slug": "family_muv",
        "price_per_day": 3800.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f9/Suzuki_Ertiga_NC_FL_1.5_GLX_Hybrid_Snow_White_Pearl.jpg/330px-Suzuki_Ertiga_NC_FL_1.5_GLX_Hybrid_Snow_White_Pearl.jpg",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 6,
        "is_available": True,
        "is_featured": False,
        "rating": 4.7,
        "description": "Premium 6-seater MPV with dedicated second-row captain seats, ventilated seats, and modern styling."
    },
    {
        "name": "Kia Carens Luxury",
        "brand": "Kia",
        "category_slug": "family_muv",
        "price_per_day": 4200.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/30/2016_Kia_Rondo_LX_Value_in_Sterling_Metallic%2C_Front_Right%2C_05-18-2023.jpg/330px-2016_Kia_Rondo_LX_Value_in_Sterling_Metallic%2C_Front_Right%2C_05-18-2023.jpg",
        "transmission": "Automatic",
        "fuel_type": "Diesel",
        "seats": 7,
        "is_available": True,
        "is_featured": False,
        "rating": 4.8,
        "description": "Modern recreational vehicle with Bose audio, air purifier, one-touch electric tumble seats, and plush ride."
    },
    {
        "name": "Toyota Rumion",
        "brand": "Toyota",
        "category_slug": "family_muv",
        "price_per_day": 3400.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f9/Suzuki_Ertiga_NC_FL_1.5_GLX_Hybrid_Snow_White_Pearl.jpg/330px-Suzuki_Ertiga_NC_FL_1.5_GLX_Hybrid_Snow_White_Pearl.jpg",
        "transmission": "Manual",
        "fuel_type": "Petrol",
        "seats": 7,
        "is_available": True,
        "is_featured": False,
        "rating": 4.6,
        "description": "Toyota backed 7-seater MPV offering spacious cabin, smooth engine, and hassle-free long distance journeys."
    },
    {
        "name": "Kia Carnival Limousine",
        "brand": "Kia",
        "category_slug": "family_muv",
        "price_per_day": 8500.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a7/2025_Kia_Carnival_Hybrid_EX%2C_front_right%2C_10-12-2025.jpg/330px-2025_Kia_Carnival_Hybrid_EX%2C_front_right%2C_10-12-2025.jpg",
        "transmission": "Automatic",
        "fuel_type": "Diesel",
        "seats": 7,
        "is_available": True,
        "is_featured": True,
        "rating": 4.9,
        "description": "Private jet on wheels with dual sunroofs, rear entertainment screens, and VIP lounge reclining seats."
    },

    # ---------------- 3. Sedan Cars ----------------
    {
        "name": "Hyundai Verna Turbo",
        "brand": "Hyundai",
        "category_slug": "sedan",
        "price_per_day": 3800.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9d/2019_Hyundai_Accent_1.6L%2C_front_10.8.19.jpg/330px-2019_Hyundai_Accent_1.6L%2C_front_10.8.19.jpg",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.8,
        "description": "Futuristic fastback styling, 160 PS turbo petrol thrust, and 5-star safety rating."
    },
    {
        "name": "Honda City ZX",
        "brand": "Honda",
        "category_slug": "sedan",
        "price_per_day": 3600.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e7/Honda_City_1.5_i-VTEC_V_%28VIII%2C_Facelift%29_%E2%80%93_f_22032025.jpg/330px-Honda_City_1.5_i-VTEC_V_%28VIII%2C_Facelift%29_%E2%80%93_f_22032025.jpg",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.8,
        "description": "India's beloved executive sedan. Silky smooth i-VTEC engine, premium leather cabin, and sofa-like rear seat."
    },
    {
        "name": "Maruti Suzuki Dzire",
        "brand": "Maruti Suzuki",
        "category_slug": "sedan",
        "price_per_day": 2500.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e7/Suzuki_Dzire_II_1.2_GLX_Hybrid_Arctic_White_Pearl.jpg/330px-Suzuki_Dzire_II_1.2_GLX_Hybrid_Arctic_White_Pearl.jpg",
        "transmission": "Manual",
        "fuel_type": "Petrol",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.7,
        "description": "Best compact sedan for city and outstation. Exceptional mileage and effortless maneuverability."
    },
    {
        "name": "Honda Amaze VX",
        "brand": "Honda",
        "category_slug": "sedan",
        "price_per_day": 2600.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f4/Honda_Amaze_%28front%29.png/330px-Honda_Amaze_%28front%29.png",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.6,
        "description": "Spacious family sedan with smooth CVT automatic transmission and huge 420-litre boot space."
    },
    {
        "name": "Hyundai Aura",
        "brand": "Hyundai",
        "category_slug": "sedan",
        "price_per_day": 2400.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bd/Hyundai_Grand_i10_Sedan_2022_%2853703857804%29_%28cropped%29.jpg/330px-Hyundai_Grand_i10_Sedan_2022_%2853703857804%29_%28cropped%29.jpg",
        "transmission": "Manual",
        "fuel_type": "CNG",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.5,
        "description": "Economical compact sedan with wireless charging, cooled glovebox, and low running costs."
    },
    {
        "name": "Volkswagen Virtus GT",
        "brand": "Volkswagen",
        "category_slug": "sedan",
        "price_per_day": 4200.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9e/2022_Volkswagen_Virtus_1.5_GT_%28India%29_front_view_02.png/330px-2022_Volkswagen_Virtus_1.5_GT_%28India%29_front_view_02.png",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 5,
        "is_available": True,
        "is_featured": True,
        "rating": 4.9,
        "description": "German engineering marvel. 1.5 TSI Evo engine with DSG, 5-star crash safety, and high-speed cornering stability."
    },
    {
        "name": "Skoda Slavia Style",
        "brand": "Skoda",
        "category_slug": "sedan",
        "price_per_day": 4000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/92/2021_%C5%A0koda_Slavia_1.5_TSI_Style_%28India%29_front_view.png/330px-2021_%C5%A0koda_Slavia_1.5_TSI_Style_%28India%29_front_view.png",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.8,
        "description": "Sophisticated European styling, large 521-litre boot, ventilated front seats, and crisp driving response."
    },

    # ---------------- 4. Budget Rental Cars (Hatchback) ----------------
    {
        "name": "Maruti Suzuki Swift",
        "brand": "Maruti Suzuki",
        "category_slug": "hatchback",
        "price_per_day": 2000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/3d/Suzuki_Swift_%282024%29_hybrid_DSC_6076.jpg/330px-Suzuki_Swift_%282024%29_hybrid_DSC_6076.jpg",
        "transmission": "Manual",
        "fuel_type": "Petrol",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.7,
        "description": "India's favorite sporty hatchback. Zippy driving feel, superb mileage, and easy parking everywhere."
    },
    {
        "name": "Maruti Suzuki Baleno",
        "brand": "Maruti Suzuki",
        "category_slug": "hatchback",
        "price_per_day": 2300.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/96/2017_Suzuki_Baleno_SZ3_Dualjet_1.2_Front.jpg/330px-2017_Suzuki_Baleno_SZ3_Dualjet_1.2_Front.jpg",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.7,
        "description": "Premium hatchback with Heads-Up Display, 360-degree camera, and wide comfortable rear seating."
    },
    {
        "name": "Maruti Suzuki Wagon R",
        "brand": "Maruti Suzuki",
        "category_slug": "hatchback",
        "price_per_day": 1800.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d7/2018_Suzuki_Karimun_Wagon_R_GL_%28front%29.jpg/330px-2018_Suzuki_Karimun_Wagon_R_GL_%28front%29.jpg",
        "transmission": "Manual",
        "fuel_type": "CNG",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.5,
        "description": "Tall-boy design offering massive headroom, low rental price, and unbeatable city efficiency."
    },
    {
        "name": "Hyundai Grand i10 Nios",
        "brand": "Hyundai",
        "category_slug": "hatchback",
        "price_per_day": 2100.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/44/Hyundai_i10_1.0_Intro_%28III%29_%E2%80%93_f_03012021.jpg/330px-Hyundai_i10_1.0_Intro_%28III%29_%E2%80%93_f_03012021.jpg",
        "transmission": "Manual",
        "fuel_type": "Petrol",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.6,
        "description": "Refined city hatchback with premium dual-tone interior, touchscreen infotainment, and smooth clutch."
    },
    {
        "name": "Tata Tiago",
        "brand": "Tata",
        "category_slug": "hatchback",
        "price_per_day": 1900.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/c/ca/2022_Tata_Tiago_XZA%2B_front_20230512.jpg/330px-2022_Tata_Tiago_XZA%2B_front_20230512.jpg",
        "transmission": "Manual",
        "fuel_type": "Petrol",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.6,
        "description": "Solid build quality, 4-star Global NCAP safety, Harman 8-speaker audio, and dependable handling."
    },
    {
        "name": "Maruti Suzuki Fronx",
        "brand": "Maruti Suzuki",
        "category_slug": "hatchback",
        "price_per_day": 2800.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/80/2024_Suzuki_Fronx.jpg/330px-2024_Suzuki_Fronx.jpg",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.8,
        "description": "Crossover SUV styling with aerodynamic coupe roofline, turbo boosterjet engine, and high ground clearance."
    },

    # ---------------- 5. Tempo Traveller & Group Rental ----------------
    {
        "name": "Force Traveller 12 Seater",
        "brand": "Force Motors",
        "category_slug": "tempo_traveller",
        "price_per_day": 7000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/13/IMG-20190215-WA0015.jpg/330px-IMG-20190215-WA0015.jpg",
        "transmission": "Manual",
        "fuel_type": "Diesel",
        "seats": 12,
        "is_available": True,
        "is_featured": True,
        "rating": 4.8,
        "description": "Ideal for medium groups, family weddings, and pilgrimage tours. 1x1 pushback seats with dedicated AC vents."
    },
    {
        "name": "Force Traveller 17 Seater",
        "brand": "Force Motors",
        "category_slug": "tempo_traveller",
        "price_per_day": 8500.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/13/IMG-20190215-WA0015.jpg/330px-IMG-20190215-WA0015.jpg",
        "transmission": "Manual",
        "fuel_type": "Diesel",
        "seats": 17,
        "is_available": True,
        "is_featured": True,
        "rating": 4.9,
        "description": "Spacious 17-seater group carrier with wide aisle, comfortable pushback seats, and huge boot for luggage."
    },
    {
        "name": "Force Traveller 20 Seater",
        "brand": "Force Motors",
        "category_slug": "tempo_traveller",
        "price_per_day": 10000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/13/IMG-20190215-WA0015.jpg/330px-IMG-20190215-WA0015.jpg",
        "transmission": "Manual",
        "fuel_type": "Diesel",
        "seats": 20,
        "is_available": True,
        "is_featured": False,
        "rating": 4.8,
        "description": "Heavy-duty 20-seater passenger van designed for corporate offsites, school trips, and pilgrimage tours."
    },
    {
        "name": "Force Traveller 26 Seater",
        "brand": "Force Motors",
        "category_slug": "tempo_traveller",
        "price_per_day": 12500.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/13/IMG-20190215-WA0015.jpg/330px-IMG-20190215-WA0015.jpg",
        "transmission": "Manual",
        "fuel_type": "Diesel",
        "seats": 26,
        "is_available": True,
        "is_featured": False,
        "rating": 4.7,
        "description": "Maximum group capacity with mini-bus comfort, Mercedes-derived FM2.6 CR ED diesel engine, and high roof."
    },
    {
        "name": "Force Urbania 10 Seater",
        "brand": "Force Motors",
        "category_slug": "tempo_traveller",
        "price_per_day": 9500.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a2/2019_Mercedes-Benz_Sprinter_314_CDi_2.1.jpg/330px-2019_Mercedes-Benz_Sprinter_314_CDi_2.1.jpg",
        "transmission": "Manual",
        "fuel_type": "Diesel",
        "seats": 10,
        "is_available": True,
        "is_featured": True,
        "rating": 4.9,
        "description": "Next-gen luxury van with European styling, ultra-quiet cabin, reclining lounge seats, and individual USB ports."
    },
    {
        "name": "Force Urbania 13 Seater",
        "brand": "Force Motors",
        "category_slug": "tempo_traveller",
        "price_per_day": 11000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a2/2019_Mercedes-Benz_Sprinter_314_CDi_2.1.jpg/330px-2019_Mercedes-Benz_Sprinter_314_CDi_2.1.jpg",
        "transmission": "Manual",
        "fuel_type": "Diesel",
        "seats": 13,
        "is_available": True,
        "is_featured": False,
        "rating": 4.9,
        "description": "13-seater executive van with projector headlamps, dual airbags, hill hold assist, and business-class seating."
    },
    {
        "name": "Force Urbania 17 Seater",
        "brand": "Force Motors",
        "category_slug": "tempo_traveller",
        "price_per_day": 13000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a2/2019_Mercedes-Benz_Sprinter_314_CDi_2.1.jpg/330px-2019_Mercedes-Benz_Sprinter_314_CDi_2.1.jpg",
        "transmission": "Manual",
        "fuel_type": "Diesel",
        "seats": 17,
        "is_available": True,
        "is_featured": False,
        "rating": 4.9,
        "description": "Flagship 17-seater Urbania luxury van offering airplane-style overhead AC ducting and unmatched ride plushness."
    },
    {
        "name": "Tata Winger Luxury 12S",
        "brand": "Tata",
        "category_slug": "tempo_traveller",
        "price_per_day": 6800.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/1c/Tata_Winger_van%2C_Bangladesh._%2833029016652%29_%28cropped%29.jpg/330px-Tata_Winger_van%2C_Bangladesh._%2833029016652%29_%28cropped%29.jpg",
        "transmission": "Manual",
        "fuel_type": "Diesel",
        "seats": 12,
        "is_available": True,
        "is_featured": False,
        "rating": 4.6,
        "description": "Monocoque body construction for car-like ride comfort, low floor height for easy ingress, and twin AC units."
    },

    # ---------------- 6. Luxury Sedan ----------------
    {
        "name": "Mercedes-Benz E-Class",
        "brand": "Mercedes-Benz",
        "category_slug": "luxury_sedan",
        "price_per_day": 14000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/fd/Mercedes-Benz_W214_1X7A1841.jpg/330px-Mercedes-Benz_W214_1X7A1841.jpg",
        "transmission": "Automatic",
        "fuel_type": "Diesel",
        "seats": 5,
        "is_available": True,
        "is_featured": True,
        "rating": 4.9,
        "description": "Long wheelbase luxury sedan for VIP business executives. Reclining rear seats, Burmester 3D audio, and ambient lighting."
    },
    {
        "name": "Mercedes-Benz S-Class",
        "brand": "Mercedes-Benz",
        "category_slug": "luxury_sedan",
        "price_per_day": 28000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/55/Mercedes-Benz_W223_IMG_6663.jpg/330px-Mercedes-Benz_W223_IMG_6663.jpg",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 4,
        "is_available": True,
        "is_featured": True,
        "rating": 5.0,
        "description": "The best car in the world. First-class rear suite with calf massage, OLED touchscreens, and whisper-quiet V8 engine."
    },
    {
        "name": "Mercedes-Benz C-Class",
        "brand": "Mercedes-Benz",
        "category_slug": "luxury_sedan",
        "price_per_day": 9500.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/be/Mercedes-Benz_W206_IMG_6380.jpg/330px-Mercedes-Benz_W206_IMG_6380.jpg",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.7,
        "description": "Baby S-Class. Sleek exterior, portrait touchscreen, AMG-line styling, and effortless luxury cruiser."
    },
    {
        "name": "BMW 3 Series Gran Limousine",
        "brand": "BMW",
        "category_slug": "luxury_sedan",
        "price_per_day": 10000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/91/BMW_G20_%282022%29_IMG_7316_%282%29.jpg/330px-BMW_G20_%282022%29_IMG_7316_%282%29.jpg",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.8,
        "description": "Extended wheelbase 3-series combining sporty rear-wheel-drive dynamics with generous rear knee room."
    },
    {
        "name": "BMW 5 Series",
        "brand": "BMW",
        "category_slug": "luxury_sedan",
        "price_per_day": 15000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/86/BMW_G60_520i_1X7A2443.jpg/330px-BMW_G60_520i_1X7A2443.jpg",
        "transmission": "Automatic",
        "fuel_type": "Diesel",
        "seats": 5,
        "is_available": True,
        "is_featured": True,
        "rating": 4.9,
        "description": "Dynamic luxury business sedan with laser lights, gesture controls, and legendary BMW TwinPower Turbo power."
    },
    {
        "name": "BMW 7 Series",
        "brand": "BMW",
        "category_slug": "luxury_sedan",
        "price_per_day": 30000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/97/BMW_730d_%28G11%2C_Facelift%29_%E2%80%93_f_16012021.jpg/330px-BMW_730d_%28G11%2C_Facelift%29_%E2%80%93_f_16012021.jpg",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 4,
        "is_available": True,
        "is_featured": True,
        "rating": 5.0,
        "description": "Futuristic flagship with illuminated kidney grille, 31.3-inch 8K BMW Theatre Screen in the rear, and sky lounge."
    },
    {
        "name": "Audi A4 Technology",
        "brand": "Audi",
        "category_slug": "luxury_sedan",
        "price_per_day": 9000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/35/Audi_A4_B9_sedans_%28FL%29_1X7A2441.jpg/330px-Audi_A4_B9_sedans_%28FL%29_1X7A2441.jpg",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.7,
        "description": "Audi Virtual Cockpit, Matrix LED lighting, Bang & Olufsen sound, and whisper-silent acoustic glass."
    },
    {
        "name": "Audi A6 Matrix",
        "brand": "Audi",
        "category_slug": "luxury_sedan",
        "price_per_day": 13500.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/eb/Audi_A6_C9_IAA_2025_DSC_1920.jpg/330px-Audi_A6_C9_IAA_2025_DSC_1920.jpg",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.8,
        "description": "Sharp styling with twin touchscreens, progressive steering, 4-zone climate control, and smooth air suspension."
    },
    {
        "name": "Audi A8 L Flagship",
        "brand": "Audi",
        "category_slug": "luxury_sedan",
        "price_per_day": 26000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/31/2018_Audi_A8_50_TDi_Quattro_Automatic_3.0.jpg/330px-2018_Audi_A8_50_TDi_Quattro_Automatic_3.0.jpg",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 4,
        "is_available": True,
        "is_featured": True,
        "rating": 4.9,
        "description": "Presidential luxury with foot massage rear relaxation seats, predictive active suspension, and all-wheel steering."
    },
    {
        "name": "Jaguar XF Prestige",
        "brand": "Jaguar",
        "category_slug": "luxury_sedan",
        "price_per_day": 12000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/37/Jaguar_XF_--_11-26-2011.jpg/330px-Jaguar_XF_--_11-26-2011.jpg",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 5,
        "is_available": True,
        "is_featured": False,
        "rating": 4.8,
        "description": "Distinct British luxury with lightweight aluminum architecture, Meridian sound system, and cat-like agility."
    },

    # ---------------- 7. Luxury SUV ----------------
    {
        "name": "Mercedes-Benz GLS 450",
        "brand": "Mercedes-Benz",
        "category_slug": "luxury_suv",
        "price_per_day": 24000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4a/Mercedes-Benz_X167_IMG_5259.jpg/330px-Mercedes-Benz_X167_IMG_5259.jpg",
        "transmission": "Automatic",
        "fuel_type": "Diesel",
        "seats": 7,
        "is_available": True,
        "is_featured": True,
        "rating": 5.0,
        "description": "The S-Class of SUVs. Majestic 7-seater luxury with E-Active Body Control, soft-close doors, and heated armrests."
    },
    {
        "name": "BMW X5 xDrive",
        "brand": "BMW",
        "category_slug": "luxury_suv",
        "price_per_day": 18000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f1/2019_BMW_X5_M50d_Automatic_3.0.jpg/330px-2019_BMW_X5_M50d_Automatic_3.0.jpg",
        "transmission": "Automatic",
        "fuel_type": "Diesel",
        "seats": 5,
        "is_available": True,
        "is_featured": True,
        "rating": 4.9,
        "description": "The ultimate sports activity vehicle. 6-cylinder diesel thrust, split tailgate, and panoramic sky lounge."
    },
    {
        "name": "BMW X7 M Sport",
        "brand": "BMW",
        "category_slug": "luxury_suv",
        "price_per_day": 26000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/00/BMW_G07_1X7A1696.jpg/330px-BMW_G07_1X7A1696.jpg",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 7,
        "is_available": True,
        "is_featured": True,
        "rating": 5.0,
        "description": "Colossal luxury SUV with illuminated kidney grille, 3-row glass panoramic sunroof, and air suspension."
    },
    {
        "name": "Audi Q7 Quattro",
        "brand": "Audi",
        "category_slug": "luxury_suv",
        "price_per_day": 17000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/5f/Audi_Q7_4M_FL2_3.0_V6_MHEV_quattro_Satellite_Silver_Metallic_01_%28cropped%29.jpg/330px-Audi_Q7_4M_FL2_3.0_V6_MHEV_quattro_Satellite_Silver_Metallic_01_%28cropped%29.jpg",
        "transmission": "Automatic",
        "fuel_type": "Diesel",
        "seats": 7,
        "is_available": True,
        "is_featured": False,
        "rating": 4.8,
        "description": "Versatile 7-seater luxury with Quattro all-wheel drive, adaptive air suspension, and Matrix LED headlamps."
    },
    {
        "name": "Land Rover Defender 110",
        "brand": "Land Rover",
        "category_slug": "luxury_suv",
        "price_per_day": 22000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/41/2015_Land_Rover_Defender_%28L316_MY15%29_90_3-door_wagon_%282015-10-24%29_01.jpg/330px-2015_Land_Rover_Defender_%28L316_MY15%29_90_3-door_wagon_%282015-10-24%29_01.jpg",
        "transmission": "Automatic",
        "fuel_type": "Petrol",
        "seats": 5,
        "is_available": True,
        "is_featured": True,
        "rating": 4.9,
        "description": "Unstoppable luxury off-roader with air suspension, Terrain Response 2, 900mm water wading, and rugged luxury."
    },
    {
        "name": "Range Rover Velar",
        "brand": "Range Rover",
        "category_slug": "luxury_suv",
        "price_per_day": 18000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9d/2017_Land_Rover_Range_Rover_Velar_First_Edition_D3_3.0_Front.jpg/330px-2017_Land_Rover_Range_Rover_Velar_First_Edition_D3_3.0_Front.jpg",
        "transmission": "Automatic",
        "fuel_type": "Diesel",
        "seats": 5,
        "is_available": True,
        "is_featured": True,
        "rating": 4.9,
        "description": "Minimalist British luxury SUV with flush deployable handles, Meridian 3D sound, and floating roof design."
    },
    {
        "name": "Range Rover Autobiography",
        "brand": "Range Rover",
        "category_slug": "luxury_suv",
        "price_per_day": 35000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/17/2022_Land_Rover_Range_Rover_SE_P440e_AWD_Automatic_3.0_Front.jpg/330px-2022_Land_Rover_Range_Rover_SE_P440e_AWD_Automatic_3.0_Front.jpg",
        "transmission": "Automatic",
        "fuel_type": "Diesel",
        "seats": 5,
        "is_available": True,
        "is_featured": True,
        "rating": 5.0,
        "description": "Pinnacle of luxury SUVs worldwide. Executive Class rear seating, active noise cancellation, and unmatched royal status."
    },
    {
        "name": "Volvo XC90 Inscription",
        "brand": "Volvo",
        "category_slug": "luxury_suv",
        "price_per_day": 19000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/2/23/Volvo_XC90_T8_AWD_Plug-in_Hybrid_Plus_%28II%2C_2._Facelift%29_%E2%80%93_f_03102025.jpg/330px-Volvo_XC90_T8_AWD_Plug-in_Hybrid_Plus_%28II%2C_2._Facelift%29_%E2%80%93_f_03102025.jpg",
        "transmission": "Automatic",
        "fuel_type": "Hybrid",
        "seats": 7,
        "is_available": True,
        "is_featured": False,
        "rating": 4.9,
        "description": "Scandinavian sanctuary. Orrefors crystal gear shifter, Bowers & Wilkins sound, world-benchmark safety, and 7 seats."
    },

    # ---------------- 8. Luxury MPV ----------------
    {
        "name": "Toyota Vellfire VIP Lounge",
        "brand": "Toyota",
        "category_slug": "luxury_mpv",
        "price_per_day": 25000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b7/Toyota_ALPHARD_Z_%28AGH40W%29.jpg/330px-Toyota_ALPHARD_Z_%28AGH40W%29.jpg",
        "transmission": "Automatic",
        "fuel_type": "Hybrid",
        "seats": 7,
        "is_available": True,
        "is_featured": True,
        "rating": 5.0,
        "description": "Thrones for seats. Executive lounge ottoman captain seats with heating/cooling, power sunshades, and VIP privacy."
    },
    {
        "name": "Kia Carnival Executive Lounge",
        "brand": "Kia",
        "category_slug": "luxury_mpv",
        "price_per_day": 12000.0,
        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a7/2025_Kia_Carnival_Hybrid_EX%2C_front_right%2C_10-12-2025.jpg/330px-2025_Kia_Carnival_Hybrid_EX%2C_front_right%2C_10-12-2025.jpg",
        "transmission": "Automatic",
        "fuel_type": "Diesel",
        "seats": 7,
        "is_available": True,
        "is_featured": True,
        "rating": 4.9,
        "description": "Ultra luxury family & corporate cruiser with twin electric sunroofs, Harman Kardon audio, and power sliding doors."
    },
]

def seed_database(db: Session):
    """Seed categories, cars, and default demo users if tables are empty"""
    # 1. Seed Categories
    if db.query(Category).count() == 0:
        for cdata in categories_data:
            cat = Category(
                name=cdata["name"],
                slug=cdata["slug"],
                description=cdata["description"],
                icon_name=cdata["icon_name"]
            )
            db.add(cat)
        db.commit()

    # 2. Seed Users
    if db.query(User).count() == 0:
        admin_user = User(
            name="Sarthak Admin",
            email="admin123@gmail.com",
            hashed_password=hash_password("admin@123"),
            phone="9960442154",
            role="admin"
        )
        demo_user = User(
            name="Sarthak Ghotekar",
            email="sarthak@example.com",
            hashed_password=hash_password("Sarthak@123"),
            phone="8087615815",
            role="user"
        )
        db.add_all([admin_user, demo_user])
        db.commit()

    # 3. Seed Cars
    if db.query(Car).count() == 0:
        cat_map = {c.slug: c.id for c in db.query(Category).all()}
        for cardata in cars_data:
            cat_id = cat_map.get(cardata["category_slug"], 1)
            new_car = Car(
                name=cardata["name"],
                brand=cardata["brand"],
                category_id=cat_id,
                price_per_day=cardata["price_per_day"],
                image_url=cardata["image_url"],
                transmission=cardata["transmission"],
                fuel_type=cardata["fuel_type"],
                seats=cardata["seats"],
                is_available=cardata["is_available"],
                is_featured=cardata["is_featured"],
                rating=cardata["rating"],
                description=cardata["description"]
            )
            db.add(new_car)
        db.commit()
