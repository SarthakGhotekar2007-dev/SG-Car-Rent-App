import 'package:flutter/material.dart';
import 'package:frontend/const/app_colors.dart';
import 'package:frontend/const/app_language.dart';
import 'package:frontend/model/car_model.dart';
import 'package:frontend/repo/car_repo.dart';
import 'package:frontend/widgets/custom_button.dart';

import 'add_car_screen.dart';
import 'edit_car_screen.dart';

class ManageCarsScreen extends StatefulWidget {
  ManageCarsScreen({super.key});

  @override
  State<ManageCarsScreen> createState() => _ManageCarsScreenState();
}

class _ManageCarsScreenState extends State<ManageCarsScreen> {
  final CarRepo _carRepo = CarRepo();
  final TextEditingController _searchController = TextEditingController();

  List<CarModel> _cars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final list = await _carRepo.getAllCars(
        search: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
      );
      setState(() {
        _cars = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCar(CarModel car) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        title: Text(AppLanguage.tr('Delete Car?'), style: TextStyle(color: AppColors.primaryText)),
        content: Text(
          'Are you sure you want to remove "${car.name}" from your fleet?',
          style: TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLanguage.tr('Cancel'), style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorColor),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLanguage.tr('Delete'), style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _carRepo.deleteCar(car.id);
      _loadCars();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Car "${car.name}" deleted successfully')),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLanguage.tr('Manage Fleet'), style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold)),
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
            // Search Input matching screen 21
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor, width: 1),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => _loadCars(),
                  style: TextStyle(color: AppColors.primaryText, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: AppLanguage.tr('Search fleet cars...'),
                    hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: AppColors.secondaryText, size: 22),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            // Car list matching screen 21
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                  : _cars.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.directions_car_outlined, size: 60, color: AppColors.secondaryText),
                              SizedBox(height: 12),
                              Text(AppLanguage.tr('No cars found in fleet'), style: TextStyle(color: AppColors.primaryText, fontSize: 17, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadCars,
                          color: AppColors.primaryColor,
                          backgroundColor: AppColors.cardColor,
                          child: ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: _cars.length,
                            itemBuilder: (context, index) {
                              final car = _cars[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 14),
                                padding: EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.borderColor, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        car.imageUrl,
                                        width: 80,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 80,
                                          height: 60,
                                          color: AppColors.secondaryCardColor,
                                          child: Icon(Icons.directions_car, color: AppColors.secondaryText),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            car.name,
                                            style: TextStyle(
                                              color: AppColors.primaryText,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '₹${car.pricePerDay.toStringAsFixed(0)}${AppLanguage.tr('/day')} • ${car.brand}',
                                            style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                                          ),
                                          SizedBox(height: 4),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: car.isAvailable
                                                  ? AppColors.successColor.withValues(alpha: 0.15)
                                                  : AppColors.errorColor.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              AppLanguage.tr(car.isAvailable ? 'AVAILABLE' : 'UNAVAILABLE'),
                                              style: TextStyle(
                                                color: car.isAvailable ? AppColors.successColor : AppColors.errorColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit_outlined, color: AppColors.primaryText, size: 20),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditCarScreen(car: car, onCarUpdated: _loadCars),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: AppColors.errorColor, size: 20),
                                      onPressed: () => _deleteCar(car),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: CustomButton(
                text: AppLanguage.tr('Add New Car'),
                icon: Icons.add,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCarScreen(onCarAdded: _loadCars),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
