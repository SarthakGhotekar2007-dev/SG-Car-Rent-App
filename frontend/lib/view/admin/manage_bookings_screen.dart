import 'package:flutter/material.dart';
import 'package:frontend/const/app_colors.dart';
import 'package:frontend/const/app_language.dart';
import 'package:frontend/model/booking_model.dart';
import 'package:frontend/repo/booking_repo.dart';
import 'package:url_launcher/url_launcher.dart';


class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

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

  Future<void> _callCustomer(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLanguage.tr('Phone number not available')),
          backgroundColor: AppColors.warningColor,
        ),
      );
      return;
    }
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot launch phone dialer for $cleanPhone'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  Future<void> _emailCustomer(String email, BookingModel booking) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLanguage.tr('Email not available')),
          backgroundColor: AppColors.warningColor,
        ),
      );
      return;
    }
    final carName = booking.car?.name ?? 'Car #${booking.carId}';
    final subject = Uri.encodeComponent('SG Car Rent - Booking #${booking.id} ($carName)');
    final uri = Uri.parse('mailto:$email?subject=$subject');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot launch email client for $email'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  Future<void> _updateStatus(BookingModel booking) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:  EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLanguage.tr('Update Booking Status'),
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                 SizedBox(height: 16),
                ListTile(
                  title: Text(
                    AppLanguage.tr('Confirmed'),
                    style: TextStyle(color: AppColors.successColor, fontWeight: FontWeight.bold),
                  ),
                  leading: Icon(Icons.check_circle, color: AppColors.successColor),
                  onTap: () => Navigator.pop(context, 'confirmed'),
                ),
                ListTile(
                  title: Text(
                    AppLanguage.tr('Completed'),
                    style: TextStyle(color: AppColors.accentColor, fontWeight: FontWeight.bold),
                  ),
                  leading: Icon(Icons.done_all, color: AppColors.accentColor),
                  onTap: () => Navigator.pop(context, 'completed'),
                ),
                ListTile(
                  title: Text(
                    AppLanguage.tr('Cancelled'),
                    style: TextStyle(color: AppColors.errorColor, fontWeight: FontWeight.bold),
                  ),
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

  void _showBookingDetails(BookingModel b) {
    final color = _getStatusColor(b.status);
    final displayName = b.userName.isNotEmpty ? b.userName : 'Customer #${b.userId}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardColor,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding:  EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                   SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLanguage.tr('Booking Request Details'),
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: color.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          AppLanguage.tr(b.status.toUpperCase()),
                          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                   SizedBox(height: 18),

                  // Customer Profile Banner
                  Container(
                    width: double.infinity,
                    padding:  EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryCardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: b.userAvatar.isNotEmpty
                                    ? Image.network(
                                        b.userAvatar,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: AppColors.primaryColor.withValues(alpha: 0.2),
                                          alignment: Alignment.center,
                                          child: Text(
                                            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                            style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: AppColors.primaryColor.withValues(alpha: 0.2),
                                        alignment: Alignment.center,
                                        child: Text(
                                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                    displayName,
                                    style: TextStyle(
                                      color: AppColors.primaryText,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                   SizedBox(height: 2),
                                  Text(
                                    '${AppLanguage.tr('User ID')}: #${b.userId}',
                                    style: TextStyle(
                                      color: AppColors.secondaryText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                         SizedBox(height: 14),
                         Divider(color: Color(0xFF293B54), height: 1),
                         SizedBox(height: 12),
                        if (b.userEmail.isNotEmpty)
                          Padding(
                            padding:  EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(Icons.email_outlined, size: 16, color: AppColors.accentColor),
                                 SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    b.userEmail,
                                    style: TextStyle(color: AppColors.primaryText, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (b.userPhone.isNotEmpty)
                          Padding(
                            padding:  EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(Icons.phone_outlined, size: 16, color: AppColors.successColor),
                                 SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    b.userPhone,
                                    style: TextStyle(color: AppColors.primaryText, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryColor),
                             SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${AppLanguage.tr('Location:')} ${b.pickupLocation}',
                                style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                         SizedBox(height: 14),
                        Row(
                          children: [
                            if (b.userPhone.isNotEmpty)
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.successColor,
                                    foregroundColor: Colors.white,
                                    padding:  EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon:  Icon(Icons.call, size: 16),
                                  label: Text(AppLanguage.tr('Call Customer'), style:  TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  onPressed: () => _callCustomer(b.userPhone),
                                ),
                              ),
                            if (b.userPhone.isNotEmpty && b.userEmail.isNotEmpty)
                               SizedBox(width: 10),
                            if (b.userEmail.isNotEmpty)
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding:  EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon:  Icon(Icons.mail_outline, size: 16),
                                  label: Text(AppLanguage.tr('Email Customer'), style:  TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  onPressed: () => _emailCustomer(b.userEmail, b),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                   SizedBox(height: 20),

                  // Car & Booking Summary
                  Text(
                    AppLanguage.tr('Booking Details'),
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                   SizedBox(height: 10),
                  Container(
                    padding:  EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 70,
                                height: 50,
                                child: b.car?.imageUrl != null && b.car!.imageUrl.isNotEmpty
                                    ? Image.network(
                                        b.car!.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: AppColors.secondaryCardColor,
                                          child: Icon(Icons.directions_car, color: AppColors.secondaryText),
                                        ),
                                      )
                                    : Container(
                                        color: AppColors.secondaryCardColor,
                                        child: Icon(Icons.directions_car, color: AppColors.secondaryText),
                                      ),
                              ),
                            ),
                             SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.car?.name ?? 'Car #${b.carId}',
                                    style: TextStyle(
                                      color: AppColors.primaryText,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (b.car?.brand != null)
                                    Text(
                                      b.car!.brand,
                                      style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                         SizedBox(height: 12),
                         Divider(color: Color(0xFF293B54), height: 1),
                         SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLanguage.tr('Dates:'), style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                            Text('${b.startDate} ➔ ${b.endDate}', style: TextStyle(color: AppColors.primaryText, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                         SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLanguage.tr('Total Days:'), style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                            Text('${b.totalDays} ${AppLanguage.tr('days')}', style: TextStyle(color: AppColors.primaryText, fontSize: 13)),
                          ],
                        ),
                         SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLanguage.tr('Total Amount:'), style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                            Text('₹${b.totalPrice.toStringAsFixed(0)}', style: TextStyle(color: AppColors.primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                   SizedBox(height: 22),

                  // Status Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primaryColor),
                            padding:  EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _updateStatus(b);
                          },
                          child: Text(AppLanguage.tr('Update Status'), style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                        ),
                      ),
                       SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cardColor,
                            foregroundColor: AppColors.secondaryText,
                            padding:  EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: AppColors.borderColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLanguage.tr('Close')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin:  EdgeInsets.only(right: 10),
        padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primaryColor : AppColors.borderColor),
        ),
        child: Text(
          AppLanguage.tr(label),
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primaryText,
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
          AppLanguage.tr('All Bookings'),
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
              padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                  : _filteredBookings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month_outlined, size: 60, color: AppColors.secondaryText),
                               SizedBox(height: 12),
                              Text(
                                AppLanguage.tr('No bookings found'),
                                style: TextStyle(
                                  color: AppColors.primaryText,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadBookings,
                          color: AppColors.primaryColor,
                          backgroundColor: AppColors.cardColor,
                          child: ListView.builder(
                            padding:  EdgeInsets.all(16),
                            itemCount: _filteredBookings.length,
                            itemBuilder: (context, index) {
                              final b = _filteredBookings[index];
                              final color = _getStatusColor(b.status);
                              final displayName = b.userName.isNotEmpty
                                  ? b.userName
                                  : 'Customer #${b.userId}';

                              return GestureDetector(
                                onTap: () => _showBookingDetails(b),
                                child: Container(
                                  margin:  EdgeInsets.only(bottom: 16),
                                  padding:  EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardColor,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: AppColors.borderColor, width: 1),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top Header: Car Name and Status Badge
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              b.car?.name ?? 'Car #${b.carId}',
                                              style: TextStyle(
                                                color: AppColors.primaryText,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                           SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => _updateStatus(b),
                                            child: Container(
                                              padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                       SizedBox(height: 10),

                                      // Customer Info Section (Prominent Customer Card)
                                      Container(
                                        padding:  EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryCardColor,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.5)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                ClipOval(
                                                  child: SizedBox(
                                                    width: 36,
                                                    height: 36,
                                                    child: b.userAvatar.isNotEmpty
                                                        ? Image.network(
                                                            b.userAvatar,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context, error, stackTrace) => Container(
                                                              color: AppColors.primaryColor.withValues(alpha: 0.2),
                                                              alignment: Alignment.center,
                                                              child: Text(
                                                                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                                                style: TextStyle(
                                                                  color: AppColors.primaryColor,
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(
                                                            color: AppColors.primaryColor.withValues(alpha: 0.2),
                                                            alignment: Alignment.center,
                                                            child: Text(
                                                              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                                              style: TextStyle(
                                                                color: AppColors.primaryColor,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                                 SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        displayName,
                                                        style: TextStyle(
                                                          color: AppColors.primaryText,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      Text(
                                                        '${AppLanguage.tr('User ID')}: #${b.userId}',
                                                        style: TextStyle(
                                                          color: AppColors.secondaryText,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Quick action contact icons
                                                if (b.userPhone.isNotEmpty)
                                                  IconButton(
                                                    icon: Icon(Icons.phone, color: AppColors.successColor, size: 20),
                                                    onPressed: () => _callCustomer(b.userPhone),
                                                    tooltip: AppLanguage.tr('Call Customer'),
                                                    padding: EdgeInsets.zero,
                                                    constraints:  BoxConstraints(),
                                                  ),
                                                if (b.userPhone.isNotEmpty && b.userEmail.isNotEmpty)
                                                   SizedBox(width: 8),
                                                if (b.userEmail.isNotEmpty)
                                                  IconButton(
                                                    icon: Icon(Icons.email, color: AppColors.accentColor, size: 20),
                                                    onPressed: () => _emailCustomer(b.userEmail, b),
                                                    tooltip: AppLanguage.tr('Email Customer'),
                                                    padding: EdgeInsets.zero,
                                                    constraints:  BoxConstraints(),
                                                  ),
                                              ],
                                            ),
                                            if (b.userEmail.isNotEmpty || b.userPhone.isNotEmpty) ...[
                                               SizedBox(height: 8),
                                              if (b.userEmail.isNotEmpty)
                                                Padding(
                                                  padding:  EdgeInsets.only(bottom: 2),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.email_outlined, size: 13, color: AppColors.secondaryText),
                                                       SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          b.userEmail,
                                                          style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (b.userPhone.isNotEmpty)
                                                Row(
                                                  children: [
                                                    Icon(Icons.phone_outlined, size: 13, color: AppColors.secondaryText),
                                                     SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        b.userPhone,
                                                        style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ],
                                        ),
                                      ),
                                       SizedBox(height: 10),

                                      // Dates & Location
                                      Text(
                                        '${AppLanguage.tr('Dates:')} ${b.startDate} to ${b.endDate} (${b.totalDays} ${AppLanguage.tr('days')})',
                                        style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                                      ),
                                       SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.location_on_outlined, size: 14, color: AppColors.secondaryText),
                                               SizedBox(width: 4),
                                              Text(
                                                b.pickupLocation,
                                                style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${AppLanguage.tr('Total:')} ₹${b.totalPrice.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              color: AppColors.primaryText,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
