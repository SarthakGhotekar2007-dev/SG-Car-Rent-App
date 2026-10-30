import 'dart:convert';
import 'package:frontend/const/app_urls.dart';
import 'package:frontend/model/booking_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class BookingRepo {
  /// Create a new car booking (Calculates price on backend)
  Future<BookingModel> createBooking({
    required int carId,
    required String startDate,
    required String endDate,
    required String pickupLocation,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.post(
      Uri.parse(AppUrls.bookings),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'car_id': carId,
        'start_date': startDate,
        'end_date': endDate,
        'pickup_location': pickupLocation,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return BookingModel.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to place booking');
    }
  }

  /// Get current user's bookings
  Future<List<BookingModel>> getMyBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.get(
      Uri.parse(AppUrls.myBookings),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((item) => BookingModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load your bookings');
    }
  }

  /// Cancel an existing booking
  Future<BookingModel> cancelBooking(int bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.patch(
      Uri.parse('${AppUrls.bookings}/$bookingId/cancel'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return BookingModel.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to cancel booking');
    }
  }

  /// Admin: Get all bookings across all users
  Future<List<BookingModel>> getAllBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.get(
      Uri.parse(AppUrls.adminBookings),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((item) => BookingModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load all bookings');
    }
  }

  /// Admin: Update status of any booking
  Future<BookingModel> updateBookingStatus(int bookingId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    

    final response = await http.patch(
      Uri.parse('${AppUrls.adminBookings}/$bookingId/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      return BookingModel.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to update booking status');
    }
  }
}
