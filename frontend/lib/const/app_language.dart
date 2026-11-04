import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage {
  // Global language notifier
  static final ValueNotifier<String> languageNotifier = ValueNotifier<String>('English');

  static String get currentLanguage => languageNotifier.value;
  static bool get isMarathi => languageNotifier.value.toLowerCase() == 'marathi';

  static Future<void> initLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString('app_language');
      if (savedLang != null && savedLang.isNotEmpty) {
        languageNotifier.value = savedLang;
      }
    } catch (_) {}
  }

  static void setLanguage(String lang) {
    if (languageNotifier.value != lang) {
      languageNotifier.value = lang;
    }
  }

  // Translation lookup method
  static String tr(String key) {
    if (!isMarathi) return key;
    return _marathiMap[key] ?? _marathiMap[key.trim()] ?? key;
  }

  static final Map<String, String> _marathiMap = {
    // Navigation bar (User & Admin)
    'Home': 'होम',
    'Explore': 'कार्स शोधा',
    'Bookings': 'बुकिंग्स',
    'Favorites': 'आवडते',
    'Profile': 'प्रोफाइल',
    'My Bookings': 'माझ्या बुकिंग्स',
    'Dashboard': 'डॅशबोर्ड',
    'Fleet': 'ताफा',

    // Admin Dashboard & Screens
    'Admin Dashboard': 'ॲडमिन डॅशबोर्ड',
    'Manage fleet, bookings & rentals': 'गाड्या, बुकिंग्स आणि भाडे व्यवस्थापन',
    'Total Cars': 'एकूण कार्स',
    'Total Bookings': 'एकूण बुकिंग्स',
    'Active Fleet': 'सक्रिय कार्स',
    'Pending Bookings': 'प्रलंबित बुकिंग्स',
    'Quick Actions': 'जलद कृती',
    'Add Car': 'कार जोडा',
    '+ Add Car': '+ कार जोडा',
    'Add New Car': 'नवीन कार जोडा',
    '+ Add New Car': '+ नवीन कार जोडा',
    'Manage Fleet': 'ताफा व्यवस्थापन',
    'Manage Fleet & Cars': 'कार्स आणि ताफा व्यवस्थापन',
    'Manage All Bookings': 'सर्व बुकिंग्स व्यवस्थापन',
    'Recent Bookings': 'अलीकडील बुकिंग्स',
    'See all': 'सर्व पहा',
    'Search fleet cars...': 'कार्स शोधा...',
    'No cars found in fleet': 'ताफ्यात कोणतीही कार आढळली नाही',
    'Delete Car?': 'कार हटवायची?',
    'Delete': 'हटवा',
    'All Bookings': 'सर्व बुकिंग्स',
    'All': 'सर्व',
    'Confirmed': 'निश्चित',
    'Pending': 'प्रलंबित',
    'Completed': 'पूर्ण झाले',
    'Cancelled': 'रद्द केले',
    'COMPLETED': 'पूर्ण झाले',
    'CONFIRMED': 'निश्चित',
    'CANCELLED': 'रद्द केले',
    'PENDING': 'प्रलंबित',
    'Dates:': 'तारीख:',
    'Total:': 'एकूण:',
    'User ID:': 'युजर आयडी:',
    'Update Booking Status': 'बुकिंग स्थिती बदला',
    'System & Database (Supabase Live)': 'सिस्टम आणि डेटाबेस (सुपाबेस थेट)',
    'ADMIN MANAGEMENT': 'ॲडमिन व्यवस्थापन',
    'ACCOUNT & SETTINGS': 'खाते आणि सेटिंग्ज',
    'ADMINISTRATOR': 'प्रशासक (Admin)',
    'Admin Profile': 'ॲडमिन प्रोफाइल',
    'Are you sure you want to logout as Admin?': 'तुम्हाला नक्की ॲडमिन म्हणून लॉगआउट करायचे आहे का?',

    // Settings
    'Settings': 'सेटिंग्ज',
    'Account': 'खाते',
    'Manage your account details': 'आपल्या खात्याचे तपशील व्यवस्थापित करा',
    'Notifications': 'सूचना',
    'Control your alerts and updates': 'सूचना आणि अपडेट्स नियंत्रित करा',
    'Language': 'भाषा',
    'Change app language': 'ॲपची भाषा बदला',
    'Appearance': 'थीम व लूक',
    'Light / Dark mode': 'लाइट / डार्क मोड',
    'App Information': 'ॲप माहिती',
    'Version, terms and more': 'व्हर्जन, नियम आणि माहिती',
    'Help & Support': 'मदत आणि सपोर्ट',
    'Get help or contact us': 'मदत मिळवा किंवा संपर्क साधा',

    // Profile & Edit Profile
    'Edit Profile': 'प्रोफाइल संपादित करा',
    'Privacy & Security': 'गोपनीयता आणि सुरक्षा',
    'Change Photo': 'फोटो बदला',
    'Take Photo': 'कॅमेऱ्याने फोटो घ्या',
    'Choose from Gallery': 'गॅलरीमधून निवडा',
    'Full Name': 'पूर्ण नाव',
    'Email Address': 'ईमेल पत्ता',
    'Bio': 'बायो (परिचय)',
    'Social Links (Optional)': 'सोशल मीडिया लिंक्स (ऐच्छिक)',
    'Save Changes': 'बदल सेव्ह करा',
    'Logout': 'लॉगआउट',
    'Delete Account': 'खाते हटवा',
    'Are you sure you want to log out?': 'तुम्हाला नक्की लॉगआउट करायचे आहे का?',
    'Cancel': 'रद्द करा',

    // Appearance
    'Light Mode': 'लाइट मोड',
    'Dark Mode': 'डार्क मोड',
    'Light theme for a brighter look': 'उजळ लूकसाठी लाइट थीम',
    'Dark theme for a comfortable view': 'डोळ्यांना आरामदायी डार्क थीम',

    // Login Activity
    'Login Activity': 'लॉगिन ॲक्टिव्हिटी',
    'This Device': 'हे डिव्हाइस',
    'Active Now': 'सध्या ॲक्टिव्ह',
    'Previous Session': 'मागील सेशन',
    'Log Out From Device': 'डिव्हाइसमधून लॉगआउट करा',

    // Home & Cars
    'Find your perfect ride': 'आपली परिपूर्ण कार शोधा',
    'Find Your Dream Car': 'आपली आवडती कार शोधा',
    'Search cars, brands...': 'कार किंवा ब्रँड शोधा...',
    'Categories': 'प्रकार',
    'Popular Cars': 'लोकप्रिय कार्स',
    'Featured Cars': 'खास कार्स',
    'Recommended For You': 'तुमच्यासाठी शिफारस केलेले',
    'View All': 'सर्व पहा',
    'Available': 'उपलब्ध',
    'Book Now': 'आत्ता बुक करा',
    '/day': '/दिवस',
    'day': 'दिवस',
    'SUV': 'एसयूव्ही',
    'Sedan': 'सेडान',
    'Sports': 'स्पोर्ट्स',
    'Electric': 'इलेक्ट्रिक',
    'Luxury': 'लक्झरी',

    // Banners
    'Luxury.\nPerformance.\nFreedom.': 'लक्झरी.\nवेग.\nस्वातंत्र्य.',
    'Rent premium cars at the best prices.': 'उत्कृष्ट दरात प्रीमियम कार्स भाड्याने घ्या.',
    'Weekend.\nAdventure.\nEscape.': 'वीकेंड.\nसाहसी प्रवास.\nसुट्टी.',
    'Rent powerful 4x4 SUVs with special discounts.': 'विशेष सवलतीसह शक्तिशाली 4x4 एसयूव्ही बुक करा.',
    'Go Electric.\nPure Power.\nFuture.': 'इलेक्ट्रिक व्हा.\nशुद्ध शक्ती.\nभविष्य.',
    'Zero emission Tesla & EV fleet for clean city drives.': 'प्रदूषणमुक्त प्रवासासाठी टेस्ला आणि ईव्ही कार्स.',
    'Executive.\nElegance.\nPrestige.': 'एक्झिक्युटिव्ह.\nराजेशाही.\nप्रतिष्ठा.',
    'Chauffeur & self-drive VIP luxury sedans.': 'ड्रायव्हरसह किंवा स्वतः चालवण्यासाठी व्हीआयपी सेडान.',

    // Bookings & Details
    'Booking Details': 'बुकिंग तपशील',
    'Select Date': 'तारीख निवडा',
    'Pickup Date': 'पिकअप तारीख',
    'Return Date': 'परतीची तारीख',
    'Total Amount': 'एकूण रक्कम',
    'Confirm Booking': 'बुकिंग कन्फर्म करा',
    'Cancel Booking': 'बुकिंग रद्द करा',
    'Contact Support': 'सपोर्टशी संपर्क साधा',
    'Back to Home': 'होमवर परत जा',
    'View My Bookings': 'माझ्या बुकिंग्स पहा',
    'No bookings yet': 'अजून एकही बुकिंग नाही',
    'No favorite cars yet': 'कोणतीही आवडती कार जोडलेली नाही',
    'Explore Cars': 'कार्स शोधा',

    // Customer & Booking Admin Details
    'Customer Details': 'ग्राहक तपशील',
    'Customer Info': 'ग्राहक माहिती',
    'Customer:': 'ग्राहक:',
    'Customer': 'ग्राहक',
    'Customer Name': 'ग्राहकाचे नाव',
    'User ID': 'युझर आयडी',
    'Phone:': 'फोन:',
    'Email:': 'ईमेल:',
    'Location:': 'पिकअप ठिकाण:',
    'Call Customer': 'कॉल करा',
    'Email Customer': 'ईमेल करा',
    'Not provided': 'उपलब्ध नाही',
    'Booking Request Details': 'बुकिंग विनंती व ग्राहक तपशील',
    'Close': 'बंद करा',
  };
}
