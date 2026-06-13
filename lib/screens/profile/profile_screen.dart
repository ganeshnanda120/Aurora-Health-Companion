import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/name_formatter.dart';
import '../../models/user_profile.dart';
import '../../providers/health_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../auth/landing_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Settings values (loaded from provider state in build)
  bool _isMetric = true;
  bool _deviceSync = false;

  void _showEditProfileDialog(UserProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final ageController = TextEditingController(text: profile.age.toString());
    final heightController = TextEditingController(text: profile.height.toString());
    final weightController = TextEditingController(text: profile.weight.toString());
    String editAvatar = profile.profilePic;
    String? editGender = profile.gender.isNotEmpty ? profile.gender : 'Other';
    String editActivityLevel = profile.activityLevel.isNotEmpty ? profile.activityLevel : 'Moderate';

    TimeOfDay parseTime(String timeStr) {
      try {
        final parts = timeStr.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (e) {
        return const TimeOfDay(hour: 7, minute: 0);
      }
    }

    TimeOfDay editWakeTime = parseTime(profile.wakeUpTime);
    TimeOfDay editBedTime = parseTime(profile.bedTime);

    final List<String> editGoals = List<String>.from(profile.healthGoals);
    final List<String> allGoals = [
      'Improve Hydration',
      'Sleep Better',
      'Build Better Habits',
      'Eat Healthier',
      'Improve Energy Levels',
      'Improve Consistency',
    ];

    String formatTimeOfDay(TimeOfDay time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return "$hour:$minute";
    }

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
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
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
                          "Edit Profile Info",
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
                    
                    // Avatar selector in edit dialog
                    const Text("Select Avatar", style: TextStyle(fontWeight: FontWeight.bold, color: AuroraTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.spaceEvenly,
                      children: AvatarWidget.avatarMap.keys.map((avatarId) {
                        final isSel = editAvatar == avatarId;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              editAvatar = avatarId;
                            });
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AvatarWidget(
                                avatarId: avatarId,
                                radius: 24,
                              ),
                              if (isSel)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: AuroraTheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check, color: AuroraTheme.darkBg, size: 10),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () async {
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
                              setDialogState(() {
                                editAvatar = base64String;
                              });
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error picking image: $e"),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.photo_library_rounded),
                        label: const Text("Upload Custom Photo"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AuroraTheme.primary,
                          side: const BorderSide(color: AuroraTheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (!editAvatar.startsWith('avatar')) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Custom Photo Selected", style: TextStyle(color: AuroraTheme.textSecondary, fontSize: 12)),
                            const SizedBox(width: 8),
                            AvatarWidget(
                              avatarId: editAvatar,
                              radius: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.none,
                      inputFormatters: [SpecialNameFormatter()],
                      decoration: const InputDecoration(
                        labelText: "Display Name",
                        helperText: "Aurora will capitalize the first letter of each name part: E.g. Ganesh Prasad",
                        helperStyle: TextStyle(color: AuroraTheme.primary, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Age"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: editGender,
                            dropdownColor: AuroraTheme.cardBg,
                            decoration: const InputDecoration(
                              labelText: "Gender",
                            ),
                            style: const TextStyle(color: AuroraTheme.textPrimary, fontSize: 16),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setDialogState(() {
                                  editGender = newValue;
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
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: heightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Height (cm)"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Weight (kg)"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: editActivityLevel,
                      dropdownColor: AuroraTheme.cardBg,
                      decoration: const InputDecoration(
                        labelText: "Activity Level",
                        prefixIcon: Icon(Icons.directions_run_rounded, color: AuroraTheme.primary, size: 20),
                      ),
                      style: const TextStyle(color: AuroraTheme.textPrimary, fontSize: 16),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setDialogState(() {
                            editActivityLevel = newValue;
                          });
                        }
                      },
                      items: <String>['Low', 'Moderate', 'High']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text("$value Activity"),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    const Text("Schedules", style: TextStyle(fontWeight: FontWeight.bold, color: AuroraTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: editWakeTime,
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
                                setDialogState(() {
                                  editWakeTime = picked;
                                });
                              }
                            },
                            icon: const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 16),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text("Wake: ${editWakeTime.format(context)}"),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AuroraTheme.textPrimary,
                              side: BorderSide(color: Colors.white.withOpacity(0.1)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: editBedTime,
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
                                setDialogState(() {
                                  editBedTime = picked;
                                });
                              }
                            },
                            icon: const Icon(Icons.bedtime_rounded, color: AuroraTheme.secondaryLight, size: 16),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text("Bed: ${editBedTime.format(context)}"),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AuroraTheme.textPrimary,
                              side: BorderSide(color: Colors.white.withOpacity(0.1)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text("Health Goals", style: TextStyle(fontWeight: FontWeight.bold, color: AuroraTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allGoals.map((goal) {
                        final isSel = editGoals.contains(goal);
                        return FilterChip(
                          label: Text(goal, style: const TextStyle(fontSize: 11)),
                          selected: isSel,
                          selectedColor: AuroraTheme.primary.withOpacity(0.2),
                          checkmarkColor: AuroraTheme.primary,
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSel ? AuroraTheme.primary : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                editGoals.add(goal);
                              } else {
                                editGoals.remove(goal);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: () {
                        final provider = Provider.of<HealthProvider>(context, listen: false);
                        final updated = profile.copyWith(
                          name: SpecialNameFormatter.formatName(nameController.text),
                          age: int.tryParse(ageController.text) ?? profile.age,
                          gender: editGender,
                          height: double.tryParse(heightController.text) ?? profile.height,
                          weight: double.tryParse(weightController.text) ?? profile.weight,
                          wakeUpTime: formatTimeOfDay(editWakeTime),
                          bedTime: formatTimeOfDay(editBedTime),
                          activityLevel: editActivityLevel,
                          healthGoals: editGoals,
                          profilePic: editAvatar,
                        );
                        provider.updateProfile(updated);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Profile updated! ✨"),
                            backgroundColor: AuroraTheme.primary,
                          ),
                        );
                      },
                      child: const Text("Save Changes"),
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

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuroraTheme.cardBg,
        title: const Text("Logout"),
        content: const Text("Are you sure you want to end your demo session?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: AuroraTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = Provider.of<HealthProvider>(context, listen: false);
              await provider.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LandingScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _handleResetData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuroraTheme.cardBg,
        title: const Text("Reset Storage"),
        content: const Text("This clears all local logs, credentials, habits, and profile configurations. This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: AuroraTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = Provider.of<HealthProvider>(context, listen: false);
              await provider.resetAllData();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LandingScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("Clear All Data", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);
    final profile = provider.profile;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Settings"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.auroraGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              // User profile header summary card
              Card(
                color: AuroraTheme.cardBg.withOpacity(0.4),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      AvatarWidget(
                        avatarId: profile.profilePic,
                        radius: 32,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary)),
                            const SizedBox(height: 4),
                            Text(
                              "Age: ${profile.age} • ${profile.gender} • ${profile.weight}kg",
                              style: TextStyle(color: AuroraTheme.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_note_rounded, color: AuroraTheme.primary, size: 28),
                        onPressed: () => _showEditProfileDialog(profile),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Lifestyle Information
              _buildSectionTitle("Lifestyle Info"),
              Card(
                color: AuroraTheme.cardBg.withOpacity(0.4),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      "Wake Up Bedtime Schedule",
                      "Wake Up: ${profile.wakeUpTime} • Bedtime: ${profile.bedTime}",
                      Icons.alarm_rounded,
                      AuroraTheme.accentSleep,
                    ),
                    _buildSettingsTile(
                      "Activity Baseline",
                      "${profile.activityLevel} Activity Level",
                      Icons.directions_run_rounded,
                      AuroraTheme.accentHydration,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Health Goals display
              _buildSectionTitle("Health Goals"),
              Card(
                color: AuroraTheme.cardBg.withOpacity(0.4),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.healthGoals.map((goal) {
                      return Chip(
                        label: Text(goal, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        backgroundColor: AuroraTheme.primary.withOpacity(0.1),
                        side: BorderSide(color: AuroraTheme.primary.withOpacity(0.2)),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Notifications preferences
              _buildSectionTitle("Notification Settings"),
              Card(
                color: AuroraTheme.cardBg.withOpacity(0.4),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      "Hydration Alerts",
                      profile.notificationPreferences['Hydration'] ?? true,
                      Icons.local_drink_rounded,
                      (val) {
                        final notif = Map<String, bool>.from(profile.notificationPreferences);
                        notif['Hydration'] = val;
                        provider.updateProfile(profile.copyWith(notificationPreferences: notif));
                      },
                    ),
                    _buildSwitchTile(
                      "Sleep Routine Nudges",
                      profile.notificationPreferences['Sleep'] ?? true,
                      Icons.nights_stay_rounded,
                      (val) {
                        final notif = Map<String, bool>.from(profile.notificationPreferences);
                        notif['Sleep'] = val;
                        provider.updateProfile(profile.copyWith(notificationPreferences: notif));
                      },
                    ),
                    _buildSwitchTile(
                      "Habit Streak Alerts",
                      profile.notificationPreferences['Habits'] ?? true,
                      Icons.task_alt_rounded,
                      (val) {
                        final notif = Map<String, bool>.from(profile.notificationPreferences);
                        notif['Habits'] = val;
                        provider.updateProfile(profile.copyWith(notificationPreferences: notif));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Measurement preferences
              _buildSectionTitle("Preferences & Connectivity"),
              Card(
                color: AuroraTheme.cardBg.withOpacity(0.4),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      "Use Metric Units",
                      _isMetric,
                      Icons.straighten_rounded,
                      (val) => setState(() => _isMetric = val),
                    ),
                    _buildSwitchTile(
                      "Smartwatch Integration",
                      _deviceSync,
                      Icons.watch_rounded,
                      (val) {
                        setState(() => _deviceSync = val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(val ? "Simulated Smartwatch Sync enabled! ⌚" : "Smartwatch Sync disabled"),
                            backgroundColor: AuroraTheme.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Danger Zone actions
              Card(
                color: Colors.redAccent.withOpacity(0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.redAccent.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      title: const Text("Log Out Session", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.redAccent),
                      onTap: _handleLogout,
                    ),
                    Divider(color: Colors.white.withOpacity(0.15), height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                      title: const Text("Reset Local Storage", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.redAccent),
                      onTap: _handleResetData,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: AuroraTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(String title, String subtitle, IconData icon, Color iconColor) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: AuroraTheme.textSecondary, fontSize: 12)),
    );
  }

  Widget _buildSwitchTile(String title, bool value, IconData icon, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AuroraTheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AuroraTheme.primary, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary, fontSize: 14)),
      value: value,
      activeColor: AuroraTheme.primary,
      onChanged: onChanged,
    );
  }
}
