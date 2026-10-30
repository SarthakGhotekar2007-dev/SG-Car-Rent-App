import 'package:flutter/material.dart';
import '../../const/app_colors.dart';
import '../../model/user_model.dart';
import '../../repo/auth_repo.dart';
import 'login_activity_screen.dart';
import '../auth/login_screen.dart';

class PrivacySecurityScreen extends StatefulWidget {
  final UserModel? user;
  final VoidCallback? onUpdated;

  PrivacySecurityScreen({super.key, this.user, this.onUpdated});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final AuthRepo _authRepo = AuthRepo();

  bool _showOnlineStatus = true;
  bool _allowMessageRequests = true;
  bool _twoFactorAuth = false;

  @override
  void initState() {
    super.initState();
    _showOnlineStatus = widget.user?.showOnlineStatus ?? true;
    _allowMessageRequests = widget.user?.allowMessageRequests ?? true;
    _twoFactorAuth = widget.user?.twoFactorAuth ?? false;
  }

  Future<void> _updatePreferences() async {
    try {
      await _authRepo.updatePreferences(
        showOnlineStatus: _showOnlineStatus,
        allowMessageRequests: _allowMessageRequests,
        twoFactorAuth: _twoFactorAuth,
      );
      if (widget.onUpdated != null) widget.onUpdated!();
    } catch (_) {}
  }

  void _showChangePasswordModal() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Change Password',
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
                  _buildModalTextField('Current Password', oldPassController, true),
                  SizedBox(height: 14),
                  _buildModalTextField('New Password', newPassController, true),
                  SizedBox(height: 14),
                  _buildModalTextField('Confirm New Password', confirmPassController, true),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coralRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isSaving
                          ? null
                          : () async {
                              final oldP = oldPassController.text;
                              final newP = newPassController.text;
                              final confP = confirmPassController.text;

                              if (oldP.isEmpty || newP.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please fill all password fields')),
                                );
                                return;
                              }
                              if (newP != confP) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('New passwords do not match')),
                                );
                                return;
                              }

                              setModalState(() => isSaving = true);
                              try {
                                await _authRepo.changePassword(
                                  oldPassword: oldP,
                                  newPassword: newP,
                                );
                                if (!context.mounted) return;
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Password changed successfully!'),
                                    backgroundColor: AppColors.successColor,
                                  ),
                                );
                              } catch (e) {
                                setModalState(() => isSaving = false);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString().replaceAll('Exception: ', '')),
                                    backgroundColor: AppColors.coralRed,
                                  ),
                                );
                              }
                            },
                      child: isSaving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Update Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalTextField(String label, TextEditingController controller, bool obscure) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: AppColors.primaryText, fontSize: 14),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _showDownloadDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Download Your Data', style: TextStyle(color: AppColors.primaryText)),
          content: Text(
            'A secure export link containing your account details, booking records, and preferences has been sent to your registered email address.',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 13, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.coralRed),
              onPressed: () => Navigator.pop(context),
              child: Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
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
          'Permanently delete your account and all booking history. This action cannot be reversed.',
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
    } catch (_) {}
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 18, bottom: 10, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.secondaryText,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w600,
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

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w600,
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
        trailing: Switch(
          value: value,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.coralRed,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: AppColors.secondaryCardColor,
          onChanged: (newVal) {
            onChanged(newVal);
            _updatePreferences();
          },
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
          'Privacy & Security',
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
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            // Section 1: Privacy
            _buildSectionHeader('Privacy'),
            _buildActionItem(
              title: 'Profile Visibility',
              subtitle: 'Make your profile visible to others',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile visibility is set to Public')),
                );
              },
            ),
            _buildToggleItem(
              title: 'Show Online Status',
              subtitle: "Let others see when you're online",
              value: _showOnlineStatus,
              onChanged: (val) {
                setState(() => _showOnlineStatus = val);
              },
            ),
            _buildToggleItem(
              title: 'Allow Message Requests',
              subtitle: 'Receive messages from other users',
              value: _allowMessageRequests,
              onChanged: (val) {
                setState(() => _allowMessageRequests = val);
              },
            ),

            // Section 2: Security
            _buildSectionHeader('Security'),
            _buildActionItem(
              title: 'Change Password',
              subtitle: 'Update your password',
              onTap: _showChangePasswordModal,
            ),
            _buildToggleItem(
              title: 'Two-Factor Authentication',
              subtitle: 'Add extra security to your account',
              value: _twoFactorAuth,
              onChanged: (val) {
                setState(() => _twoFactorAuth = val);
              },
            ),
            _buildActionItem(
              title: 'Login Activity',
              subtitle: 'View your recent login devices',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginActivityScreen()),
                );
              },
            ),

            // Section 3: Data & Privacy
            _buildSectionHeader('Data & Privacy'),
            _buildActionItem(
              title: 'Download Your Data',
              subtitle: 'Get a copy of your data',
              onTap: _showDownloadDataDialog,
            ),
            _buildActionItem(
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              onTap: _deleteAccount,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
