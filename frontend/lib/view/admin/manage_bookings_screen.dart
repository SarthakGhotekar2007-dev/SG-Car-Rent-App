import 'package:flutter/material.dart';
import 'package:frontend/const/app_colors.dart';
import 'package:frontend/const/app_language.dart';
import 'package:frontend/model/booking_model.dart';
import 'package:frontend/repo/booking_repo.dart';

class ManageBookingsScreen extends StatefulWidget {
  ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  final BookingRepo _bookingRepo = BookingRepo();
  List<BookingModel> _bookings = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final list = await _bookingRepo.getAllBookings();
      setState(() {
        _bookings = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<BookingModel> get _filteredBookings {
    if (_selectedFilter == 'All') return _bookings;
    return _bookings.where((b) => b.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();
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

  Future<void> _updateStatus(BookingModel booking) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLanguage.tr('Update Booking Status'),
                  style: TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ListTile(
                  title: Text(AppLanguage.tr('Confirmed'), style: TextStyle(color: AppColors.successColor, fontWeight: FontWeight.bold)),
                  leading: Icon(Icons.check_circle, color: AppColors.successColor),
                  onTap: () => Navigator.pop(context, 'confirmed'),
                ),
                ListTile(
                  title: Text(AppLanguage.tr('Completed'), style: TextStyle(color: AppColors.accentColor, fontWeight: FontWeight.bold)),
                  leading: Icon(Icons.done_all, color: AppColors.accentColor),
                  onTap: () => Navigator.pop(context, 'completed'),
                ),
                ListTile(
                  title: Text(AppLanguage.tr('Cancelled'), style: TextStyle(color: AppColors.errorColor, fontWeight: FontWeight.bold)),
                  leading: Icon(Icons.cancel, color: AppColors.errorColor),
                  onTap: () => Navigator.pop(context, 'cancelled'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && selected != booking.status) {
      try {
        await _bookingRepo.updateBookingStatus(booking.id, selected);
        _loadBookings();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking #${booking.id} updated to ${selected.toUpperCase()}'),
            backgroundColor: AppColors.successColor,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primaryColor : AppColors.borderColor),
        ),
        child: Text(
          AppLanguage.tr(label),
          style: TextStyle(
            color: isSelected ? AppColors.backgroundColor : AppColors.primaryText,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLanguage.tr('All Bookings'), style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold)),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    _buildFilterChip('Confirmed'),
                    _buildFilterChip('Pending'),
                    _buildFilterChip('Completed'),
                    _buildFilterChip('Cancelled'),
                  ],
                ),
              ),
            ),
            // Bookings List matching screen 24
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                  : _filteredBookings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month_outlined, size: 60, color: AppColors.secondaryText),
                              SizedBox(height: 12),
                              Text(AppLanguage.tr('No bookings found'), style: TextStyle(color: AppColors.primaryText, fontSize: 17, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadBookings,
                          color: AppColors.primaryColor,
                          backgroundColor: AppColors.cardColor,
                          child: ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: _filteredBookings.length,
                            itemBuilder: (context, index) {
                              final b = _filteredBookings[index];
                              final color = _getStatusColor(b.status);

                              return Container(
                                margin: EdgeInsets.only(bottom: 14),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.borderColor, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          b.car?.name ?? 'Car #${b.carId}',
                                          style: TextStyle(
                                            color: AppColors.primaryText,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _updateStatus(b),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: color.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: color.withValues(alpha: 0.6)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  AppLanguage.tr(b.status.toUpperCase()),
                                                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                                                ),
                                                SizedBox(width: 4),
                                                Icon(Icons.arrow_drop_down, color: color, size: 16),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${AppLanguage.tr('Dates:')} ${b.startDate} to ${b.endDate} (${b.totalDays} ${AppLanguage.tr('days')})',
                                      style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${AppLanguage.tr('User ID:')} #${b.userId} • ${b.pickupLocation}',
                                          style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
                                        ),
                                        Text(
                                          '${AppLanguage.tr('Total:')} ₹${b.totalPrice.toStringAsFixed(0)}',
                                          style: TextStyle(color: AppColors.primaryText, fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
