import 'car_model.dart';
import 'user_model.dart';

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
  final UserModel? user;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userAvatar;

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
    this.user,
    this.userName = '',
    this.userEmail = '',
    this.userPhone = '',
    this.userAvatar = '',
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    UserModel? parsedUser;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      parsedUser = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    }

    final rawName = parsedUser != null && parsedUser.name.isNotEmpty
        ? parsedUser.name
        : (json['user_name'] as String? ?? (json['name'] as String? ?? ''));
    final rawEmail = parsedUser != null && parsedUser.email.isNotEmpty
        ? parsedUser.email
        : (json['user_email'] as String? ?? (json['email'] as String? ?? ''));
    final rawPhone = parsedUser != null && parsedUser.phone != null && parsedUser.phone!.isNotEmpty
        ? parsedUser.phone!
        : (json['user_phone'] as String? ?? (json['phone'] as String? ?? ''));
    final rawAvatar = parsedUser != null && parsedUser.avatarUrl.isNotEmpty
        ? parsedUser.avatarUrl
        : (json['user_avatar'] as String? ?? (json['avatar_url'] as String? ?? ''));

    return BookingModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? (parsedUser?.id ?? 0),
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
      user: parsedUser,
      userName: rawName,
      userEmail: rawEmail,
      userPhone: rawPhone,
      userAvatar: rawAvatar,
    );
  }
}
