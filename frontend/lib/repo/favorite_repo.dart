import 'dart:convert';
import 'package:frontend/const/app_urls.dart';
import 'package:frontend/model/car_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class FavoriteRepo {
  /// Fetch all favorite cars for current user
  Future<List<CarModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.get(
      Uri.parse(AppUrls.favorites),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      List<CarModel> cars = [];
      for (var item in list) {
        if (item['car'] != null) {
          cars.add(CarModel.fromJson(item['car'] as Map<String, dynamic>));
        }
      }
      return cars;
    } else {
      throw Exception('Failed to load favorites');
    }
  }

  /// Add car to favorites
  Future<bool> addFavorite(int carId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.post(
      Uri.parse('${AppUrls.favorites}/$carId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  /// Remove car from favorites
  Future<bool> removeFavorite(int carId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.delete(
      Uri.parse('${AppUrls.favorites}/$carId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }
}
