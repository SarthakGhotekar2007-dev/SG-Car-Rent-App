import 'package:flutter/material.dart';
import 'package:frontend/const/app_colors.dart';
import 'package:frontend/const/app_language.dart';
import 'package:frontend/model/booking_model.dart';
import 'package:frontend/model/car_model.dart';
import 'package:frontend/repo/booking_repo.dart';
import 'package:frontend/repo/car_repo.dart';
import 'package:frontend/widgets/booking_card.dart';

import 'add_car_screen.dart';
import 'manage_cars_screen.dart';
import 'manage_bookings_screen.dart';
import 'admin_profile_screen.dart';

class AdminDashboard extends StatefulWidget {
  AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentTabIndex = 0;

  final CarRepo _carRepo = CarRepo();
  final BookingRepo _bookingRepo = BookingRepo();

  List<CarModel> _cars = [];
  List<BookingModel> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cars = await _carRepo.getAllCars();
      final bookings = await _bookingRepo.getAllBookings();

      setState(() {
        _cars = cars;
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(icon, color: color, size: 22),
            ],
          ),
          SizedBox(height: 8),
          Text(
            AppLanguage.tr(label),
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardView() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
    }

    final totalCars = _cars.length;
    final totalBookings = _bookings.length;
    final pendingBookings = _bookings.where((b) => b.status.toLowerCase() == 'pending').length;

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppColors.primaryColor,
      backgroundColor: AppColors.cardColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Welcome Header matching screen 20
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLanguage.tr('Admin Dashboard'),
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      AppLanguage.tr('Manage fleet, bookings & rentals'),
                      style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentTabIndex = 3; // Go to Admin Profile
                    });
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.cardColor,
                    child: Icon(Icons.admin_panel_settings, color: AppColors.primaryColor, size: 22),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            // Stats Grid matching screen 20
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Cars', '$totalCars', Icons.directions_car, AppColors.primaryColor)),
                SizedBox(width: 12),
                Expanded(child: _buildStatCard('Total Bookings', '$totalBookings', Icons.calendar_month, AppColors.successColor)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('Active Fleet', '${_cars.where((c) => c.isAvailable).length}', Icons.check_circle_outline, AppColors.accentColor)),
                SizedBox(width: 12),
                Expanded(child: _buildStatCard('Pending Bookings', '$pendingBookings', Icons.hourglass_top, AppColors.warningColor)),
              ],
            ),
            SizedBox(height: 28),
            // Quick Actions Buttons matching screen 20
            Text(
              AppLanguage.tr('Quick Actions'),
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: Icon(Icons.add, size: 20),
                    label: Text(AppLanguage.tr('Add Car'), style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddCarScreen(onCarAdded: _loadDashboardData),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardColor,
                      foregroundColor: AppColors.primaryText,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: Icon(Icons.directions_car_outlined, size: 20, color: AppColors.primaryColor),
                    label: Text(AppLanguage.tr('Manage Fleet'), style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ManageCarsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            // Recent Bookings matching screen 20
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLanguage.tr('Recent Bookings'),
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ManageBookingsScreen()),
                    );
                  },
                  child: Text(AppLanguage.tr('See all'), style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (_bookings.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Center(
                  child: Text(AppLanguage.tr('No bookings recorded yet.'), style: TextStyle(color: AppColors.secondaryText)),
                ),
              )
            else
              ..._bookings.take(5).map((b) => BookingCard(
                    booking: b,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ManageBookingsScreen()),
                      );
                    },
                  )),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentBody;
    switch (_currentTabIndex) {
      case 0:
        currentBody = _buildDashboardView();
        break;
      case 1:
        currentBody = ManageCarsScreen();
        break;
      case 2:
        currentBody = ManageBookingsScreen();
        break;
      case 3:
        currentBody = AdminProfileScreen();
        break;
      default:
        currentBody = _buildDashboardView();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(child: currentBody),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          border: Border(top: BorderSide(color: AppColors.borderColor, width: 0.8)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) => setState(() => _currentTabIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.backgroundColor,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.secondaryText,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: AppLanguage.tr('Dashboard'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car_outlined),
              activeIcon: Icon(Icons.directions_car),
              label: AppLanguage.tr('Fleet'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: AppLanguage.tr('Bookings'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings),
              label: AppLanguage.tr('Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
