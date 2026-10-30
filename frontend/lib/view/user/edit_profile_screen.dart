import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';import 'package:frontend/const/app_colors.dart';
import 'package:frontend/const/app_icons.dart';
import 'package:frontend/const/app_language.dart';
import 'package:frontend/model/user_model.dart';
import 'package:frontend/repo/auth_repo.dart';
import 'package:frontend/services/supabase_storage_service.dart';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';



class EditProfileScreen extends StatefulWidget {
  final UserModel? user;
  final String currentName;
  final String currentEmail;
  final VoidCallback onUpdated;

  EditProfileScreen({
    super.key,
    this.user,
    required this.currentName,
    required this.currentEmail,
    required this.onUpdated,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthRepo _authRepo = AuthRepo();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;

  String _linkedinUrl = 'https://www.linkedin.com/in/sarthak-ghotekar-137845389';
  String _githubUrl = 'https://github.com/SarthakGhotekar2007-dev';
  String _instagramUrl = 'https://www.instagram.com/mr_sarthak_4020_/';

  Uint8List? _avatarBytes;
  String? _avatarUrl;
  bool _isUploadingPhoto = false;
  bool _isLoading = false;
  int _bioLength = 0;

  @override
  void initState() {
    super.initState();
    _avatarUrl = widget.user?.avatarUrl;
    _loadLocalAvatar();
    _loadSocialUrls();
    _nameController = TextEditingController(text: widget.user?.name ?? widget.currentName);
    _emailController = TextEditingController(text: widget.user?.email ?? widget.currentEmail);
    _bioController = TextEditingController(text: widget.user?.bio ?? '');

    _bioLength = _bioController.text.length;
    _bioController.addListener(() {
      setState(() {
        _bioLength = _bioController.text.length;
      });
    });
  }

  Future<void> _loadSocialUrls() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLinkedin = prefs.getString('user_linkedin');
    final savedGithub = prefs.getString('user_github');
    final savedInsta = prefs.getString('user_instagram');

    final userLinkedin = widget.user?.linkedin;
    final userGithub = widget.user?.github;

    setState(() {
      _linkedinUrl = savedLinkedin ??
          (userLinkedin != null && userLinkedin.isNotEmpty
              ? userLinkedin
              : 'https://www.linkedin.com/in/sarthak-ghotekar-137845389');
      _githubUrl = savedGithub ??
          (userGithub != null && userGithub.isNotEmpty
              ? userGithub
              : 'https://github.com/SarthakGhotekar2007-dev');
      _instagramUrl = savedInsta ?? 'https://www.instagram.com/mr_sarthak_4020_/';
    });
  }

  Future<void> _loadLocalAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('user_avatar_url');
    final userUrl = widget.user?.avatarUrl;

    if (savedUrl != null && savedUrl.isNotEmpty) {
      _avatarUrl = savedUrl;
    } else if (userUrl != null && userUrl.isNotEmpty) {
      _avatarUrl = userUrl;
    }

    final savedBase64 = prefs.getString('user_avatar_base64');
    if (savedBase64 != null && savedBase64.isNotEmpty) {
      try {
        setState(() {
          _avatarBytes = base64Decode(savedBase64);
        });
      } catch (_) {}
    } else {
      setState(() {});
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final Uint8List bytes = await pickedFile.readAsBytes();
        setState(() {
          _avatarBytes = bytes;
          _isUploadingPhoto = true;
        });

        // Save base64 locally for instant offline display
        final prefs = await SharedPreferences.getInstance();
        final base64Image = base64Encode(bytes);
        await prefs.setString('user_avatar_base64', base64Image);

        widget.onUpdated();

        // Upload to Supabase Storage 'avatars' bucket
        try {
          final int userId = widget.user?.id ?? 0;
          final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
          final String fileName = userId > 0 ? 'user_${userId}_$timestamp.jpg' : 'avatar_$timestamp.jpg';

          final publicUrl = await SupabaseStorageService.uploadAvatar(
            bytes: bytes,
            fileName: fileName,
            mimeType: 'image/jpeg',
          );

          // Update backend profile database with Supabase URL
          await _authRepo.updateFullProfile(
            name: _nameController.text.trim(),
            bio: _bioController.text.trim(),
            avatarUrl: publicUrl,
            linkedin: _linkedinUrl,
            github: _githubUrl,
          );

          await prefs.setString('user_avatar_url', publicUrl);

          setState(() {
            _avatarUrl = publicUrl;
            _isUploadingPhoto = false;
          });

          widget.onUpdated();

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo uploaded and saved to Supabase Storage!'),
              backgroundColor: AppColors.successColor,
              duration: Duration(seconds: 3),
            ),
          );
        } catch (uploadError) {
          setState(() {
            _isUploadingPhoto = false;
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved locally. Supabase upload notice: $uploadError'),
              backgroundColor: AppColors.warningColor,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUploadingPhoto = false;
      });
      if (!mounted) return;
      final bool isMissingPlugin = e.toString().contains('MissingPluginException');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isMissingPlugin
                ? 'Camera/Gallery plugin needs app restart. Please restart flutter run in terminal.'
                : 'Could not access ${source == ImageSource.camera ? 'camera' : 'gallery'}. Please check permissions.',
          ),
          backgroundColor: AppColors.coralRed,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _showChangePhotoBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and close icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
         
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.primaryText, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Change Photo',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 48), // Balancing width for center alignment
                ],
              ),
              SizedBox(height: 20),

              // Large Center Avatar
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: AppColors.secondaryCardColor,
                    backgroundImage: _avatarBytes != null
                        ? MemoryImage(_avatarBytes!)
                        : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                            ? NetworkImage(_avatarUrl!) as ImageProvider
                            : null),
                    child: _isUploadingPhoto
                        ? CircularProgressIndicator(color: AppColors.coralRed, strokeWidth: 2)
                        : (_avatarBytes == null && (_avatarUrl == null || _avatarUrl!.isEmpty)
                            ? Icon(Icons.person, size: 60, color: AppColors.primaryColor)
                            : null),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 4,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.black, size: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Take Photo Option -> Opens Camera
              _buildPhotoOption(
                icon: Icons.camera_alt_outlined,
                title: AppLanguage.tr('Take Photo'),
                subtitle: 'Use your camera',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              SizedBox(height: 12),

              // Choose from Gallery Option -> Opens Gallery
              _buildPhotoOption(
                icon: Icons.image_outlined,
                title: AppLanguage.tr('Choose from Gallery'),
                subtitle: AppLanguage.tr('Select from your photos'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryText, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Future<void> _openSocialLink(String urlString) async {
    try {
      String formattedUrl = urlString.trim();
      if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
        formattedUrl = 'https://$formattedUrl';
      }
      final Uri uri = Uri.parse(formattedUrl);
      final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening: $urlString'),
          backgroundColor: AppColors.successColor,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Full name cannot be empty')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_instagram', _instagramUrl);
      await prefs.setString('user_github', _githubUrl);
      await prefs.setString('user_linkedin', _linkedinUrl);

      await _authRepo.updateFullProfile(
        name: name,
        bio: _bioController.text.trim(),
        avatarUrl: _avatarUrl,
        linkedin: _linkedinUrl,
        github: _githubUrl,
      );

      widget.onUpdated();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.successColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.coralRed,
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

  Widget _buildSocialIconCard({
    required String label,
    Widget? iconWidget,
    IconData? icon,
    LinearGradient? gradient,
    Color? bgColor,
    Color iconColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: gradient,
                color: gradient == null ? bgColor : null,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: iconWidget ??
                  (icon != null
                      ? Icon(icon, color: iconColor, size: 22)
                      : SizedBox.shrink()),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSocialDialog() {
    final instaCtl = TextEditingController(text: _instagramUrl);
    final githubCtl = TextEditingController(text: _githubUrl);
    final linkedinCtl = TextEditingController(text: _linkedinUrl);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Social Links',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.primaryText),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildDialogField(
                'Instagram Profile URL',
                instaCtl,
                iconWidget: AppIcons.instagram(size: 18, color: AppColors.secondaryText),
              ),
              SizedBox(height: 12),
              _buildDialogField(
                'GitHub Profile URL',
                githubCtl,
                iconWidget: AppIcons.github(size: 18, color: AppColors.secondaryText),
              ),
              SizedBox(height: 12),
              _buildDialogField(
                'LinkedIn Profile URL',
                linkedinCtl,
                iconWidget: AppIcons.linkedin(size: 18, color: AppColors.secondaryText),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coralRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    final newInsta = instaCtl.text.trim();
                    final newGithub = githubCtl.text.trim();
                    final newLinkedin = linkedinCtl.text.trim();
                    setState(() {
                      _instagramUrl = newInsta;
                      _githubUrl = newGithub;
                      _linkedinUrl = newLinkedin;
                    });
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setString('user_instagram', newInsta);
                      prefs.setString('user_github', newGithub);
                      prefs.setString('user_linkedin', newLinkedin);
                    });
                    Navigator.pop(sheetContext);
                  },
                  child: Text(
                    'Update Links',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    Widget? iconWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryCardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              iconWidget ??
                  (icon != null
                      ? Icon(icon, size: 18, color: AppColors.secondaryText)
                      : SizedBox.shrink()),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: TextStyle(color: AppColors.primaryText, fontSize: 13),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldCard({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    int? maxLength,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            maxLength: maxLength,
            readOnly: readOnly,
            style: TextStyle(color: AppColors.primaryText, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.secondaryText.withValues(alpha: 0.6), fontSize: 14),
              counterText: '',
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
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
          AppLanguage.tr('Edit Profile'),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with camera badge & Change Photo
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showChangePhotoBottomSheet,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 46,
                            backgroundColor: AppColors.secondaryCardColor,
                            backgroundImage: _avatarBytes != null
                                ? MemoryImage(_avatarBytes!)
                                : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                                    ? NetworkImage(_avatarUrl!) as ImageProvider
                                    : null),
                            child: _isUploadingPhoto
                                ? CircularProgressIndicator(color: AppColors.coralRed, strokeWidth: 2)
                                : (_avatarBytes == null && (_avatarUrl == null || _avatarUrl!.isEmpty)
                                    ? Icon(Icons.person, size: 50, color: AppColors.primaryColor)
                                    : null),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 4,
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.camera_alt, color: Colors.black, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: _showChangePhotoBottomSheet,
                      child: Text(
                        AppLanguage.tr('Change Photo'),
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28),

              // Full Name Field
              _buildTextFieldCard(
                label: AppLanguage.tr('Full Name'),
                controller: _nameController,
                hint: 'Enter your full name',
              ),
              SizedBox(height: 18),

              // Email Address Field
              _buildTextFieldCard(
                label: AppLanguage.tr('Email Address'),
                controller: _emailController,
                hint: 'Enter your email',
                readOnly: true,
              ),
              SizedBox(height: 18),

              // Bio Field with 0/150 counter
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLanguage.tr('Bio'),
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$_bioLength/150',
                        style: TextStyle(
                          color: AppColors.secondaryText.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: TextField(
                      controller: _bioController,
                      maxLines: 3,
                      maxLength: 150,
                      style: TextStyle(color: AppColors.primaryText, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Tell something about yourself...',
                        hintStyle: TextStyle(color: AppColors.secondaryText.withValues(alpha: 0.6), fontSize: 14),
                        counterText: '',
                        contentPadding: EdgeInsets.all(14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Social Links (Clickable Icons)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLanguage.tr('Social Profiles'),
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showEditSocialDialog,
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 14, color: AppColors.coralRed),
                        SizedBox(width: 4),
                        Text(
                          AppLanguage.tr('Edit Links'),
                          style: TextStyle(
                            color: AppColors.coralRed,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildSocialIconCard(
                      label: 'Instagram',
                      iconWidget: AppIcons.instagram(size: 22, color: Colors.white),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF833AB4),
                          Color(0xFFFD1D1D),
                          Color(0xFFFCB045),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => _openSocialLink(_instagramUrl),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildSocialIconCard(
                      label: 'GitHub',
                      iconWidget: AppIcons.github(size: 22, color: Colors.white),
                      bgColor: Color(0xFF24292E),
                      onTap: () => _openSocialLink(_githubUrl),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildSocialIconCard(
                      label: 'LinkedIn',
                      iconWidget: AppIcons.linkedin(size: 22, color: Colors.white),
                      bgColor: Color(0xFF0A66C2),
                      onTap: () => _openSocialLink(_linkedinUrl),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Save Changes Button (Coral Red)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coralRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isLoading ? null : _saveChanges,
                  child: _isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          AppLanguage.tr('Save Changes'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
