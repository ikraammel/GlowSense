class UserModel {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? skinType;
  final String? skinConcerns;
  final bool onboardingCompleted;
  final bool notificationsEnabled;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.skinType,
    this.skinConcerns,
    this.onboardingCompleted = false,
    this.notificationsEnabled = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    firstName: json['firstName'] ?? '',
    lastName: json['lastName'] ?? '',
    email: json['email'] ?? '',
    phoneNumber: json['phoneNumber'],
    profileImageUrl: json['profileImageUrl'],
    skinType: json['skinType'],
    skinConcerns: json['skinConcerns'],
    onboardingCompleted: json['onboardingCompleted'] ?? false,
    notificationsEnabled: json['notificationsEnabled'] ?? true,
  );

  String get fullName => '$firstName $lastName';
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthResponse({required this.accessToken, required this.refreshToken, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    accessToken: json['accessToken'] ?? '',
    refreshToken: json['refreshToken'] ?? '',
    user: UserModel.fromJson(json['user'] ?? {}),
  );
}
