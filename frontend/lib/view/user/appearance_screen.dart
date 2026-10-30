import 'package:flutter/material.dart';
import 'package:frontend/const/app_colors.dart';
import 'package:frontend/repo/auth_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AppearanceScreen extends StatefulWidget {
  final String currentTheme;
  final VoidCallback? onUpdated;

  AppearanceScreen({super.key, this.currentTheme = 'dark', this.onUpdated});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  final AuthRepo _authRepo = AuthRepo();
  late String _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = AppColors.isDarkMode ? 'dark' : 'light';
  }

  Future<void> _selectTheme(String theme) async {
    setState(() {
      _selectedTheme = theme;
    });

    AppColors.setTheme(theme);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', theme);

    try {
      await _authRepo.updatePreferences(themeMode: theme);
      if (widget.onUpdated != null) widget.onUpdated!();
    } catch (_) {}

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appearance updated: ${theme == 'dark' ? 'Dark Mode' : 'Light Mode'}'),
        backgroundColor: AppColors.successColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildThemeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String modeKey,
  }) {
    final bool isSelected = _selectedTheme == modeKey;

    return GestureDetector(
      onTap: () => _selectTheme(modeKey),
      child: Container(
        margin: EdgeInsets.only(bottom: 14),
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.coralRed.withValues(alpha: 0.6) : AppColors.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondaryCardColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryText, size: 22),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.coralRed : AppColors.secondaryText.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.coralRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
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
          'Appearance',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            _buildThemeCard(
              title: 'Light Mode',
              subtitle: 'Light theme for a brighter look',
              icon: Icons.light_mode_outlined,
              modeKey: 'light',
            ),
            _buildThemeCard(
              title: 'Dark Mode',
              subtitle: 'Dark theme for a comfortable view',
              icon: Icons.dark_mode_outlined,
              modeKey: 'dark',
            ),
          ],
        ),
      ),
    );
  }
}
