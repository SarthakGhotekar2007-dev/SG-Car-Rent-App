import 'package:flutter/material.dart';
import '../../const/app_colors.dart';
import '../../const/app_language.dart';
import '../../model/booking_model.dart';
import '../../repo/booking_repo.dart';
import '../../widgets/booking_card.dart';
import 'booking_details_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final BookingRepo _bookingRepo = BookingRepo();
  List<BookingModel> _allBookings = [];
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
      final list = await _bookingRepo.getMyBookings();
      setState(() {
        _allBookings = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<BookingModel> get _filteredBookings {
    if (_selectedFilter == 'All') return _allBookings;
    return _allBookings.where((b) => b.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
          ),
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
        title: Text(
          AppLanguage.tr('My Bookings'),
          style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        ),
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            // Bookings List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.primaryColor),
                    )
                  : _filteredBookings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month_outlined, size: 64, color: AppColors.secondaryText),
                              SizedBox(height: 16),
                              Text(
                                AppLanguage.tr('No bookings found'),
                                style: TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 6),
                              Text(
                                AppLanguage.tr('You have not placed any bookings in this category yet.'),
                                style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                              ),
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
                              final booking = _filteredBookings[index];
                              return BookingCard(
                                booking: booking,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookingDetailsScreen(
                                        booking: booking,
                                        onStatusChanged: _loadBookings,
                                      ),
                                    ),
                                  );
                                },
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
