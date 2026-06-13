import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/health_provider.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final _habitTitleController = TextEditingController();
  String _selectedCategory = 'Mindfulness';

  final List<String> _categories = ['Mindfulness', 'Physical', 'Learning', 'Routine'];

  final List<SuggestedHabit> _suggestions = [
    SuggestedHabit(title: 'Meditation', category: 'Mindfulness', icon: Icons.spa_rounded),
    SuggestedHabit(title: 'Stretching', category: 'Physical', icon: Icons.accessibility_new_rounded),
    SuggestedHabit(title: 'Morning Walk', category: 'Physical', icon: Icons.directions_walk_rounded),
    SuggestedHabit(title: 'Journaling', category: 'Mindfulness', icon: Icons.edit_note_rounded),
    SuggestedHabit(title: 'Read 10 Pages', category: 'Learning', icon: Icons.menu_book_rounded),
    SuggestedHabit(title: 'Take Supplements', category: 'Routine', icon: Icons.medication_rounded),
    SuggestedHabit(title: 'Early Bedtime', category: 'Routine', icon: Icons.bedtime_rounded),
  ];

  @override
  void dispose() {
    _habitTitleController.dispose();
    super.dispose();
  }

  void _addHabit(String title, String category) {
    if (title.trim().isEmpty) return;
    Provider.of<HealthProvider>(context, listen: false).addCustomHabit(title.trim(), category);
    _habitTitleController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Habit '$title' created! 🚀"),
        backgroundColor: AuroraTheme.accentHabits,
      ),
    );
  }

  void _showAddHabitDialog() {
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
                          "Create New Habit",
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
                    
                    TextField(
                      controller: _habitTitleController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: "Habit Name (e.g. Drink hot tea)",
                        prefixIcon: Icon(Icons.star_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSel = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat, style: TextStyle(fontSize: 12, color: isSel ? AuroraTheme.darkBg : AuroraTheme.textPrimary)),
                          selected: isSel,
                          selectedColor: AuroraTheme.accentHabits,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() {
                                _selectedCategory = cat;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: () {
                        _addHabit(_habitTitleController.text, _selectedCategory);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuroraTheme.accentHabits,
                        foregroundColor: AuroraTheme.darkBg,
                      ),
                      child: const Text("Create Habit"),
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
    final habits = provider.habits;

    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    // Filter habit insights
    final allInsights = provider.getMemoryInsights();
    final habitInsights = allInsights.where((ins) => ins.toLowerCase().contains("habit") || ins.toLowerCase().contains("consistency")).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Habit Tracker"),
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
                // Quick suggestions carousel
                const Text(
                  "Suggested Routines",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 96,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final sug = _suggestions[index];
                      return Card(
                        color: AuroraTheme.cardBg.withOpacity(0.4),
                        margin: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () => _addHabit(sug.title, sug.category),
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(sug.icon, color: AuroraTheme.accentHabits, size: 20),
                                const SizedBox(height: 6),
                                Text(sug.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(sug.category, style: TextStyle(color: AuroraTheme.textMuted, fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Habit Insights Card
                if (habitInsights.isNotEmpty) ...[
                  Card(
                    color: AuroraTheme.cardBg.withOpacity(0.4),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: AuroraTheme.accentHabits, size: 20),
                              SizedBox(width: 8),
                              Text("Habit Insights", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: habitInsights.map((insight) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("• ", style: TextStyle(color: AuroraTheme.accentHabits, fontSize: 16, fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: Text(
                                        insight,
                                        style: const TextStyle(color: AuroraTheme.textPrimary, height: 1.4, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Habit List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Your Routines (${habits.length})",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, color: AuroraTheme.accentHabits, size: 28),
                      onPressed: _showAddHabitDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Active habits checklist
                if (habits.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Text(
                      "No habits logged. Nurturing habits is the core of longevity.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AuroraTheme.textMuted),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      final state = habit.history[todayStr] ?? 'due';

                      return Card(
                        color: AuroraTheme.cardBg.withOpacity(0.4),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // State Checkbox
                              _buildHabitActionButton(
                                state: state,
                                onCompleted: () => provider.toggleHabitStatus(habit.id, todayStr, 'completed'),
                                onSkipped: () => provider.toggleHabitStatus(habit.id, todayStr, 'skipped'),
                                onPaused: () => provider.toggleHabitStatus(habit.id, todayStr, 'paused'),
                              ),
                              const SizedBox(width: 16),
                              // Habit Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      habit.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: state == 'completed'
                                            ? AuroraTheme.textMuted
                                            : AuroraTheme.textPrimary,
                                        decoration: state == 'completed'
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getCategoryColor(habit.category).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            habit.category,
                                            style: TextStyle(
                                              color: _getCategoryColor(habit.category),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (habit.streakCount > 0) ...[
                                          const Icon(Icons.local_fire_department_rounded, color: AuroraTheme.accentStreak, size: 14),
                                          Text(
                                            "${habit.streakCount}d streak",
                                            style: const TextStyle(color: AuroraTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Delete Button
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                onPressed: () {
                                  provider.deleteHabit(habit.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitActionButton({
    required String state,
    required VoidCallback onCompleted,
    required VoidCallback onSkipped,
    required VoidCallback onPaused,
  }) {
    IconData icon;
    Color color;

    switch (state) {
      case 'completed':
        icon = Icons.check_circle_rounded;
        color = AuroraTheme.accentHabits;
        break;
      case 'skipped':
        icon = Icons.next_plan_outlined;
        color = Colors.amber;
        break;
      case 'paused':
        icon = Icons.pause_circle_filled_rounded;
        color = Colors.lightBlueAccent;
        break;
      default:
        icon = Icons.radio_button_off_rounded;
        color = AuroraTheme.textSecondary;
        break;
    }

    return PopupMenuButton<String>(
      icon: Icon(icon, color: color, size: 28),
      color: AuroraTheme.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (val) {
        if (val == 'completed') onCompleted();
        if (val == 'skipped') onSkipped();
        if (val == 'paused') onPaused();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'completed',
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AuroraTheme.accentHabits),
              SizedBox(width: 8),
              Text("Complete"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'skipped',
          child: Row(
            children: [
              Icon(Icons.next_plan_outlined, color: Colors.amber),
              SizedBox(width: 8),
              Text("Skip"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'paused',
          child: Row(
            children: [
              Icon(Icons.pause_circle_filled_rounded, color: Colors.lightBlueAccent),
              SizedBox(width: 8),
              Text("Pause"),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mindfulness':
        return AuroraTheme.accentSleep;
      case 'Physical':
        return AuroraTheme.accentHydration;
      case 'Learning':
        return AuroraTheme.accentNutrition;
      default:
        return AuroraTheme.accentHabits;
    }
  }
}

class SuggestedHabit {
  final String title;
  final String category;
  final IconData icon;

  SuggestedHabit({
    required this.title,
    required this.category,
    required this.icon,
  });
}
