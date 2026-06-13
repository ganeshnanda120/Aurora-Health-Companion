import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../../providers/health_provider.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  
  String _selectedMealType = 'Breakfast';
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _showAddMealDialog() {
    // Populate default placeholders for demonstration speed in hackathons
    _foodNameController.text = 'Healthy Salad Bowl';
    _caloriesController.text = '380';
    _proteinController.text = '18';
    _carbsController.text = '25';
    _fatController.text = '12';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuroraTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Log Meal / Snack",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AuroraTheme.textSecondary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 16),
                    
                    // Meal Type Row
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _mealTypes.map((type) {
                        final isSel = _selectedMealType == type;
                        return ChoiceChip(
                          label: Text(type, style: TextStyle(fontSize: 12, color: isSel ? AuroraTheme.darkBg : AuroraTheme.textPrimary)),
                          selected: isSel,
                          selectedColor: AuroraTheme.accentNutrition,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() {
                                _selectedMealType = type;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _foodNameController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: "Food Name or Description",
                        prefixIcon: Icon(Icons.restaurant_menu_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _caloriesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Calories (kcal)",
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _proteinController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Protein (g)",
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _carbsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Carbs (g)",
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _fatController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Fat (g)",
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: () {
                        final foodName = _foodNameController.text.trim();
                        final calories = int.tryParse(_caloriesController.text) ?? 0;
                        final protein = int.tryParse(_proteinController.text) ?? 0;
                        final carbs = int.tryParse(_carbsController.text) ?? 0;
                        final fat = int.tryParse(_fatController.text) ?? 0;
                        
                        if (foodName.isNotEmpty) {
                          Provider.of<HealthProvider>(context, listen: false).addNutrition(
                            _selectedMealType,
                            foodName,
                            calories,
                            protein,
                            carbs,
                            fat,
                          );
                          _foodNameController.clear();
                          _caloriesController.clear();
                          _proteinController.clear();
                          _carbsController.clear();
                          _fatController.clear();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Meal logged successfully! 🍎"),
                              backgroundColor: AuroraTheme.accentNutrition,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuroraTheme.accentNutrition,
                        foregroundColor: AuroraTheme.darkBg,
                      ),
                      child: const Text("Log Food"),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);
    final logs = provider.nutritionLogs;
    final today = DateTime.now();

    final todayLogs = logs.where((e) =>
        e.timestamp.year == today.year &&
        e.timestamp.month == today.month &&
        e.timestamp.day == today.day
    ).toList();

    final totalCalories = todayLogs.fold(0, (sum, item) => sum + item.calories);
    final totalProtein = todayLogs.fold(0, (sum, item) => sum + item.protein);
    final totalCarbs = todayLogs.fold(0, (sum, item) => sum + item.carbs);
    final totalFat = todayLogs.fold(0, (sum, item) => sum + item.fat);
    
    final int calGoal = 2000;

    // Macro Chart Data
    final totalMacros = totalProtein + totalCarbs + totalFat;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nutrition Awareness"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.auroraGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mindful awareness slogan
                Card(
                  color: AuroraTheme.accentNutrition.withOpacity(0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: AuroraTheme.accentNutrition.withOpacity(0.2)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Aurora focuses on dietary awareness and mindful consumption rather than calorie restriction. Feed your body what it needs.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AuroraTheme.textSecondary, fontSize: 13, height: 1.4, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Calories Card
                Card(
                  color: AuroraTheme.cardBg.withOpacity(0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text("TODAY'S CALORIC SUMMARY", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AuroraTheme.textSecondary, letterSpacing: 1.5)),
                        const SizedBox(height: 8),
                        Text("$totalCalories / $calGoal kcal", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (totalCalories / calGoal).clamp(0.0, 1.0),
                            color: AuroraTheme.accentNutrition,
                            backgroundColor: Colors.white.withOpacity(0.05),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Macro Chart Row
                Row(
                  children: [
                    // Pie chart widget
                    Expanded(
                      flex: 4,
                      child: Card(
                        color: AuroraTheme.cardBg.withOpacity(0.4),
                        child: Container(
                          height: 180,
                          padding: const EdgeInsets.all(16),
                          child: totalMacros == 0
                              ? const Center(child: Text("No macro data\nlogged today", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AuroraTheme.textMuted)))
                              : PieChart(
                                  PieChartData(
                                    sectionsSpace: 4,
                                    centerSpaceRadius: 30,
                                    sections: [
                                      PieChartSectionData(
                                        color: Colors.redAccent,
                                        value: totalProtein.toDouble(),
                                        title: 'P',
                                        radius: 35,
                                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      PieChartSectionData(
                                        color: Colors.blueAccent,
                                        value: totalCarbs.toDouble(),
                                        title: 'C',
                                        radius: 35,
                                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      PieChartSectionData(
                                        color: Colors.amber,
                                        value: totalFat.toDouble(),
                                        title: 'F',
                                        radius: 35,
                                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Legends
                    Expanded(
                      flex: 5,
                      child: Card(
                        color: AuroraTheme.cardBg.withOpacity(0.4),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMacroLabel("Protein", "$totalProtein g", Colors.redAccent),
                              const SizedBox(height: 8),
                              _buildMacroLabel("Carbs", "$totalCarbs g", Colors.blueAccent),
                              const SizedBox(height: 8),
                              _buildMacroLabel("Fats", "$totalFat g", Colors.amber),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Log food button
                ElevatedButton.icon(
                  onPressed: _showAddMealDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuroraTheme.accentNutrition,
                    foregroundColor: AuroraTheme.darkBg,
                    padding: const EdgeInsets.all(18),
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text("Log Meal or Snack"),
                ),
                const SizedBox(height: 24),

                // History List
                Card(
                  color: AuroraTheme.cardBg.withOpacity(0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Today's Logged Meals",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        if (todayLogs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(
                              "No meals logged yet. Eat mindfully and hydrate.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AuroraTheme.textMuted),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: todayLogs.length,
                            itemBuilder: (context, index) {
                              final meal = todayLogs[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AuroraTheme.accentNutrition.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.restaurant_rounded, color: AuroraTheme.accentNutrition, size: 16),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(meal.foodName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${meal.mealType} • P:${meal.protein}g C:${meal.carbs}g F:${meal.fat}g",
                                            style: TextStyle(color: AuroraTheme.textSecondary, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text("${meal.calories} kcal", style: const TextStyle(fontWeight: FontWeight.bold)),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                          onPressed: () {
                                            provider.deleteNutrition(meal.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMacroLabel(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, style: const TextStyle(color: AuroraTheme.textSecondary, fontSize: 11)),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AuroraTheme.textPrimary)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
