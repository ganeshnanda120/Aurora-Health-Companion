class UserProfile {
  final String name;
  final int age;
  final String gender;
  final double height; // in cm
  final double weight; // in kg
  final String wakeUpTime; // e.g., "07:00"
  final String bedTime; // e.g., "22:30"
  final String activityLevel; // "Low", "Moderate", "High"
  final List<String> healthGoals;
  final Map<String, bool> notificationPreferences;
  final String profilePic; // Stores avatar identifier, e.g. 'avatar1', 'avatar2'

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.wakeUpTime,
    required this.bedTime,
    required this.activityLevel,
    required this.healthGoals,
    required this.notificationPreferences,
    this.profilePic = 'avatar1',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'wakeUpTime': wakeUpTime,
      'bedTime': bedTime,
      'activityLevel': activityLevel,
      'healthGoals': healthGoals,
      'notificationPreferences': notificationPreferences,
      'profilePic': profilePic,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      wakeUpTime: json['wakeUpTime'] ?? '07:00',
      bedTime: json['bedTime'] ?? '23:00',
      activityLevel: json['activityLevel'] ?? 'Moderate',
      healthGoals: List<String>.from(json['healthGoals'] ?? []),
      notificationPreferences: Map<String, bool>.from(json['notificationPreferences'] ?? {}),
      profilePic: json['profilePic'] ?? 'avatar1',
    );
  }

  UserProfile copyWith({
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? wakeUpTime,
    String? bedTime,
    String? activityLevel,
    List<String>? healthGoals,
    Map<String, bool>? notificationPreferences,
    String? profilePic,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      bedTime: bedTime ?? this.bedTime,
      activityLevel: activityLevel ?? this.activityLevel,
      healthGoals: healthGoals ?? this.healthGoals,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      profilePic: profilePic ?? this.profilePic,
    );
  }
}
