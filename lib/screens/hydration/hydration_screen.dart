import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/health_provider.dart';

class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});

  @override
  State<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  final _customAmountController = TextEditingController();
  final int _waterGoal = 2000;

  @override
  void initState() {
    super.initState();
    // Wave animation running continuously
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  void _addWater(int amount) {
    Provider.of<HealthProvider>(context, listen: false).addHydration(amount);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Added ${amount}ml of water! 💧"),
        backgroundColor: AuroraTheme.primary,
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  void _logCustomAmount() {
    final text = _customAmountController.text;
    final amount = int.tryParse(text);
    if (amount != null && amount > 0) {
      _addWater(amount);
      _customAmountController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid amount"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);
    final logs = provider.hydrationLogs;
    final today = DateTime.now();

    final todayLogs = logs
        .where((e) => e.timestamp.year == today.year && e.timestamp.month == today.month && e.timestamp.day == today.day)
        .toList();
    final todayWater = todayLogs.fold(0, (sum, item) => sum + item.amountMl);
    final fillPercentage = (todayWater / _waterGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hydration"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.auroraGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Animated Virtual Bottle Panel
                Card(
                  color: AuroraTheme.cardBg.withOpacity(0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Text(
                          "DAILY WATER PROGRESS",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: AuroraTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$todayWater / ${_waterGoal}ml",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AuroraTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Water Bottle Render
                        AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(140, 240),
                              painter: WaterBottlePainter(
                                fillLevel: fillPercentage,
                                wavePhase: _waveController.value * 2 * pi,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          fillPercentage >= 1.0
                              ? "Goal Achieved! You are fully hydrated! 🎉"
                              : "${((1.0 - fillPercentage) * _waterGoal).round()}ml left to reach goal",
                          style: TextStyle(
                            color: fillPercentage >= 1.0 ? AuroraTheme.primary : AuroraTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Quick add options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [250, 500, 750].map((amount) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          onPressed: () => _addWater(amount),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AuroraTheme.accentHydration.withOpacity(0.15),
                            foregroundColor: AuroraTheme.accentHydration,
                            side: const BorderSide(color: AuroraTheme.accentHydration, width: 1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.local_drink_rounded, size: 20),
                              const SizedBox(height: 4),
                              Text("+$amount ml", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Custom Log Entry
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Enter custom amount (ml)",
                          prefixIcon: Icon(Icons.edit_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _logCustomAmount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuroraTheme.primary,
                        foregroundColor: AuroraTheme.darkBg,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Hydration History Logs
                Card(
                  color: AuroraTheme.cardBg.withOpacity(0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Today's History",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary),
                            ),
                            if (todayLogs.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  provider.clearHydration();
                                },
                                child: const Text("Clear Logs", style: TextStyle(color: Colors.redAccent)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (todayLogs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(
                              "No water logged yet today. Hydration fuels cell function!",
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
                              final log = todayLogs[index];
                              final time = "${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}";
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.local_drink_rounded, color: AuroraTheme.accentHydration, size: 18),
                                        const SizedBox(width: 8),
                                        Text("${log.amountMl} ml", style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Text(time, style: TextStyle(color: AuroraTheme.textMuted)),
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
}

// Custom Painter for animated water bottle
class WaterBottlePainter extends CustomPainter {
  final double fillLevel; // 0.0 to 1.0
  final double wavePhase;

  WaterBottlePainter({required this.fillLevel, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    final paintBottle = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final paintBottleBg = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Define bottle path shape (capsule-like bottle body with a smaller cap neck)
    final bottlePath = Path();
    final double r = 24.0; // corner radius
    final double neckWidth = 40.0;
    final double neckHeight = 20.0;

    final double xStart = (size.width - neckWidth) / 2;
    
    bottlePath.moveTo(xStart, neckHeight);
    bottlePath.lineTo(xStart + neckWidth, neckHeight);
    // Shoulder transition
    bottlePath.lineTo(size.width - 8, neckHeight + 16);
    // Body right
    bottlePath.lineTo(size.width - 8, size.height - r);
    // Bottom right corner
    bottlePath.arcToPoint(
      Offset(size.width - 8 - r, size.height),
      radius: Radius.circular(r),
      clockwise: true,
    );
    // Bottom left
    bottlePath.lineTo(8 + r, size.height);
    // Bottom left corner
    bottlePath.arcToPoint(
      Offset(8, size.height - r),
      radius: Radius.circular(r),
      clockwise: true,
    );
    // Body left
    bottlePath.lineTo(8, neckHeight + 16);
    bottlePath.close();

    // Cap neck path
    final capPath = Path();
    capPath.moveTo(xStart + 4, neckHeight);
    capPath.lineTo(xStart + 4, 6);
    capPath.lineTo(xStart + neckWidth - 4, 6);
    capPath.lineTo(xStart + neckWidth - 4, neckHeight);
    capPath.close();

    // Fill background inside bottle
    canvas.drawPath(bottlePath, paintBottleBg);
    canvas.drawPath(capPath, paintBottleBg);

    // Draw Cap outline
    final capPaint = Paint()
      ..color = AuroraTheme.primary.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawPath(capPath, capPaint);
    canvas.drawPath(capPath, paintBottle);

    // Clip the canvas to bottle path, so the water stays inside the bottle!
    canvas.save();
    canvas.clipPath(bottlePath);

    // If there is water, draw waves
    if (fillLevel > 0) {
      final double fillHeight = size.height - (fillLevel * (size.height - neckHeight - 20));

      final paintWater = Paint()
        ..shader = AuroraTheme.hydrationGradient.createShader(
          Rect.fromLTWH(0, fillHeight, size.width, size.height - fillHeight),
        )
        ..style = PaintingStyle.fill;

      // Double sine wave math
      final wavePath = Path();
      wavePath.moveTo(0, size.height);
      wavePath.lineTo(0, fillHeight);

      // Draw sine wave line
      for (double x = 0; x <= size.width; x++) {
        final double y = fillHeight +
            8 * sin(wavePhase + (x / 20)) +
            3 * cos(wavePhase * 2 + (x / 10)); // compound wave equations
        wavePath.lineTo(x, y);
      }
      wavePath.lineTo(size.width, size.height);
      wavePath.close();

      canvas.drawPath(wavePath, paintWater);

      // Foam accent (secondary semi-transparent wave slightly offset)
      final paintFoam = Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.fill;

      final foamPath = Path();
      foamPath.moveTo(0, size.height);
      foamPath.lineTo(0, fillHeight);
      for (double x = 0; x <= size.width; x++) {
        final double y = fillHeight +
            6 * sin(wavePhase + pi + (x / 15)) +
            2 * cos(wavePhase * 1.5 + (x / 8));
        foamPath.lineTo(x, y);
      }
      foamPath.lineTo(size.width, size.height);
      foamPath.close();

      canvas.drawPath(foamPath, paintFoam);
    }

    canvas.restore();

    // Draw main bottle container outline
    canvas.drawPath(bottlePath, paintBottle);
  }

  @override
  bool shouldRepaint(covariant WaterBottlePainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel || oldDelegate.wavePhase != wavePhase;
  }
}
