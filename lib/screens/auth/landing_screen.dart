import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'auth_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: "Meet Aurora",
      description: "Meet your personal health companion.",
      icon: Icons.spa_rounded,
      color: AuroraTheme.primary,
    ),
    OnboardingSlide(
      title: "Holistic Tracking",
      description: "Track hydration, sleep, habits, and nutrition.",
      icon: Icons.track_changes_rounded,
      color: AuroraTheme.secondaryLight,
    ),
    OnboardingSlide(
      title: "Personalized Insights",
      description: "Receive personalized daily insights.",
      icon: Icons.psychology_rounded,
      color: AuroraTheme.accentSleep,
    ),
    OnboardingSlide(
      title: "Healthy Habits",
      description: "Build healthier routines through consistency.",
      icon: Icons.loop_rounded,
      color: AuroraTheme.accentHabits,
    ),
    OnboardingSlide(
      title: "Understand Yourself",
      description: "Learn more about yourself every day.",
      icon: Icons.insights_rounded,
      color: AuroraTheme.accentHydration,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.auroraGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Logo Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AuroraTheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.blur_on_rounded,
                      color: AuroraTheme.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "AURORA",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: AuroraTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Slogan
              const Text(
                "Understand yourself better every day.",
                style: TextStyle(
                  color: AuroraTheme.textSecondary,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.5,
                ),
              ),
              // Slide PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Graphic placeholder with glowing orb
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: slide.color.withOpacity(0.25),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: AuroraTheme.cardBg.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: slide.color.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  slide.icon,
                                  size: 64,
                                  color: slide.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),
                          Text(
                            slide.title,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            slide.description,
                            style: const TextStyle(
                              color: AuroraTheme.textSecondary,
                              fontSize: 16,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AuroraTheme.primary
                          : AuroraTheme.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // CTA Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthScreen(isLoginMode: false),
                          ),
                        );
                      },
                      child: const Text("Get Started"),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthScreen(isLoginMode: true),
                          ),
                        );
                      },
                      child: const Text(
                        "I already have an account",
                        style: TextStyle(
                          color: AuroraTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
