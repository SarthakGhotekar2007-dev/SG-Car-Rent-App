import 'car_model.dart';

class BookingModel {
  final int id;
  final int userId;
  final int carId;
  final String startDate;
  final String endDate;
  final int totalDays;
  final double totalPrice;
  final String pickupLocation;
  final String status;
  final String createdAt;
  final CarModel? car;

  BookingModel({
    required this.id,
    required this.userId,
    required this.carId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.totalPrice,
    required this.pickupLocation,
    required this.status,
    required this.createdAt,
    this.car,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      carId: json['car_id'] as int? ?? 0,
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      totalDays: json['total_days'] as int? ?? 1,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      pickupLocation: json['pickup_location'] as String? ?? 'Pune',
      status: json['status'] as String? ?? 'confirmed',
      createdAt: json['created_at'] as String? ?? '',
      car: json['car'] != null && json['car'] is Map<String, dynamic>
          ? CarModel.fromJson(json['car'] as Map<String, dynamic>)
          : null,
    );
  }
}
