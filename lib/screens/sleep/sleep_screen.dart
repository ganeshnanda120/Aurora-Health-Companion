import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/health_provider.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  double _logDuration = 8.0;
  int _logQuality = 80;
  final _notesController = TextEditingController();

  void _showLogSleepDialog() {
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
                          "Log Night Sleep",
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
                    
                    // Duration Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Sleep Duration", style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          "${_logDuration.toStringAsFixed(1)} hours",
                          style: const TextStyle(color: AuroraTheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    Slider(
                      value: _logDuration,
                      min: 3.0,
                      max: 12.0,
                      divisions: 18,
                      activeColor: AuroraTheme.accentSleep,
                      inactiveColor: Colors.white10,
                      onChanged: (val) {
                        setDialogState(() {
                          _logDuration = val;
                        });
                        setState(() {
                          _logDuration = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Quality Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Sleep Quality", style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          "$_logQuality / 100",
                          style: const TextStyle(color: AuroraTheme.accentSleep, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    Slider(
                      value: _logQuality.toDouble(),
                      min: 20.0,
                      max: 100.0,
                      divisions: 8,
                      activeColor: AuroraTheme.accentSleep,
                      inactiveColor: Colors.white10,
                      onChanged: (val) {
                        setDialogState(() {
                          _logQuality = val.round();
                        });
                        setState(() {
                          _logQuality = val.round();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: "Notes (e.g. Dreams, woke up early)",
                        prefixIcon: Icon(Icons.note_alt_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<HealthProvider>(context, listen: false).logSleep(
                          _logDuration,
                          _logQuality,
                          notes: _notesController.text.trim(),
                        );
                        _notesController.clear();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Sleep log recorded! 🛌"),
                            backgroundColor: AuroraTheme.accentSleep,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuroraTheme.accentSleep,
                        foregroundColor: AuroraTheme.darkBg,
                      ),
                      child: const Text("Save Log"),
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
    final logs = provider.sleepLogs;

    // Get weekly logs (last 7 logs)
    final weeklyLogs = logs.length > 7 ? logs.sublist(logs.length - 7) : logs;
    
    // Calculations
    final avgSleep = logs.isEmpty
        ? 0.0
        : logs.fold(0.0, (sum, item) => sum + item.durationHours) / logs.length;
    final avgQuality = logs.isEmpty
        ? 0.0
        : logs.fold(0.0, (sum, item) => sum + item.qualityScore) / logs.length;

    // Sleep Insights specifically
    final allInsights = provider.getMemoryInsights();
    final sleepInsights = allInsights.where((ins) => ins.toLowerCase().contains("sleep") || ins.toLowerCase().contains("rest")).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sleep Analysis"),
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
                // Top stats row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        "Average Duration",
                        "${avgSleep.toStringAsFixed(1)} hrs",
                        Icons.access_time_rounded,
                        AuroraTheme.accentSleep,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        "Average Quality",
                        "${avgQuality.round()}%",
                        Icons.star_rounded,
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Weekly Chart Card
                Card(
                  color: AuroraTheme.cardBg.withOpacity(0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Weekly Sleep Duration Trends",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 200,
                          child: weeklyLogs.isEmpty
                              ? const Center(child: Text("No sleep logs recorded yet"))
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: 12,
                                    barTouchData: BarTouchData(enabled: true),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (double value, TitleMeta meta) {
                                            int idx = value.toInt();
                                            if (idx >= 0 && idx < weeklyLogs.length) {
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 6.0),
                                                child: Text(
                                                  DateFormat('E').format(weeklyLogs[idx].date),
                                                  style: const TextStyle(color: AuroraTheme.textSecondary, fontSize: 11),
                                                ),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 3,
                                          getTitlesWidget: (double value, TitleMeta meta) {
                                            return Text(
                                              "${value.toInt()}h",
                                              style: const TextStyle(color: AuroraTheme.textMuted, fontSize: 10),
                                            );
                                          },
                                        ),
                                      ),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (value) => FlLine(
                                        color: Colors.white.withOpacity(0.05),
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups: List.generate(weeklyLogs.length, (index) {
                                      final log = weeklyLogs[index];
                                      return BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY: log.durationHours,
                                            gradient: const LinearGradient(
                                              colors: [AuroraTheme.accentSleep, AuroraTheme.secondaryLight],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                            width: 14,
                                            borderRadius: BorderRadius.circular(4),
                                            backDrawRodData: BackgroundBarChartRodData(
                                              show: true,
                                              toY: 12,
                                              color: Colors.white.withOpacity(0.03),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sleep Insights Card
                if (sleepInsights.isNotEmpty) ...[
                  Card(
                    color: AuroraTheme.cardBg.withOpacity(0.4),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: AuroraTheme.accentSleep, size: 20),
                              SizedBox(width: 8),
                              Text("Sleep Insights", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: sleepInsights.map((insight) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("• ", style: TextStyle(color: AuroraTheme.accentSleep, fontSize: 16, fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 20),
                ],

                // Action log sleep
                ElevatedButton.icon(
                  onPressed: _showLogSleepDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuroraTheme.accentSleep,
                    foregroundColor: AuroraTheme.darkBg,
                    padding: const EdgeInsets.all(18),
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text("Log Last Night's Sleep"),
                ),
                const SizedBox(height: 24),

                // Sleep history logs list
                Card(
                  color: AuroraTheme.cardBg.withOpacity(0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Sleep History",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        if (logs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(
                              "No logs. Sleep consistency prevents chronic fatigue.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AuroraTheme.textMuted),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: logs.length > 5 ? 5 : logs.length, // Show up to last 5
                            itemBuilder: (context, index) {
                              // Show in reverse order (newest first)
                              final log = logs[logs.length - 1 - index];
                              final dateText = DateFormat('EEEE, MMM d').format(log.date);
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(dateText, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        if (log.notes.isNotEmpty)
                                          Text(
                                            log.notes,
                                            style: TextStyle(color: AuroraTheme.textMuted, fontSize: 12, fontStyle: FontStyle.italic),
                                          ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("${log.durationHours} hours", style: const TextStyle(color: AuroraTheme.accentSleep, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text("Quality: ${log.qualityScore}%", style: const TextStyle(color: Colors.amber, fontSize: 12)),
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      color: AuroraTheme.cardBg.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AuroraTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
