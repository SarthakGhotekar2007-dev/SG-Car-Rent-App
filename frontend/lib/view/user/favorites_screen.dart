import 'package:flutter/material.dart';
import '../../const/app_colors.dart';
import '../../const/app_language.dart';
import '../../model/car_model.dart';
import '../../repo/favorite_repo.dart';
import '../../widgets/car_card.dart';
import 'car_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteRepo _favoriteRepo = FavoriteRepo();
  List<CarModel> _favoriteCars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final list = await _favoriteRepo.getFavorites();
      setState(() {
        _favoriteCars = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(int carId) async {
    try {
      await _favoriteRepo.removeFavorite(carId);
      setState(() {
        _favoriteCars.removeWhere((c) => c.id == carId);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLanguage.tr('Removed from favorites'))),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLanguage.tr('Favorites'),
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
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
            : _favoriteCars.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.heartColor),
                        SizedBox(height: 16),
                        Text(
                          AppLanguage.tr('No favorite cars yet'),
                          style: TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text(
                          AppLanguage.tr('Tap the heart icon on any car to save it here.'),
                          style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadFavorites,
                    color: AppColors.primaryColor,
                    backgroundColor: AppColors.cardColor,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _favoriteCars.length,
                      itemBuilder: (context, index) {
                        final car = _favoriteCars[index];
                        return CarCard(
                          car: car,
                          isFavorite: true,
                          onFavoriteToggle: () => _removeFavorite(car.id),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CarDetailsScreen(car: car)),
                            ).then((_) => _loadFavorites());
                          },
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
