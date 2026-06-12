class SleepLog {
  final String id;
  final DateTime date;
  final double durationHours;
  final int qualityScore; // 1 to 100
  final String notes;

  SleepLog({
    required this.id,
    required this.date,
    required this.durationHours,
    required this.qualityScore,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'durationHours': durationHours,
      'qualityScore': qualityScore,
      'notes': notes,
    };
  }

  factory SleepLog.fromJson(Map<String, dynamic> json) {
    return SleepLog(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      durationHours: (json['durationHours'] as num?)?.toDouble() ?? 0.0,
      qualityScore: json['qualityScore'] ?? 50,
      notes: json['notes'] ?? '',
    );
  }
}
