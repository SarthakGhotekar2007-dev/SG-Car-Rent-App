import 'package:flutter/material.dart';
import '../../const/app_colors.dart';
import '../../const/app_language.dart';
import '../../model/car_model.dart';
import '../../model/category_model.dart';
import '../../repo/car_repo.dart';
import '../../repo/category_repo.dart';
import '../../repo/favorite_repo.dart';
import '../../widgets/car_card.dart';
import '../../widgets/category_card.dart';
import 'car_details_screen.dart';

class ExploreCarsScreen extends StatefulWidget {
  final int? initialCategoryId;

  ExploreCarsScreen({super.key, this.initialCategoryId});

  @override
  State<ExploreCarsScreen> createState() => _ExploreCarsScreenState();
}

class _ExploreCarsScreenState extends State<ExploreCarsScreen> {
  final CarRepo _carRepo = CarRepo();
  final CategoryRepo _categoryRepo = CategoryRepo();
  final FavoriteRepo _favoriteRepo = FavoriteRepo();
  final TextEditingController _searchController = TextEditingController();

  List<CarModel> _cars = [];
  List<CategoryModel> _categories = [];
  Set<int> _favoriteCarIds = {};

  int _selectedCategoryId = 0; // 0 = All
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId ?? 0;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cats = await _categoryRepo.getCategories();
      final cars = await _carRepo.getAllCars(
        categoryId: _selectedCategoryId > 0 ? _selectedCategoryId : null,
        search: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
      );

      // Fetch user favorites to highlight hearts
      try {
        final favs = await _favoriteRepo.getFavorites();
        _favoriteCarIds = favs.map((c) => c.id).toSet();
      } catch (_) {}

      setState(() {
        _categories = cats;
        _cars = cars;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onCategorySelected(int categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _loadData();
  }

  void _onSearchChanged(String query) {
    _loadData();
  }

  void _toggleFavorite(CarModel car) async {
    final isFav = _favoriteCarIds.contains(car.id);
    setState(() {
      if (isFav) {
        _favoriteCarIds.remove(car.id);
      } else {
        _favoriteCarIds.add(car.id);
      }
    });

    try {
      if (isFav) {
        await _favoriteRepo.removeFavorite(car.id);
      } else {
        await _favoriteRepo.addFavorite(car.id);
      }
    } catch (_) {}
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
        title: Text(
          AppLanguage.tr('Explore Cars'),
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
            // Search Input matching screens 9 & 10
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
                  onChanged: _onSearchChanged,
                  style: TextStyle(color: AppColors.primaryText, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: AppLanguage.tr('Search cars, brands, or categories...'),
                    hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: AppColors.secondaryText, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppColors.secondaryText, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _loadData();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            // Category Selector Horizontal Row matching screen 9
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    CategoryCard(
                      title: AppLanguage.tr('All'),
                      icon: Icons.directions_car,
                      isSelected: _selectedCategoryId == 0,
                      onTap: () => _onCategorySelected(0),
                    ),
                    ..._categories.map((cat) {
                      IconData icon = Icons.directions_car_filled;
                      final s = cat.slug.toLowerCase();
                      if (s.contains('traveller') || s.contains('tempo')) {
                        icon = Icons.directions_bus;
                      } else if (s.contains('family') || s.contains('muv')) {
                        icon = Icons.people_outline;
                      } else if (s.contains('hatchback')) {
                        icon = Icons.time_to_leave;
                      } else if (s.contains('suv')) {
                        icon = Icons.airport_shuttle;
                      } else if (s.contains('mpv')) {
                        icon = Icons.airline_seat_recline_extra;
                      } else if (s.contains('luxury')) {
                        icon = Icons.star;
                      } else if (s.contains('sedan')) {
                        icon = Icons.directions_car_filled;
                      } else if (s.contains('electric')) {
                        icon = Icons.electric_car;
                      }

                      return CategoryCard(
                        title: cat.name,
                        icon: icon,
                        isSelected: _selectedCategoryId == cat.id,
                        onTap: () => _onCategorySelected(cat.id),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Cars List matching screens 9 & 10
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                  : _cars.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 60, color: AppColors.secondaryText),
                              SizedBox(height: 14),
                              Text(
                                AppLanguage.tr('No matching cars found'),
                                style: TextStyle(color: AppColors.primaryText, fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 6),
                              Text(
                                AppLanguage.tr('Try adjusting your search query or category filter.'),
                                style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: AppColors.primaryColor,
                          backgroundColor: AppColors.cardColor,
                          child: ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: _cars.length,
                            itemBuilder: (context, index) {
                              final car = _cars[index];
                              final isFav = _favoriteCarIds.contains(car.id);
                              return CarCard(
                                car: car,
                                isFavorite: isFav,
                                onFavoriteToggle: () => _toggleFavorite(car),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => CarDetailsScreen(car: car)),
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
