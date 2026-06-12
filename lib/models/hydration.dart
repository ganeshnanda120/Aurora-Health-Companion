class HydrationLog {
  final String id;
  final int amountMl;
  final DateTime timestamp;

  HydrationLog({
    required this.id,
    required this.amountMl,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amountMl': amountMl,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HydrationLog.fromJson(Map<String, dynamic> json) {
    return HydrationLog(
      id: json['id'] ?? '',
      amountMl: json['amountMl'] ?? 0,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
