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
  
  // Champs Onboarding
  final String? onboardingName; // Le nom choisi au début du questionnaire
  final int? age;
  final String? gender;
  final String? ethnicity;
  final String? skinSensitivity;
  final String? tirednessLevel;
  final String? stressLevel;
  final String? sunExposure;
  final String? routinePreference;
  final String? ingredientsToAvoid;
  final String? effortLevel;
  final String? desiredBenefits;

  // Settings - Email
  final bool emailWeeklyDigest;
  final bool emailAnalysisResults;
  final bool emailSkincareTips;
  final bool emailProductReviews;
  final bool emailAccountUpdates;
  final bool emailSecurityAlerts;
  final bool emailPromotions;
  final String digestDay;
  final String digestTime;

  // Settings - Notifications
  final bool notifAnalysisReminders;
  final bool notifWeeklyReports;
  final bool notifNewRecommendations;
  final bool notifRoutineReminders;
  final bool notifProgressUpdates;
  final bool notifProductAlerts;
  final bool notifPromotionsPush;
  final String reminderFrequency;

  final String? deletionRequestedAt;

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
    this.onboardingName,
    this.age,
    this.gender,
    this.ethnicity,
    this.skinSensitivity,
    this.tirednessLevel,
    this.stressLevel,
    this.sunExposure,
    this.routinePreference,
    this.ingredientsToAvoid,
    this.effortLevel,
    this.desiredBenefits,
    this.emailWeeklyDigest = true,
    this.emailAnalysisResults = true,
    this.emailSkincareTips = true,
    this.emailProductReviews = false,
    this.emailAccountUpdates = true,
    this.emailSecurityAlerts = true,
    this.emailPromotions = false,
    this.digestDay = 'Monday',
    this.digestTime = 'Morning',
    this.notifAnalysisReminders = true,
    this.notifWeeklyReports = true,
    this.notifNewRecommendations = true,
    this.notifRoutineReminders = false,
    this.notifProgressUpdates = true,
    this.notifProductAlerts = false,
    this.notifPromotionsPush = false,
    this.reminderFrequency = 'weekly',
    this.deletionRequestedAt,
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
    onboardingName: json['onboardingName'] ?? json['name'],
    age: json['age'] is int ? json['age'] : int.tryParse(json['age']?.toString() ?? ''),
    gender: json['gender'],
    ethnicity: json['ethnicity'],
    skinSensitivity: json['skinSensitivity'],
    tirednessLevel: json['tirednessLevel'],
    stressLevel: json['stressLevel'],
    sunExposure: json['sunExposure'],
    routinePreference: json['routinePreference'],
    ingredientsToAvoid: json['ingredientsToAvoid'],
    effortLevel: json['effortLevel'],
    desiredBenefits: json['desiredBenefits'],
    emailWeeklyDigest: json['emailWeeklyDigest'] ?? true,
    emailAnalysisResults: json['emailAnalysisResults'] ?? true,
    emailSkincareTips: json['emailSkincareTips'] ?? true,
    emailProductReviews: json['emailProductReviews'] ?? false,
    emailAccountUpdates: json['emailAccountUpdates'] ?? true,
    emailSecurityAlerts: json['emailSecurityAlerts'] ?? true,
    emailPromotions: json['emailPromotions'] ?? false,
    digestDay: json['digestDay'] ?? 'Monday',
    digestTime: json['digestTime'] ?? 'Morning',
    notifAnalysisReminders: json['notifAnalysisReminders'] ?? true,
    notifWeeklyReports: json['notifWeeklyReports'] ?? true,
    notifNewRecommendations: json['notifNewRecommendations'] ?? true,
    notifRoutineReminders: json['notifRoutineReminders'] ?? false,
    notifProgressUpdates: json['notifProgressUpdates'] ?? true,
    notifProductAlerts: json['notifProductAlerts'] ?? false,
    notifPromotionsPush: json['notifPromotionsPush'] ?? false,
    reminderFrequency: json['reminderFrequency'] ?? 'weekly',
    deletionRequestedAt: json['deletionRequestedAt'],
  );

  String get fullName => '$firstName $lastName';
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final UserModel user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return AuthResponse(
      accessToken: data['accessToken'] ?? '',
      refreshToken: data['refreshToken'] ?? '',
      tokenType: data['tokenType'] ?? 'Bearer',
      user: UserModel.fromJson(data['user'] ?? {}),
    );
  }
}
