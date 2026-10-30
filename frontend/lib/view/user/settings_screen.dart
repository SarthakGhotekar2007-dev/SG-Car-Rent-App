import 'package:flutter/material.dart';
import '../../const/app_colors.dart';
import '../../const/app_language.dart';
import '../../model/user_model.dart';
import 'notifications_screen.dart';
import 'language_screen.dart';
import 'appearance_screen.dart';

class SettingsScreen extends StatelessWidget {
  final UserModel? user;
  final VoidCallback? onUpdated;

  SettingsScreen({super.key, this.user, this.onUpdated});

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.secondaryCardColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryText, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 2),
          child: Text(
            subtitle,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: AppColors.secondaryText, size: 16),
      ),
    );
  }

  void _showAppInformation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'App Information',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.primaryText),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildInfoRow('Application Name', 'SG Car Rent'),
              _buildInfoRow('Version', '1.0.0'),
              _buildInfoRow('Developer', 'Sarthak Ghotekar'),
              _buildInfoRow('Technology', '• Flutter \n• FastAPI \n• Supabase PostgreSQL'),
              SizedBox(height: 16),
              Text(
                'SG Car Rent is a full-stack luxury car rental management platform delivering seamless ride bookings and fleet administration.',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 13, height: 1.4),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showHelpSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Help & Support',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.primaryText),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.email_outlined, color: AppColors.coralRed),
                title: Text('Customer Support Email', style: TextStyle(color: AppColors.primaryText, fontSize: 14)),
                subtitle: Text('sarthakghotekar8055@gmail.com', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.phone_outlined, color: AppColors.successColor),
                title: Text('24x7 Roadside Assistance', style: TextStyle(color: AppColors.primaryText, fontSize: 14)),
                subtitle: Text('+91 80876 15815', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.location_on_outlined, color: Colors.blueAccent),
                title: Text('Headquarters', style: TextStyle(color: AppColors.primaryText, fontSize: 14)),
                subtitle: Text('Sinnar, Maharashtra, India', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
          Text(value, style: TextStyle(color: AppColors.primaryText, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
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
          AppLanguage.tr('Settings'),
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
            _buildSettingsItem(
              context: context,
              icon: Icons.notifications_none_rounded,
              title: AppLanguage.tr('Notifications'),
              subtitle: AppLanguage.tr('Control your alerts and updates'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsScreen()),
                );
              },
            ),
            _buildSettingsItem(
              context: context,
              icon: Icons.language_rounded,
              title: AppLanguage.tr('Language'),
              subtitle: AppLanguage.tr('Change app language'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LanguageScreen(
                      currentLanguage: AppLanguage.currentLanguage,
                      onUpdated: onUpdated,
                    ),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              context: context,
              icon: Icons.brightness_4_outlined,
              title: AppLanguage.tr('Appearance'),
              subtitle: AppLanguage.tr('Light / Dark mode'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppearanceScreen(
                      currentTheme: AppColors.isDarkMode ? 'dark' : 'light',
                      onUpdated: onUpdated,
                    ),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              context: context,
              icon: Icons.info_outline,
              title: AppLanguage.tr('App Information'),
              subtitle: AppLanguage.tr('Version, terms and more'),
              onTap: () => _showAppInformation(context),
            ),
            _buildSettingsItem(
              context: context,
              icon: Icons.help_outline_rounded,
              title: AppLanguage.tr('Help & Support'),
              subtitle: AppLanguage.tr('Get help or contact us'),
              onTap: () => _showHelpSupport(context),
            ),
          ],
        ),
      ),
    );
  }
}
