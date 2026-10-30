# SG Car Rent - Flutter Frontend Application 📱✨

> **SG Car Rent Frontend** हे Flutter 3.44+ आणि Dart 3.x चा वापर करून विकसित केलेले एक हाय-एंड, डार्क थीम बेस्ड मोबाइल व वेब ॲप्लिकेशन आहे. हे ॲप **Clean Architecture** आणि **Repository Pattern** वर डिझाइन केलेले आहे.

---

## 🎨 1. डिझाइन आणि थीम सिस्टीम (Design & Theme System)

ॲपमध्ये **Obsidian Luxury Dark Theme** वापरली गेली आहे, ज्यामुळे लक्झरी कार रेंटलचा आंतरराष्ट्रीय दर्जाचा फील मिळतो:

* **Background Color:** `#121212` (Deep Charcoal Black)
* **Card Surface Color:** `#1E1E1E` (Sleek Elevated Card)
* **Secondary Card Color:** `#252525` (Subtle Chip / Input Box)
* **Primary Accent Color:** `#FFFFFF` (Crisp Contrast White) / Gold Highlights
* **Border Color:** `#2C2C2C` (Subtle 1px Glassmorphism Border)
* **Status Badges:**
  * 🟢 **Confirmed:**
  * 🟡 **Pending:** Amber Warning (`#FFB300`)
  * 🔴 **Cancelled:** Error Red (`#E53935`)
  * 🔵 **Completed:** Accent Blue (`#1E88E5`)

---

## 📂 2. फ्रंटएंड फोल्डर स्ट्रक्चर (Folder Architecture)

```text
frontend/
├── assets/
│   └── images/                      # हाय-रिझोल्यूशन स्थानिक इमेजेस (Offline Assets)
│       ├── splash_car.jpg           # स्प्लॅश स्क्रीन कार
│       ├── onboarding_1.jpg         # ऑनबोर्डिंग १ (Luxury Cars)
│       ├── onboarding_2.jpg         # ऑनबोर्डिंग २ (Rent, Drive, Explore)
│       ├── onboarding_3.jpg         # ऑनबोर्डिंग ३ (Your Ride, Your Rules)
│       ├── banner_car.jpg           # होम स्क्रीन प्रोमो बॅनर
│       ├── login_car.jpg            # लॉगिन स्क्रीन हेडर कार (Mercedes AMG)
│       ├── register_car.jpg         # रजिस्टर स्क्रीन हेडर कार (BMW M)
│       └── forgot_car.jpg           # पासवर्ड रीसेट हेडर कार (Porsche)
│
├── lib/
│   ├── const/                       # जागतिक कॉन्स्टंट्स (Constants)
│   │   ├── app_colors.dart          # संपूर्ण ॲपचे कलर पॅलेट
│   │   ├── app_strings.dart         # टेक्स्ट आणि लेबल्स
│   │   └── app_urls.dart            # बॅकएंड API एंडपॉइंट्स (स्मार्ट IP डिटेक्शनसह)
│   │
│   ├── model/                       # डेटा मॉडेल्स (JSON Serialization)
│   │   ├── user_model.dart          # युझर माहिती व रोल
│   │   ├── car_model.dart           # कारचे स्पेसिफिकेशन्स, किंमत व इमेजेस
│   │   ├── category_model.dart      # कार कॅटेगरी (SUV, Sedan, etc.)
│   │   └── booking_model.dart       # बुकिंग तारीख, स्टेटस व किंमत
│   │
│   ├── repo/                        # रिपॉझिटरी लेयर (API Services)
│   │   ├── auth_repo.dart           # Login, Register, Logout, Token Storage
│   │   ├── car_repo.dart            # Get All Cars, Featured, Filter
│   │   ├── category_repo.dart       # Fetch Categories
│   │   ├── booking_repo.dart        # Create Booking, My Bookings, Cancel
│   │   └── favorite_repo.dart       # Wishlist Add / Remove
│   │
│   ├── widgets/                     # रियुझेबल विजेट्स (Reusable Components)
│   │   ├── car_card.dart            # हॉरिझॉन्टल व व्हर्टिकल कार कार्ड
│   │   ├── booking_card.dart        # बुकिंग कार्ड (डायनॅमिक स्टेटस बॅजसह)
│   │   ├── category_card.dart       # कॅटेगरी फिल्टर बटन्स
│   │   ├── custom_bottom_nav.dart   # ५ पर्यायांचा बॉटम नेव्हिगेशन बार
│   │   ├── custom_button.dart       # लोडिंग इंडिकेटरयुक्त कस्टम बटण
│   │   └── custom_text_field.dart   # पासवर्ड टॉगलसह इनपुट बॉक्स
│   │
│   ├── view/                        # युझर इंटरफेस स्क्रीन्स (UI Layer)
│   │   ├── auth/                    # 🔐 ऑथेंटिकेशन व ऑनबोर्डिंग
│   │   │   ├── splash_screen.dart
│   │   │   ├── onboarding_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   │
│   │   ├── admin/                   # 👑 ॲडमिन मॅनेजमेंट स्क्रीन्स
│   │   │   ├── admin_dashboard.dart
│   │   │   ├── manage_cars_screen.dart
│   │   │   ├── add_car_screen.dart
│   │   │   ├── edit_car_screen.dart
│   │   │   ├── manage_bookings_screen.dart
│   │   │   └── admin_profile_screen.dart
│   │   │
│   │   └── user/                    # 👤 ग्राहक (Customer) स्क्रीन्स
│   │       ├── home_screen.dart
│   │       ├── explore_cars_screen.dart
│   │       ├── car_details_screen.dart
│   │       ├── booking_date_screen.dart
│   │       ├── booking_confirmation_screen.dart
│   │       ├── booking_details_screen.dart
│   │       ├── my_bookings_screen.dart
│   │       ├── favorites_screen.dart
│   │       ├── notifications_screen.dart
│   │       ├── profile_screen.dart
│   │       └── edit_profile_screen.dart
│   │
│   └── main.dart                    # ॲपचा मुख्य एंट्री पॉईंट आणि थीम
│
└── pubspec.yaml                     # डिपेंडन्सीज व ॲसेट्स नोंदणी
```

