import 'package:flutter/material.dart';
import 'package:frontend/const/app_colors.dart';
import 'package:frontend/model/car_model.dart';
import 'package:frontend/repo/car_repo.dart';
import 'package:frontend/widgets/custom_button.dart';
import 'package:frontend/widgets/custom_text_field.dart';


class EditCarScreen extends StatefulWidget {
  final CarModel car;
  final VoidCallback onCarUpdated;

  EditCarScreen({super.key, required this.car, required this.onCarUpdated});

  @override
  State<EditCarScreen> createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  final CarRepo _carRepo = CarRepo();

  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  late TextEditingController _descController;
  late bool _isAvailable;
  late bool _isFeatured;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.car.name);
    _brandController = TextEditingController(text: widget.car.brand);
    _priceController = TextEditingController(text: widget.car.pricePerDay.toStringAsFixed(0));
    _imageController = TextEditingController(text: widget.car.imageUrl);
    _descController = TextEditingController(text: widget.car.description);
    _isAvailable = widget.car.isAvailable;
    _isFeatured = widget.car.isFeatured;
  }

  Future<void> _updateCar() async {
    final name = _nameController.text.trim();
    final brand = _brandController.text.trim();
    final priceStr = _priceController.text.trim();
    final imageUrl = _imageController.text.trim();

    if (name.isEmpty || brand.isEmpty || priceStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _carRepo.updateCar(widget.car.id, {
        'name': name,
        'brand': brand,
        'price_per_day': double.tryParse(priceStr) ?? widget.car.pricePerDay,
        'image_url': imageUrl,
        'description': _descController.text.trim(),
        'is_available': _isAvailable,
        'is_featured': _isFeatured,
      });

      if (!mounted) return;

      widget.onCarUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Car updated successfully!'),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Edit Car', style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold)),
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
              CustomTextField(
                label: 'Car Model Name',
                hint: 'e.g. BMW M4',
                controller: _nameController,
              ),
              SizedBox(height: 16),
              CustomTextField(
                label: 'Brand',
                hint: 'e.g. BMW',
                controller: _brandController,
              ),
              SizedBox(height: 16),
              CustomTextField(
                label: 'Daily Price (₹)',
                hint: 'e.g. 150',
                controller: _priceController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              CustomTextField(
                label: 'Image URL',
                hint: 'https://...',
                controller: _imageController,
              ),
              SizedBox(height: 16),
              CustomTextField(
                label: 'Description',
                hint: 'Description...',
                controller: _descController,
                maxLines: 3,
              ),
              SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primaryColor,
                title: Text('Featured on Home Screen', style: TextStyle(color: AppColors.primaryText, fontSize: 14)),
                value: _isFeatured,
                onChanged: (val) => setState(() => _isFeatured = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primaryColor,
                title: Text('Available for Booking', style: TextStyle(color: AppColors.primaryText, fontSize: 14)),
                value: _isAvailable,
                onChanged: (val) => setState(() => _isAvailable = val),
              ),
              SizedBox(height: 28),
              CustomButton(
                text: 'Update Car',
                isLoading: _isLoading,
                onPressed: _updateCar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
