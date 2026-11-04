import 'package:flutter/material.dart';
import 'package:frontend/const/app_colors.dart';
import 'package:frontend/const/app_language.dart';
import 'package:frontend/model/booking_model.dart';


class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    this.onCancel,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.successColor;
      case 'pending':
        return AppColors.warningColor;
      case 'cancelled':
        return AppColors.errorColor;
      case 'completed':
      default:
        return AppColors.accentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(booking.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:  EdgeInsets.only(bottom: 16),
        padding:  EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderColor, width: 1),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 75,
                    height: 60,
                    child: booking.car?.imageUrl != null && booking.car!.imageUrl.isNotEmpty
                        ? Image.network(
                            booking.car!.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: AppColors.secondaryCardColor,
                                  child: Icon(
                                    Icons.directions_car,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                          )
                        : Container(
                            color: AppColors.secondaryCardColor,
                            child: Icon(
                              Icons.directions_car,
                              color: AppColors.secondaryText,
                            ),
                          ),
                  ),
                ),
                 SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.car?.name ?? 'Car #${booking.carId}',
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (booking.userName.isNotEmpty) ...[
                         SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 13, color: AppColors.primaryColor),
                             SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                booking.userName,
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                       SizedBox(height: 3),
                      Text(
                        '${booking.startDate} to ${booking.endDate}',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                       SizedBox(height: 3),
                      Text(
                        '${AppLanguage.tr('Total:')} ₹${booking.totalPrice.toStringAsFixed(0)} (${booking.totalDays} ${AppLanguage.tr('days')})',
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                 SizedBox(width: 8),
                Container(
                  padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    AppLanguage.tr(booking.status.toUpperCase()),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (onCancel != null &&
                booking.status.toLowerCase() == 'confirmed') ...[
              Divider(color: AppColors.borderColor, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorColor,
                      side: BorderSide(color: AppColors.errorColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:  EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                    ),
                    child: Text(
                      AppLanguage.tr('Cancel Booking'),
                      style:  TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
