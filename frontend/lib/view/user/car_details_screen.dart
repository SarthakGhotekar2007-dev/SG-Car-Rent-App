import 'package:flutter/material.dart';
import 'package:frontend/const/app_colors.dart';
import 'package:frontend/model/car_model.dart';
import 'package:frontend/repo/favorite_repo.dart';
import 'package:frontend/widgets/custom_button.dart';

import 'booking_date_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  final CarModel car;

  CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final FavoriteRepo _favoriteRepo = FavoriteRepo();
  bool _isFavorite = false;

  void _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      if (_isFavorite) {
        await _favoriteRepo.addFavorite(widget.car.id);
      } else {
        await _favoriteRepo.removeFavorite(widget.car.id);
      }
    } catch (_) {
      // Revert if error
    }
  }

  Widget _buildSpecItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.accentColor),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondaryCardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accentColor),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.car;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar matching screen 11
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.share_outlined, color: AppColors.primaryText),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Sharing car details...')),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? AppColors.heartColor : AppColors.primaryText,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Car Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        height: 240,
                        width: double.infinity,
                        color: AppColors.cardColor,
                        child: Image.network(
                          car.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: AppColors.secondaryCardColor,
                              child: Center(
                                child: SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryColor),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(Icons.directions_car, color: AppColors.secondaryText, size: 80),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Car Title & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                car.name,
                                style: TextStyle(
                                  color: AppColors.primaryText,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                car.brand,
                                style: TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: AppColors.warningColor, size: 16),
                              SizedBox(width: 4),
                              Text(
                                '${car.rating.toStringAsFixed(1)} (120 reviews)',
                                style: TextStyle(
                                  color: AppColors.primaryText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    // Specs Grid matching reference image
                    Row(
                      children: [
                        Expanded(child: _buildSpecItem('0-100 km/h', '3.9s', Icons.speed)),
                        SizedBox(width: 12),
                        Expanded(child: _buildSpecItem('Top Speed', '250 mph', Icons.shutter_speed)),
                        SizedBox(width: 12),
                        Expanded(child: _buildSpecItem('Seats', '${car.seats} Seats', Icons.airline_seat_recline_normal)),
                      ],
                    ),
                    SizedBox(height: 24),
                    // Description
                    Text(
                      'Description',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      car.description,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24),
                    // Features Chips
                    Text(
                      'Features',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildFeatureChip(car.transmission, Icons.settings),
                        _buildFeatureChip(car.fuelType, Icons.local_gas_station),
                        _buildFeatureChip('${car.seats} Seats', Icons.event_seat),
                        _buildFeatureChip('GPS Navigation', Icons.navigation),
                        _buildFeatureChip('Bluetooth Audio', Icons.bluetooth),
                      ],
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            // Sticky Bottom Bar matching reference screen 11
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                border: Border(top: BorderSide(color: AppColors.borderColor, width: 1)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Price',
                        style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
                      ),
                      Text(
                        '₹${car.pricePerDay.toStringAsFixed(0)}/day',
                        style: TextStyle(
                          color: AppColors.accentColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: CustomButton(
                      text: 'Book Now',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingDateScreen(car: car),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
