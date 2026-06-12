import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/name_formatter.dart';
import '../../models/user_profile.dart';
import '../../providers/health_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Profile Pic
  String _selectedAvatar = 'avatar1';

  // Form Controllers
  final _formKey1 = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _gender;
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  Future<void> _pickCustomImage() async {
    Navigator.pop(context); // Close bottom sheet
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        setState(() {
          _selectedAvatar = base64String;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error picking image: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showAvatarPickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuroraTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
            left: 24.0,
            right: 24.0,
            top: 24.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Choose Your Companion Avatar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: AvatarWidget.avatarMap.length,
                  itemBuilder: (context, index) {
                    final avatarId = 'avatar${index + 1}';
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = avatarId;
                        });
                        Navigator.pop(context);
                      },
                      child: AvatarWidget(
                        avatarId: avatarId,
                        radius: 30,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "OR",
                  style: TextStyle(color: AuroraTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickCustomImage,
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text("Upload Custom Photo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuroraTheme.primary.withOpacity(0.15),
                    foregroundColor: AuroraTheme.primary,
                    side: const BorderSide(color: AuroraTheme.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // Step 2 variables
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 30);
  TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 30);
  String _activityLevel = 'Moderate';

  // Step 3 variables
  final List<String> _allGoals = [
    'Improve Hydration',
    'Sleep Better',
    'Build Better Habits',
    'Eat Healthier',
    'Improve Energy Levels',
    'Improve Consistency',
  ];
  final List<String> _selectedGoals = [];

  // Step 4 variables
  bool _notifHydration = true;
  bool _notifSleep = true;
  bool _notifHabit = true;
  bool _notifInsights = true;

  @override
  void initState() {
    super.initState();
    final userEmail = Provider.of<HealthProvider>(context, listen: false).userEmail;
    if (userEmail != null && userEmail.contains("demo")) {
      _nameController.text = "Demo User";
      _ageController.text = "28";
      _gender = 'Female';
      _heightController.text = "168";
      _weightController.text = "62";
      _selectedGoals.addAll(['Improve Hydration', 'Sleep Better', 'Build Better Habits']);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey1.currentState!.validate()) return;
    }

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    final provider = Provider.of<HealthProvider>(context, listen: false);

    final profile = UserProfile(
      name: SpecialNameFormatter.formatName(_nameController.text),
      age: int.tryParse(_ageController.text) ?? 25,
      gender: _gender ?? 'Female',
      height: double.tryParse(_heightController.text) ?? 170.0,
      weight: double.tryParse(_weightController.text) ?? 65.0,
      wakeUpTime: _formatTime(_wakeTime),
      bedTime: _formatTime(_bedTime),
      activityLevel: _activityLevel,
      healthGoals: _selectedGoals,
      notificationPreferences: {
        'Hydration': _notifHydration,
        'Sleep': _notifSleep,
        'Habits': _notifHabit,
        'Insights': _notifInsights,
      },
      profilePic: _selectedAvatar,
    );

    await provider.completeOnboarding(profile);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainShell()),
        (route) => false,
      );
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  Future<void> _selectTime(BuildContext context, bool isWakeTime) async {
    final initialTime = isWakeTime ? _wakeTime : _bedTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AuroraTheme.primary,
              onPrimary: AuroraTheme.darkBg,
              surface: AuroraTheme.cardBg,
              onSurface: AuroraTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isWakeTime) {
          _wakeTime = picked;
        } else {
          _bedTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AuroraTheme.auroraGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Progress Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Text(
                      "Step ${_currentStep + 1} of $_totalSteps",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AuroraTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (_currentStep + 1) / _totalSteps,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          color: AuroraTheme.primary,
                          minHeight: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Body PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildStep1Personal(),
                    _buildStep2Lifestyle(),
                    _buildStep3Goals(),
                    _buildStep4Notifications(),
                  ],
                ),
              ),
              // Navigation Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      OutlinedButton(
                        onPressed: _prevStep,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AuroraTheme.textPrimary,
                          side: BorderSide(color: Colors.white.withOpacity(0.2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        child: const Text("Back"),
                      )
                    else
                      const SizedBox.shrink(),
                    ElevatedButton(
                      onPressed: _nextStep,
                      child: Text(_currentStep == _totalSteps - 1 ? "Finish" : "Next"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Step 1: Personal Info
  Widget _buildStep1Personal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tell us about yourself",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              "This data helps us calculate your daily water requirements and sleep cycles.",
              style: TextStyle(color: AuroraTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            
            // Avatar picker
            Center(
              child: Stack(
                children: [
                  AvatarWidget(
                    avatarId: _selectedAvatar,
                    radius: 44,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showAvatarPickerSheet,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AuroraTheme.primary,
                        child: const Icon(Icons.camera_alt_rounded, color: AuroraTheme.darkBg, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.none,
              inputFormatters: [SpecialNameFormatter()],
              decoration: const InputDecoration(
                labelText: "What should we call you?",
                prefixIcon: Icon(Icons.person_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return "Please enter your name";
                return null;
              },
            ),
            const SizedBox(height: 6),
            const Text(
              "Aurora will capitalize the first letter of each part of your name (First, Middle, Last)! E.g. Ganesh Prasad",
              style: TextStyle(color: AuroraTheme.primary, fontSize: 11, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Age",
                      prefixIcon: Icon(Icons.cake_rounded),
                    ),
                    validator: (value) {
                      if (value == null || int.tryParse(value) == null) return "Enter age";
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    dropdownColor: AuroraTheme.cardBg,
                    decoration: const InputDecoration(
                      labelText: "Gender",
                      prefixIcon: Icon(Icons.wc_rounded),
                    ),
                    style: const TextStyle(color: AuroraTheme.textPrimary, fontSize: 16),
                    hint: const Text("Select Gender"),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _gender = newValue;
                        });
                      }
                    },
                    items: <String>['Male', 'Female', 'Other']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Select gender";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Height (cm)",
                      prefixIcon: Icon(Icons.height_rounded),
                    ),
                    validator: (value) {
                      if (value == null || double.tryParse(value) == null) return "Enter height";
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Weight (kg)",
                      prefixIcon: Icon(Icons.scale_rounded),
                    ),
                    validator: (value) {
                      if (value == null || double.tryParse(value) == null) return "Enter weight";
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: Lifestyle Info
  Widget _buildStep2Lifestyle() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lifestyle & Habits",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Establish your primary schedule for reminders.",
            style: TextStyle(color: AuroraTheme.textSecondary),
          ),
          const SizedBox(height: 32),
          
          // Times loggers
          Row(
            children: [
              Expanded(
                child: Card(
                  color: AuroraTheme.cardBg.withOpacity(0.5),
                  child: InkWell(
                    onTap: () => _selectTime(context, true),
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 28),
                          const SizedBox(height: 12),
                          const Text("Wake Up", style: TextStyle(color: AuroraTheme.textSecondary)),
                          const SizedBox(height: 8),
                          Text(
                            _wakeTime.format(context),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  color: AuroraTheme.cardBg.withOpacity(0.5),
                  child: InkWell(
                    onTap: () => _selectTime(context, false),
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Icon(Icons.bedtime_rounded, color: AuroraTheme.secondaryLight, size: 28),
                          const SizedBox(height: 12),
                          const Text("Bedtime", style: TextStyle(color: AuroraTheme.textSecondary)),
                          const SizedBox(height: 8),
                          Text(
                            _bedTime.format(context),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          const Text(
            "Activity Level",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          Column(
            children: ['Low', 'Moderate', 'High'].map((level) {
              final isSel = _activityLevel == level;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSel ? AuroraTheme.primary.withOpacity(0.15) : AuroraTheme.cardBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSel ? AuroraTheme.primary : Colors.white.withOpacity(0.05),
                    width: 1.5,
                  ),
                ),
                child: RadioListTile<String>(
                  title: Text(
                    "$level Activity",
                    style: TextStyle(
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel ? AuroraTheme.textPrimary : AuroraTheme.textSecondary,
                    ),
                  ),
                  subtitle: Text(
                    level == 'Low' 
                        ? 'Mostly sitting (desk work, minimal exercises)'
                        : level == 'Moderate'
                            ? 'Moving throughout the day, light workouts'
                            : 'Intense workouts, active physical jobs',
                    style: TextStyle(color: isSel ? AuroraTheme.textSecondary : AuroraTheme.textMuted),
                  ),
                  value: level,
                  groupValue: _activityLevel,
                  activeColor: AuroraTheme.primary,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _activityLevel = val;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Step 3: Health Goals
  Widget _buildStep3Goals() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Health Goals",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Choose all goals that align with your wellness aspirations.",
            style: TextStyle(color: AuroraTheme.textSecondary),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _allGoals.map((goal) {
              final isSel = _selectedGoals.contains(goal);
              return FilterChip(
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Text(
                    goal,
                    style: TextStyle(
                      color: isSel ? AuroraTheme.darkBg : AuroraTheme.textPrimary,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                selected: isSel,
                selectedColor: AuroraTheme.primary,
                backgroundColor: AuroraTheme.cardBg.withOpacity(0.5),
                checkmarkColor: AuroraTheme.darkBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSel ? AuroraTheme.primary : Colors.white.withOpacity(0.1),
                  ),
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedGoals.add(goal);
                    } else {
                      _selectedGoals.remove(goal);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Step 4: Notification Preferences
  Widget _buildStep4Notifications() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Stay Motivated",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Choose when you'd like Aurora to gently nudge you.",
            style: TextStyle(color: AuroraTheme.textSecondary),
          ),
          const SizedBox(height: 32),
          
          _buildNotificationToggle(
            title: "Hydration Reminders",
            subtitle: "Hourly notifications to hit your daily water limit.",
            value: _notifHydration,
            icon: Icons.local_drink_rounded,
            color: AuroraTheme.accentHydration,
            onChanged: (val) => setState(() => _notifHydration = val),
          ),
          const SizedBox(height: 16),
          _buildNotificationToggle(
            title: "Sleep Reminders",
            subtitle: "Nudges when it is time to wind down for bed.",
            value: _notifSleep,
            icon: Icons.nights_stay_rounded,
            color: AuroraTheme.accentSleep,
            onChanged: (val) => setState(() => _notifSleep = val),
          ),
          const SizedBox(height: 16),
          _buildNotificationToggle(
            title: "Habit Reminders",
            subtitle: "Checklists for morning/evening streaks.",
            value: _notifHabit,
            icon: Icons.task_alt_rounded,
            color: AuroraTheme.accentHabits,
            onChanged: (val) => setState(() => _notifHabit = val),
          ),
          const SizedBox(height: 16),
          _buildNotificationToggle(
            title: "Daily Health Insights",
            subtitle: "Summaries of your biological rhythms every morning.",
            value: _notifInsights,
            icon: Icons.insights_rounded,
            color: AuroraTheme.accentNutrition,
            onChanged: (val) => setState(() => _notifInsights = val),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AuroraTheme.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: SwitchListTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 44.0, top: 4.0),
          child: Text(subtitle, style: const TextStyle(color: AuroraTheme.textSecondary, fontSize: 13)),
        ),
        value: value,
        activeColor: AuroraTheme.primary,
        onChanged: onChanged,
      ),
    );
  }
}
