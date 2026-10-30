class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String bio;
  final String avatarUrl;
  final String linkedin;
  final String github;
  final String language;
  final String themeMode;
  final bool profileVisibility;
  final bool showOnlineStatus;
  final bool allowMessageRequests;
  final bool twoFactorAuth;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.bio = '',
    this.avatarUrl = '',
    this.linkedin = '',
    this.github = '',
    this.language = 'English',
    this.themeMode = 'dark',
    this.profileVisibility = true,
    this.showOnlineStatus = true,
    this.allowMessageRequests = true,
    this.twoFactorAuth = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      phone: json['phone'] as String?,
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      linkedin: json['linkedin'] as String? ?? '',
      github: json['github'] as String? ?? '',
      language: json['language'] as String? ?? 'English',
      themeMode: json['theme_mode'] as String? ?? 'dark',
      profileVisibility: json['profile_visibility'] as bool? ?? true,
      showOnlineStatus: json['show_online_status'] as bool? ?? true,
      allowMessageRequests: json['allow_message_requests'] as bool? ?? true,
      twoFactorAuth: json['two_factor_auth'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'bio': bio,
      'avatar_url': avatarUrl,
      'linkedin': linkedin,
      'github': github,
      'language': language,
      'theme_mode': themeMode,
      'profile_visibility': profileVisibility,
      'show_online_status': showOnlineStatus,
      'allow_message_requests': allowMessageRequests,
      'two_factor_auth': twoFactorAuth,
    };
  }

  bool get isAdmin => role == 'admin';
}
