class CarModel {
  final int id;
  final String name;
  final String brand;
  final int categoryId;
  final String categoryName;
  final double pricePerDay;
  final String imageUrl;
  final String transmission;
  final String fuelType;
  final int seats;
  final bool isAvailable;
  final bool isFeatured;
  final double rating;
  final String description;

  CarModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.categoryId,
    required this.categoryName,
    required this.pricePerDay,
    required this.imageUrl,
    required this.transmission,
    required this.fuelType,
    required this.seats,
    required this.isAvailable,
    required this.isFeatured,
    required this.rating,
    required this.description,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Luxury Car',
      brand: json['brand'] as String? ?? 'Premium',
      categoryId: json['category_id'] as int? ?? 1,
      categoryName: json['category_name'] as String? ?? 'Luxury',
      pricePerDay: (json['price_per_day'] as num?)?.toDouble() ?? 100.0,
      imageUrl: json['image_url'] as String? ??
          'https://images.unsplash.com/photo-1617788138017-80ad40651399?auto=format&fit=crop&w=800&q=80',
      transmission: json['transmission'] as String? ?? 'Automatic',
      fuelType: json['fuel_type'] as String? ?? 'Petrol',
      seats: json['seats'] as int? ?? 4,
      isAvailable: json['is_available'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      description: json['description'] as String? ??
          'Experience the pinnacle of automotive engineering and luxury craftsmanship.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand': brand,
      'category_id': categoryId,
      'price_per_day': pricePerDay,
      'image_url': imageUrl,
      'transmission': transmission,
      'fuel_type': fuelType,
      'seats': seats,
      'is_available': isAvailable,
      'is_featured': isFeatured,
      'rating': rating,
      'description': description,
    };
  }
}
