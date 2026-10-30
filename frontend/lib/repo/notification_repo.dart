import 'dart:convert';
import 'package:frontend/const/app_urls.dart';
import 'package:frontend/model/notification_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class NotificationRepo {
  /// Fetch all notifications for the logged-in user
  Future<List<NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.get(
      Uri.parse(AppUrls.notifications),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      List<NotificationModel> result = [];
      for (var item in list) {
        result.add(NotificationModel.fromJson(item as Map<String, dynamic>));
      }
      return result;
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.put(
      Uri.parse(AppUrls.readAllNotifications),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  /// Mark a single notification as read
  Future<bool> markAsRead(int notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.put(
      Uri.parse('${AppUrls.notifications}/$notificationId/read'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  /// Delete a single notification
  Future<bool> deleteNotification(int notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.delete(
      Uri.parse('${AppUrls.notifications}/$notificationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  /// Clear all notifications
  Future<bool> clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.delete(
      Uri.parse(AppUrls.clearNotifications),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }
}
