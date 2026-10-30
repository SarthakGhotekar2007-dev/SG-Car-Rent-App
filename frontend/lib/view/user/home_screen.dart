import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../const/app_colors.dart';
import '../../const/app_language.dart';
import '../../model/car_model.dart';
import '../../model/category_model.dart';
import '../../repo/car_repo.dart';
import '../../repo/category_repo.dart';
import '../../repo/favorite_repo.dart';
import '../../widgets/car_card.dart';
import '../../widgets/category_card.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'car_details_screen.dart';
import 'explore_cars_screen.dart';
import 'my_bookings_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  final CarRepo _carRepo = CarRepo();
  final CategoryRepo _categoryRepo = CategoryRepo();
  final FavoriteRepo _favoriteRepo = FavoriteRepo();

  List<CarModel> _featuredCars = [];
  List<CarModel> _allCars = [];
  List<CategoryModel> _categories = [];
  Set<int> _favoriteCarIds = {};

  int _selectedCategoryId = 0;
  String _userName = 'Sarthak';
  bool _isLoading = true;

  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  final List<Map<String, String>> _promoBanners = [
    {
      'title': 'Luxury.\nPerformance.\nFreedom.',
      'subtitle': 'Rent premium cars at the best prices.',
      'asset': 'assets/images/banner_car.jpg',
      'network':
          'https://images.unsplash.com/photo-1617788138017-80ad40651399?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Weekend.\nAdventure.\nEscape.',
      'subtitle': 'Rent powerful 4x4 SUVs with special discounts.',
      'asset': 'assets/images/onboarding_2.jpg',
      'network':
          'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Go Electric.\nPure Power.\nFuture.',
      'subtitle': 'Zero emission Tesla & EV fleet for clean city drives.',
      'asset': 'assets/images/onboarding_3.jpg',
      'network':
          'https://images.unsplash.com/photo-1560958089-b8a1929cea89?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Executive.\nElegance.\nPrestige.',
      'subtitle': 'Chauffeur & self-drive VIP luxury sedans.',
      'asset': 'assets/images/onboarding_1.jpg',
      'network':
          'https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=400&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();

    _startBannerAutoScroll();
    _loadHomeData();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerAutoScroll() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || !_bannerController.hasClients) return;
      final nextIndex = (_currentBannerIndex + 1) % _promoBanners.length;
      _bannerController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  Future<void> _loadHomeData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'Sarthak';

    setState(() {
      _userName = name.split(' ').first;
      _isLoading = true;
    });

    try {
      final featured = await _carRepo.getFeaturedCars();
      final cars = await _carRepo.getAllCars();
      final cats = await _categoryRepo.getCategories();

      try {
        final favs = await _favoriteRepo.getFavorites();
        _favoriteCarIds = favs.map((c) => c.id).toSet();
      } catch (_) {}

      setState(() {
        _featuredCars = featured;
        _allCars = cars;
        _categories = cats;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
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

  Widget _buildHomeView() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHomeData,
      color: AppColors.primaryColor,
      backgroundColor: AppColors.cardColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Greeting & Icons matching screen 8
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLanguage.tr('Hello')}, $_userName !',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      AppLanguage.tr('Find your perfect ride'),
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.primaryText,
                        size: 26,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentTabIndex = 3; // Switch to profile tab
                        });
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.cardColor,
                        child: Icon(
                          Icons.favorite_border,
                          color: AppColors.heartColor,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildPromoBannerCarousel(),
            SizedBox(height: 26),
            // Categories Row matching screen 8
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLanguage.tr('Categories'),
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
                      MaterialPageRoute(
                        builder: (context) => ExploreCarsScreen(),
                      ),
                    );
                  },
                  child: Text(
                    AppLanguage.tr('See all'),
                    style: TextStyle(
                      color: AppColors.accentColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  CategoryCard(
                    title: AppLanguage.tr('All'),
                    icon: Icons.directions_car,
                    isSelected: _selectedCategoryId == 0,
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = 0;
                      });
                    },
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
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = cat.id;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ExploreCarsScreen(initialCategoryId: cat.id),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 26),
            // Featured Cars Carousel matching screen 8
            if (_featuredCars.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLanguage.tr('Featured Cars'),
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
                        MaterialPageRoute(
                          builder: (context) => ExploreCarsScreen(),
                        ),
                      );
                    },
                    child: Text(
                      AppLanguage.tr('See all'),
                      style: TextStyle(
                        color: AppColors.accentColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              SizedBox(
                height: 195,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _featuredCars.length,
                  itemBuilder: (context, index) {
                    final car = _featuredCars[index];
                    return CarCard(
                      car: car,
                      isHorizontal: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CarDetailsScreen(car: car),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 24),
            ],
            // Recommended Cars matching screen 8
            Text(
              AppLanguage.tr('Recommended For You'),
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 14),
            ..._allCars.map((car) {
              final isFav = _favoriteCarIds.contains(car.id);
              return CarCard(
                car: car,
                isFavorite: isFav,
                onFavoriteToggle: () => _toggleFavorite(car),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarDetailsScreen(car: car),
                    ),
                  );
                },
              );
            }),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBannerCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 148,
          child: PageView.builder(
            controller: _bannerController,
            physics: const BouncingScrollPhysics(),
            itemCount: _promoBanners.length,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final item = _promoBanners[index];
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLanguage.tr(item['title']!),
                            style: TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppLanguage.tr(item['subtitle']!),
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12.5,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 105,
                        height: 74,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryCardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          item['asset']!,
                          width: 105,
                          height: 74,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.network(
                                item['network']!,
                                width: 105,
                                height: 74,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 105,
                                      height: 74,
                                      color: AppColors.secondaryCardColor,
                                      child: Icon(
                                        Icons.directions_car,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_promoBanners.length, (index) {
            final bool isActive = _currentBannerIndex == index;
            return GestureDetector(
              onTap: () {
                _bannerController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryColor : AppColors.borderColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 5-Tab Navigation switching
    Widget currentBody;
    switch (_currentTabIndex) {
      case 0:
        currentBody = _buildHomeView();
        break;
      case 1:
        currentBody = ExploreCarsScreen();
        break;
      case 2:
        currentBody = MyBookingsScreen();
        break;
      case 3:
        currentBody = FavoritesScreen();
        break;
      case 4:
        currentBody = ProfileScreen();
        break;
      default:
        currentBody = _buildHomeView();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(child: currentBody),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
      ),
    );
  }
}
