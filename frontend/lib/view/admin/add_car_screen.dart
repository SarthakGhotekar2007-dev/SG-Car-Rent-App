import 'package:flutter/material.dart';
import 'package:frontend/const/app_colors.dart';
import 'package:frontend/model/category_model.dart';
import 'package:frontend/repo/car_repo.dart';
import 'package:frontend/repo/category_repo.dart';
import 'package:frontend/widgets/custom_button.dart';
import 'package:frontend/widgets/custom_text_field.dart';


class AddCarScreen extends StatefulWidget {
  final VoidCallback onCarAdded;

  AddCarScreen({super.key, required this.onCarAdded});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final CarRepo _carRepo = CarRepo();
  final CategoryRepo _categoryRepo = CategoryRepo();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageController = TextEditingController(
    text: 'https://images.unsplash.com/photo-1617788138017-80ad40651399?auto=format&fit=crop&w=800&q=80',
  );
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController(text: '4');

  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;
  String _selectedTransmission = 'Automatic';
  String _selectedFuelType = 'Petrol';
  bool _isFeatured = true;
  bool _isAvailable = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _categoryRepo.getCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          if (cats.isNotEmpty) {
            _selectedCategoryId = cats.first.id;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _submitCar() async {
    final name = _nameController.text.trim();
    final brand = _brandController.text.trim();
    final priceStr = _priceController.text.trim();
    final imageUrl = _imageController.text.trim();
    final seatsStr = _seatsController.text.trim();

    if (name.isEmpty || brand.isEmpty || priceStr.isEmpty || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required car details')),
      );
      return;
    }

    final price = double.tryParse(priceStr) ?? 150.0;
    final seats = int.tryParse(seatsStr) ?? 4;

    setState(() {
      _isLoading = true;
    });

    try {
      await _carRepo.addCar({
        'name': name,
        'brand': brand,
        'category_id': _selectedCategoryId ?? 1,
        'price_per_day': price,
        'image_url': imageUrl,
        'transmission': _selectedTransmission,
        'fuel_type': _selectedFuelType,
        'seats': seats,
        'is_available': _isAvailable,
        'is_featured': _isFeatured,
        'rating': 4.9,
        'description': _descController.text.trim().isNotEmpty
            ? _descController.text.trim()
            : 'Uncompromising luxury, power, and prestige.',
      });

      if (!mounted) return;

      widget.onCarAdded();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New car added to fleet successfully!'),
          backgroundColor: AppColors.successColor,
        ),
      );
      Navigator.pop(context);
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
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _descController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:  Text('Add New Car', style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:  EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Car Model Name',
                hint: 'e.g. BMW M4 Competition',
                controller: _nameController,
                prefixIcon: Icons.directions_car_outlined,
              ),
              SizedBox(height: 16),
              CustomTextField(
                label: 'Brand',
                hint: 'e.g. BMW, Tesla, Mercedes',
                controller: _brandController,
                prefixIcon: Icons.branding_watermark_outlined,
              ),
               SizedBox(height: 16),
              // Category Dropdown
               Text('Category', style: TextStyle(color: AppColors.primaryText, fontSize: 14, fontWeight: FontWeight.w600)),
               SizedBox(height: 8),
              Container(
                padding:  EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedCategoryId,
                    dropdownColor: AppColors.cardColor,
                    isExpanded: true,
                    items: _categories.map((cat) {
                      return DropdownMenuItem<int>(
                        value: cat.id,
                        child: Text(cat.name, style: TextStyle(color: AppColors.primaryText)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategoryId = val;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              CustomTextField(
                label: 'Daily Rental Price (₹)',
                hint: 'e.g. 150',
                controller: _priceController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money,
              ),
              SizedBox(height: 16),
              CustomTextField(
                label: 'Car Photo Image URL',
                hint: 'https://...',
                controller: _imageController,
                prefixIcon: Icons.image_outlined,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text('Transmission', style: TextStyle(color: AppColors.primaryText, fontSize: 14, fontWeight: FontWeight.w600)),
                         SizedBox(height: 8),
                        Container(
                          padding:   EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedTransmission,
                              dropdownColor: AppColors.cardColor,
                              isExpanded: true,
                              items: ['Automatic', 'Manual'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: TextStyle(color: AppColors.primaryText, fontSize: 13)))).toList(),
                              onChanged: (v) => setState(() => _selectedTransmission = v ?? 'Automatic'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                   SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text('Fuel Type', style: TextStyle(color: AppColors.primaryText, fontSize: 14, fontWeight: FontWeight.w600)),
                         SizedBox(height: 8),
                        Container(
                          padding:   EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedFuelType,
                              dropdownColor: AppColors.cardColor,
                              isExpanded: true,
                              items: ['Petrol', 'Diesel', 'Electric', 'Hybrid'].map((f) => DropdownMenuItem(value: f, child: Text(f, style: TextStyle(color: AppColors.primaryText, fontSize: 13)))).toList(),
                              onChanged: (v) => setState(() => _selectedFuelType = v ?? 'Petrol'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
               SizedBox(height: 16),
              CustomTextField(
                label: 'Description',
                hint: 'Tell customers about features, performance, and experience...',
                controller: _descController,
                maxLines: 3,
              ),
               SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primaryColor,
                title: Text('Show as Featured on Home Screen', style: TextStyle(color: AppColors.primaryText, fontSize: 14)),
                value: _isFeatured,
                onChanged: (val) => setState(() => _isFeatured = val),
              ),
              SwitchListTile(     
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primaryColor,
                title: Text('Car is Available for Booking', style: TextStyle(color: AppColors.primaryText, fontSize: 14)),
                value: _isAvailable,
                onChanged: (val) => setState(() => _isAvailable = val),
              ),
               SizedBox(height: 28),
              CustomButton(
                text: 'Add Car to Fleet',
                isLoading: _isLoading,
                onPressed: _submitCar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
