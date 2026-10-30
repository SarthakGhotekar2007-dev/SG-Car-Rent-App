import 'dart:convert';
import 'package:frontend/model/car_model.dart';
import 'package:frontend/model/category_model.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/const/app_urls.dart';


class CategoryRepo {
  /// Fetch all available car categories
  Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(Uri.parse(AppUrls.categories));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((item) => CategoryModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  /// Fetch cars belonging to a specific category
  Future<List<CarModel>> getCarsByCategory(int categoryId) async {
    final response = await http.get(Uri.parse('${AppUrls.categories}/$categoryId/cars'));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((item) => CarModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load cars for category');
    }
  }
}
