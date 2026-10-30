import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../const/app_colors.dart';
import '../../const/app_language.dart';
import '../../model/user_model.dart';
import '../../repo/auth_repo.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'privacy_security_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepo _authRepo = AuthRepo();
  UserModel? _user;
  String _userName = 'sarthak ghotekar';
  String _userEmail = 'sarthak123@gmail.com';
  Uint8List? _avatarBytes;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAvatar = prefs.getString('user_avatar_base64');
    final savedAvatarUrl = prefs.getString('user_avatar_url');
    Uint8List? loadedBytes;
    if (savedAvatar != null && savedAvatar.isNotEmpty) {
      try {
        loadedBytes = base64Decode(savedAvatar);
      } catch (_) {}
    }

    setState(() {
      _userName = prefs.getString('user_name') ?? 'sarthak ghotekar';
      _userEmail = prefs.getString('user_email') ?? 'sarthak123@gmail.com';
      if (loadedBytes != null) {
        _avatarBytes = loadedBytes;
      }
      if (savedAvatarUrl != null && savedAvatarUrl.isNotEmpty) {
        _avatarUrl = savedAvatarUrl;
      }
    });

    try {
      final user = await _authRepo.getProfile();
      if (!mounted) return;
      setState(() {
        _user = user;
        _userName = user.name;
        _userEmail = user.email;
        if (user.avatarUrl.isNotEmpty) {
          _avatarUrl = user.avatarUrl;
        }
      });
      if (user.avatarUrl.isNotEmpty) {
        await prefs.setString('user_avatar_url', user.avatarUrl);
      }
    } catch (_) {}
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
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
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        leading: Icon(icon, color: iconColor ?? AppColors.primaryColor, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? AppColors.primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: AppColors.secondaryText, size: 16),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: TextStyle(color: AppColors.primaryText)),
        content: Text('Are you sure you want to logout?', style: TextStyle(color: AppColors.secondaryText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coralRed),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _authRepo.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Account', style: TextStyle(color: AppColors.coralRed, fontWeight: FontWeight.bold)),
        content: Text(
          'This will permanently delete your account and all your data. This action cannot be undone.',
          style: TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coralRed),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _authRepo.deleteAccount();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.coralRed,
        ),
      );
    }
  }

  void _openEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          user: _user,
          currentName: _userName,
          currentEmail: _userEmail,
          onUpdated: _loadProfile,
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
          AppLanguage.tr('Profile'),
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppColors.primaryText, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen(user: _user, onUpdated: _loadProfile)),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // User Card
              GestureDetector(
                onTap: _openEditProfile,
                child: Container(
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: AppColors.secondaryCardColor,
                        backgroundImage: _avatarBytes != null
                            ? MemoryImage(_avatarBytes!)
                            : ((_user?.avatarUrl != null && _user!.avatarUrl.isNotEmpty)
                                ? NetworkImage(_user!.avatarUrl) as ImageProvider
                                : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                                    ? NetworkImage(_avatarUrl!) as ImageProvider
                                    : null)),
                        child: _avatarBytes == null &&
                                (_user?.avatarUrl == null || _user!.avatarUrl.isEmpty) &&
                                (_avatarUrl == null || _avatarUrl!.isEmpty)
                            ? Icon(Icons.person, size: 38, color: AppColors.primaryColor)
                            : null,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName,
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _userEmail,
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: AppColors.secondaryText, size: 16),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Menu Items from Reference Screenshot
              _buildMenuItem(
                icon: Icons.edit_outlined,
                title: AppLanguage.tr('Edit Profile'),
                onTap: _openEditProfile,
              ),
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: AppLanguage.tr('Settings'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen(user: _user, onUpdated: _loadProfile)),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.shield_outlined,
                title: AppLanguage.tr('Privacy & Security'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PrivacySecurityScreen(user: _user, onUpdated: _loadProfile)),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.logout_rounded,
                title: AppLanguage.tr('Logout'),
                iconColor: AppColors.coralRed,
                textColor: AppColors.coralRed,
                onTap: _logout,
              ),
              _buildMenuItem(
                icon: Icons.delete_outline,
                title: AppLanguage.tr('Delete Account'),
                iconColor: AppColors.coralRed,
                textColor: AppColors.coralRed,
                onTap: _deleteAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
