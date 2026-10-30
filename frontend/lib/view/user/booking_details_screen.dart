import 'package:flutter/material.dart';
import 'package:frontend/const/app_colors.dart';
import 'package:frontend/const/app_language.dart';
import 'package:frontend/model/booking_model.dart';
import 'package:frontend/repo/booking_repo.dart';
import 'package:frontend/widgets/custom_button.dart';

class BookingDetailsScreen extends StatefulWidget {
  final BookingModel booking;
  final VoidCallback? onStatusChanged;

  BookingDetailsScreen({
    super.key,
    required this.booking,
    this.onStatusChanged,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final BookingRepo _bookingRepo = BookingRepo();
  late BookingModel _currentBooking;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
  }

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

  Future<void> _cancelBooking() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        title: Text(
          AppLanguage.tr('Cancel Booking?'),
          style: TextStyle(color: AppColors.primaryText),
        ),
        content: Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
          style: TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppLanguage.tr('Keep Booking'),
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLanguage.tr('Cancel It'),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updated = await _bookingRepo.cancelBooking(_currentBooking.id);
      setState(() {
        _currentBooking = updated;
      });
      widget.onStatusChanged?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Booking has been cancelled')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = _currentBooking;
    final statusColor = _getStatusColor(booking.status);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLanguage.tr('Booking Details'),
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car Image Hero
              if (booking.car?.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    booking.car!.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: AppColors.cardColor,
                      child: Icon(
                        Icons.directions_car,
                        color: AppColors.secondaryText,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 20),
              // Name and Status Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.car?.name ?? 'Car #${booking.carId}',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      AppLanguage.tr(booking.status.toUpperCase()),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                '${AppLanguage.tr('Booking ID:')} #${booking.id.toString().padLeft(4, '0')}',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
              ),
              SizedBox(height: 24),
              // Details breakdown matching screen 15
              Container(
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLanguage.tr('Pick Up Date'),
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          booking.startDate,
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLanguage.tr('Return Date'),
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          booking.endDate,
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLanguage.tr('Duration'),
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${booking.totalDays} ${AppLanguage.tr('Days')}',
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLanguage.tr('Location'),
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          booking.pickupLocation,
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: AppColors.borderColor, height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLanguage.tr('Total Amount Paid'),
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${booking.totalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 36),
              if (booking.status.toLowerCase() == 'confirmed') ...[
                CustomButton(
                  text: AppLanguage.tr('Cancel Booking'),
                  isSecondary: true,
                  isLoading: _isLoading,
                  onPressed: _cancelBooking,
                ),
                SizedBox(height: 14),
              ],
              CustomButton(
                text: AppLanguage.tr('Contact Support'),
                isSecondary: booking.status.toLowerCase() == 'confirmed',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Support helpline: +91 80876 15815 (Sinnar)',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
