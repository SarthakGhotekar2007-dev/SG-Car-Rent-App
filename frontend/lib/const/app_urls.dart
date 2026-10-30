import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppUrls {
  // Automatically selects 10.0.2.2 for Android Emulator, and 127.0.0.1 for Windows/Web/iOS
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  // Auth Endpoints
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get me => '$baseUrl/auth/me';

  // Car Endpoints
  static String get cars => '$baseUrl/cars';
  static String get featuredCars => '$baseUrl/cars/featured';
  static String get searchCars => '$baseUrl/cars/search';
  static String get categories => '$baseUrl/categories';

  // Booking Endpoints
  static String get bookings => '$baseUrl/bookings';
  static String get myBookings => '$baseUrl/bookings/my';

  // Favorites Endpoints
  static String get favorites => '$baseUrl/favorites';

  // User Profile & Settings Endpoints
  static String get userProfile => '$baseUrl/users/me';
  static String get userPreferences => '$baseUrl/users/preferences';
  static String get changePassword => '$baseUrl/users/change-password';
  static String get loginActivity => '$baseUrl/users/login-activity';

  // Admin Endpoints
  static String get adminCars => '$baseUrl/admin/cars';
  static String get adminBookings => '$baseUrl/admin/bookings';

  // Notifications Endpoints
  static String get notifications => '$baseUrl/notifications';
  static String get readAllNotifications => '$baseUrl/notifications/read-all';
  static String get clearNotifications => '$baseUrl/notifications/clear-all';
}
