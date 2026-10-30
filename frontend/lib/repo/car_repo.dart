import 'dart:convert';
import 'package:frontend/model/car_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/const/app_urls.dart';


class CarRepo {
  /// Fetch all available cars with optional category or search filters
  Future<List<CarModel>> getAllCars({int? categoryId, String? search}) async {
    String url = AppUrls.cars;
    List<String> params = [];

    if (categoryId != null && categoryId > 0) {
      params.add('category_id=$categoryId');
    }
    if (search != null && search.trim().isNotEmpty) {
      params.add('brand=${Uri.encodeComponent(search.trim())}');
    }

    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((item) => CarModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load cars from server');
    }
  }

  /// Fetch featured luxury cars for home screen banner
  Future<List<CarModel>> getFeaturedCars() async {
    final response = await http.get(Uri.parse(AppUrls.featuredCars));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((item) => CarModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load featured cars');
    }
  }

  /// Search cars by query string
  Future<List<CarModel>> searchCars(String query) async {
    final url = '${AppUrls.searchCars}?name=${Uri.encodeComponent(query.trim())}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((item) => CarModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to search cars');
    }
  }

  /// Get details for a single car
  Future<CarModel> getCarById(int id) async {
    final response = await http.get(Uri.parse('${AppUrls.cars}/$id'));

    if (response.statusCode == 200) {
      return CarModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Car details not found');
    }
  }

  /// Check car availability for given dates
  Future<bool> checkAvailability(int carId, String startDate, String endDate) async {
    final url = '${AppUrls.cars}/$carId/availability?start_date=$startDate&end_date=$endDate';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['is_available'] == true;
    }
    return false;
  }

  /// Admin: Add a new car to the fleet
  Future<CarModel> addCar(Map<String, dynamic> carData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.post(
      Uri.parse(AppUrls.adminCars),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(carData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return CarModel.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to add car');
    }
  }

  /// Admin: Update an existing car
  Future<CarModel> updateCar(int id, Map<String, dynamic> carData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.patch(
      Uri.parse('${AppUrls.adminCars}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(carData),
    );

    if (response.statusCode == 200) {
      return CarModel.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to update car');
    }
  }

  /// Admin: Delete a car
  Future<bool> deleteCar(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await http.delete(
      Uri.parse('${AppUrls.adminCars}/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to delete car');
    }
  }
}
