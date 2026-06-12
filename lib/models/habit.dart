class Habit {
  final String id;
  final String title;
  final String category; // e.g. "Mindfulness", "Physical", "Learning", "Routine"
  final DateTime createdAt;
  final Map<String, String> history; // date string (YYYY-MM-DD) -> state ("completed", "skipped", "paused")
  final bool isActive;
  final int streakCount;

  Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
    required this.history,
    this.isActive = true,
    this.streakCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'history': history,
      'isActive': isActive,
      'streakCount': streakCount,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'General',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      history: Map<String, String>.from(json['history'] ?? {}),
      isActive: json['isActive'] ?? true,
      streakCount: json['streakCount'] ?? 0,
    );
  }

  Habit copyWith({
    String? title,
    String? category,
    Map<String, String>? history,
    bool? isActive,
    int? streakCount,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      createdAt: createdAt,
      history: history ?? this.history,
      isActive: isActive ?? this.isActive,
      streakCount: streakCount ?? this.streakCount,
    );
  }
}