---

## 🌐 3. स्मार्ट नेटवर्क कॉन्फिगरेशन (`AppUrls`)

[app_urls.dart](file:///c:/flutter practice/sg car rent app/frontend/lib/const/app_urls.dart) मध्ये स्मार्ट IP डिटेक्शन लॉजिक लिहिलेले आहे:
* **Android Emulator साठी:** `http://10.0.2.2:8000/api/v1` (कारण इम्युलेटरवर Localhost म्हणजे स्वतः डिव्हाइस असते).
* **Chrome Web व Windows साठी:** `http://127.0.0.1:8000/api/v1`.

यामुळे कोणत्याही कोडमध्ये मॅन्युअली IP ॲड्रेस बदलण्याची गरज पडत नाही!

---

## ⚡ 4. ॲप कसे चालवावे? (Running the App)

### १. डिपेंडन्सीज इन्स्टॉल करा:
```powershell
flutter pub get
```

### २. वेबवर रन करण्यासाठी (Google Chrome):
```powershell
flutter run -d chrome
```

### ३. अँड्रॉइड इम्युलेटरवर रन करण्यासाठी:
```powershell
flutter run
```

### ४. कोड तपासणी (Code Analysis):
```powershell
flutter analyze
```

---

## 🔐 5. टेस्ट क्रेडेंशियल्स (Test Accounts)

* **👑 Admin Login:** `admin123@gmail.com` | पासवर्ड: `admin@123` (ॲडमिन डॅशबोर्ड थेट उघडेल).
* **👤 User Login:** `sarthak@example.com` | पासवर्ड: `Sarthak@123` (ग्राहक होम स्क्रीन उघडेल).
* किंवा नवीन युझर म्हणून ॲपमधून थेट **Register** करू शकता.

---

*SG Car Rent - Drive Your Dreams*
