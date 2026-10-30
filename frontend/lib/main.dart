import 'package:flutter/material.dart';
import 'const/app_colors.dart';
import 'const/app_language.dart';
import 'view/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppColors.initTheme();
  await AppLanguage.initLanguage();
  runApp(SGCarRentApp());
}

class SGCarRentApp extends StatelessWidget {
  SGCarRentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, child) {
        return ValueListenableBuilder<String>(
          valueListenable: AppLanguage.languageNotifier,
          builder: (context, lang, child) {
            return MaterialApp(
              key: ValueKey('sg_app_${lang}_$isDark'),
              title: "SG Car Rent",
              debugShowCheckedModeBanner: false,
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              theme: ThemeData(
                fontFamily: 'Roboto',
                brightness: Brightness.light,
                scaffoldBackgroundColor: AppColors.backgroundColor,
                cardColor: AppColors.cardColor,
                primaryColor: AppColors.primaryColor,
                colorScheme: ColorScheme.light(
                  primary: AppColors.primaryColor,
                  secondary: AppColors.accentColor,
                  surface: AppColors.cardColor,
                  error: AppColors.errorColor,
                ),
                textTheme: ThemeData.light().textTheme.apply(
                  fontFamily: 'Roboto',
                  bodyColor: AppColors.primaryText,
                  displayColor: AppColors.primaryText,
                ),
                appBarTheme: AppBarTheme(
                  backgroundColor: AppColors.backgroundColor,
                  elevation: 0,
                  iconTheme: IconThemeData(color: AppColors.primaryText),
                  titleTextStyle: TextStyle(
                    fontFamily: 'Roboto',
                    color: AppColors.primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              darkTheme: ThemeData(
                fontFamily: 'Roboto',
                brightness: Brightness.dark,
                scaffoldBackgroundColor: AppColors.backgroundColor,
                cardColor: AppColors.cardColor,
                primaryColor: AppColors.primaryColor,
                colorScheme: ColorScheme.dark(
                  primary: AppColors.primaryColor,
                  secondary: AppColors.accentColor,
                  surface: AppColors.cardColor,
                  error: AppColors.errorColor,
                ),
                textTheme: ThemeData.dark().textTheme.apply(
                  fontFamily: 'Roboto',
                  bodyColor: AppColors.primaryText,
                  displayColor: AppColors.primaryText,
                ),
                appBarTheme: AppBarTheme(
                  backgroundColor: AppColors.backgroundColor,
                  elevation: 0,
                  iconTheme: IconThemeData(color: AppColors.primaryText),
                  titleTextStyle: TextStyle(
                    fontFamily: 'Roboto',
                    color: AppColors.primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
