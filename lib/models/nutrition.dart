class NutritionLog {
  final String id;
  final String mealType; // "Breakfast", "Lunch", "Dinner", "Snack"
  final String foodName;
  final int calories;
  final int protein; // in grams
  final int carbs; // in grams
  final int fat; // in grams
  final DateTime timestamp;

  NutritionLog({
    required this.id,
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealType': mealType,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory NutritionLog.fromJson(Map<String, dynamic> json) {
    return NutritionLog(
      id: json['id'] ?? '',
      mealType: json['mealType'] ?? 'Snack',
      foodName: json['foodName'] ?? '',
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fat: json['fat'] ?? 0,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
