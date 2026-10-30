import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../const/app_colors.dart';
import '../../repo/auth_repo.dart';

import '../../const/app_language.dart';

class LanguageScreen extends StatefulWidget {
  final String currentLanguage;
  final VoidCallback? onUpdated;

  LanguageScreen({super.key, this.currentLanguage = 'English', this.onUpdated});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final AuthRepo _authRepo = AuthRepo();
  late String _selectedLanguage;

  final List<String> _languages = [
    'English',
    'Marathi',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = AppLanguage.currentLanguage;
  }

  Future<void> _selectLanguage(String lang) async {
    setState(() {
      _selectedLanguage = lang;
    });

    AppLanguage.setLanguage(lang);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);

    try {
      await _authRepo.updatePreferences(language: lang);
      if (widget.onUpdated != null) widget.onUpdated!();
    } catch (_) {}

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          lang == 'Marathi'
              ? 'भाषा मराठीमध्ये बदलली!'
              : 'Language set to English',
        ),
        backgroundColor: AppColors.successColor,
        duration: Duration(seconds: 2),
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
          AppLanguage.tr('Language'),
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
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: _languages.length,
          separatorBuilder: (context, index) => SizedBox(height: 10),
          itemBuilder: (context, index) {
            final lang = _languages[index];
            final bool isSelected = lang == _selectedLanguage;

            return GestureDetector(
              onTap: () => _selectLanguage(lang),
              child: Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
          },
        ),
      ),
    );
  }
}
