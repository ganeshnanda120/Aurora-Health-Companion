# Aurora Health Companion

Aurora is a premium, AI-powered health and wellness companion mobile application built using Flutter and Dart. Designed with a calming dark theme and Material 3 guidelines, it functions as a holistic wellness coach that helps users log hydration, monitor sleep patterns, track habits, log nutrition, and interact with an intelligent voice coach.

---

## 🌟 Key Features

* **Calm & Premium Aesthetics**: Deep dark-slate backgrounds combined with glowing Aurora Borealis gradients and custom micro-animations create a serene, non-clinical user experience.
* **Daily Insight Hub**: Real-time contextual banner that alerts users to hydration shortages, sleep variance, and outstanding goals based on their weekly logs.
* **Animated Virtual Water Bottle**: Renders fluid liquid inside a bottle container using compound sine-wave equations. The liquid dynamically rises and falls based on water goals.
* **Interactive Sleep Analytics**: Visualizes sleep durations and quality logs using custom bar graphs powered by `fl_chart`. It alerts users when they stray from their sleep averages.
* **Flexible Habit Checklist**: Multi-state checks (Complete, Skip, Pause) with active consecutive streak tracking and category tags.
* **Mindful Nutrition Log**: Macronutrients ratio analysis (Protein, Carbs, Fats) represented as a donut chart, focusing on food awareness instead of diet restrictions.
* **Aurora AI Voice Companion**: Real-time simulated voice-to-voice health partner. Parses phrases like *"I drank 500ml water"* or *"I slept 8 hours"* and logs it directly into the application database, providing audible feedback.
* **Offline-first Architecture**: Persists all sessions, profile configurations, conversation logs, and telemetry using SharedPreferences.

---

## 👥 Demo Credentials

The prototype implements a simulated authentication layer. To access the onboarding and dashboard quickly, use the pre-filled credentials:

* **Email**: `demo@aurora.com`
* **Password**: `123456`

*(Alternatively, you can create a custom demo account or log in via simulated Google / Apple OAuth tabs.)*

---

## 🛠️ Technology Stack

* **Frontend Framework**: Flutter (Latest Stable)
* **Programming Language**: Dart
* **Design System**: Material 3
* **State Management**: Provider
* **Local Storage**: SharedPreferences
* **Data Visualizations**: fl_chart
* **Voice Capabilities**: speech_to_text, flutter_tts

---

## 📂 Project Structure

```text
lib/
├── core/
│   └── theme.dart          # Colors, typography, gradients, theme data
├── models/
│   ├── ai_message.dart     # AI dialogue transcript schema
│   ├── habit.dart          # Habits history status schema
│   ├── hydration.dart      # Single water intake schema
│   ├── nutrition.dart      # Calories and macro meal log schema
│   ├── sleep.dart          # Duration and quality rating schema
│   └── user_profile.dart   # Profile metrics and notification triggers
├── providers/
│   └── health_provider.dart# State controller linking storage, AI, and modules
├── screens/
│   ├── ai_companion/
│   │   └── ai_companion_screen.dart # Voice waveform orb and chat interface
│   ├── auth/
│   │   ├── auth_screen.dart         # Email login/signup forms
│   │   └── landing_screen.dart      # 5-page onboarding slides carousel
│   ├── dashboard/
│   │   └── home_screen.dart         # Stats summary hub and active streaks
│   ├── habits/
│   │   └── habits_screen.dart       # Habits checker and custom adding sheet
│   ├── hydration/
│   │   └── hydration_screen.dart    # Custom animated water bottle screen
│   ├── nutrition/
│   │   └── nutrition_screen.dart    # Meal macros charts and food input sheets
│   ├── onboarding/
│   │   └── onboarding_screen.dart   # Personal goals and preferences wizard
│   ├── profile/
│   │   └── profile_screen.dart      # Units, synchronization, and storage settings
│   └── main_shell.dart     # M3 NavigationBar coordinator
├── services/
│   ├── ai_service.dart     # Local NLP parser and speech synthesizer
│   └── storage_service.dart# SharedPreferences JSON serializer
└── main.dart               # Startup binding, provider hook, and initial route
```

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK Installed (>= 3.11.4)
* Dart SDK (>= 3.11.0)
* Android Studio / Xcode (for mobile emulators)

### Installation

1. Clone or copy the project files to your environment.
2. Open terminal in the project directory.
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```

### Running the App

To launch the application on a connected device or emulator:

```bash
flutter run
```

### Running Unit Tests

A comprehensive unit test suite is available. To verify compilation, models serialization, and AI parsing logic:

```bash
flutter test
```
