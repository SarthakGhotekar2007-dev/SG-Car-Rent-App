import 'dart:convert';
import 'package:frontend/const/app_urls.dart';
import 'package:frontend/model/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class AuthRepo {
  /// Login with email and password, save token in SharedPreferences and return UserModel
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(AppUrls.login);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();

      final token = responseData['access_token'] as String;
      await prefs.setString('access_token', token);

      final userData = responseData['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userData);

      // Save user role, name, and email for easy offline access
      await prefs.setString('user_role', user.role);
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_email', user.email);
      if (user.avatarUrl.isNotEmpty) {
        await prefs.setString('user_avatar_url', user.avatarUrl);
      }

      return user;
    }

    final message = responseData is Map<String, dynamic>
        ? responseData['detail']?.toString() ?? 'Login failed'
        : 'Login failed';

    throw Exception(message);
  }

  /// Register a new user account
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final url = Uri.parse(AppUrls.register);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'phone': phone?.trim(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    final responseData = jsonDecode(response.body);

    final message = responseData is Map<String, dynamic>
        ? responseData['detail']?.toString() ?? 'Registration failed'
        : 'Registration failed';

    throw Exception(message);
  }

  /// Get stored access token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Clear token and logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_role');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_avatar_base64');
    await prefs.remove('user_avatar_url');
  }

  /// Get full user profile from backend
  Future<UserModel> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.get(
      Uri.parse(AppUrls.userProfile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final user = UserModel.fromJson(jsonDecode(response.body));
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_email', user.email);
      return user;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to fetch profile');
    }
  }

  /// Update user profile using PUT /users/me
  Future<UserModel> updateProfile({
    required String name,
    String? phone,
  }) async {
    return updateFullProfile(name: name, phone: phone);
  }

  /// Update full profile with bio, avatar, and social links
  Future<UserModel> updateFullProfile({
    required String name,
    String? phone,
    String? bio,
    String? avatarUrl,
    String? linkedin,
    String? github,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.put(
      Uri.parse(AppUrls.userProfile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name.trim(),
        'phone': (phone != null && phone.trim().isNotEmpty) ? phone.trim() : null,
        'bio': bio?.trim(),
        'avatar_url': avatarUrl?.trim(),
        'linkedin': linkedin?.trim(),
        'github': github?.trim(),
      }),
    );

    if (response.statusCode == 200) {
      final user = UserModel.fromJson(jsonDecode(response.body));
      await prefs.setString('user_name', user.name);
      return user;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to update profile');
    }
  }

  /// Update preferences (language, theme_mode, privacy switches)
  Future<UserModel> updatePreferences({
    String? language,
    String? themeMode,
    bool? profileVisibility,
    bool? showOnlineStatus,
    bool? allowMessageRequests,
    bool? twoFactorAuth,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final Map<String, dynamic> body = {};
    if (language != null) body['language'] = language;
    if (themeMode != null) body['theme_mode'] = themeMode;
    if (profileVisibility != null) body['profile_visibility'] = profileVisibility;
    if (showOnlineStatus != null) body['show_online_status'] = showOnlineStatus;
    if (allowMessageRequests != null) body['allow_message_requests'] = allowMessageRequests;
    if (twoFactorAuth != null) body['two_factor_auth'] = twoFactorAuth;

    final response = await http.patch(
      Uri.parse(AppUrls.userPreferences),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to update preferences');
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.post(
      Uri.parse(AppUrls.changePassword),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to change password');
    }
  }

  /// Get login activity list
  Future<List<Map<String, dynamic>>> getLoginActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.get(
      Uri.parse(AppUrls.loginActivity),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load login activity');
    }
  }

  /// Revoke / log out from a specific session device
  Future<bool> logoutDevice(int deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.delete(
      Uri.parse('${AppUrls.loginActivity}/$deviceId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  /// Delete current user account using DELETE /users/me
  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.delete(
      Uri.parse(AppUrls.userProfile),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Clear all local session data after deletion
      await prefs.remove('access_token');
      await prefs.remove('user_role');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to delete account');
    }
  }
}
