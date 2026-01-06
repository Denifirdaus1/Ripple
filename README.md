# Ripple

<p align="center">
  <img src="assets/icons/app_icon.png" width="120" alt="Ripple Logo">
</p>

<p align="center">
  <strong>Your All-in-One Productivity Companion</strong>
</p>

---

## 📱 About Ripple

**Ripple** is a productivity application built with Flutter that integrates essential productivity tools into a single, cohesive platform. It helps you manage daily tasks and achieve long-term goals effectively.

### Core Features

- 📋 **Todo List** - Manage your daily tasks with priorities, due dates, and smart reminders
- ⏱️ **Focus Mode** - Pomodoro-style timer to boost your concentration and productivity
- 📝 **Notes** - Rich text editor with folder organization for your ideas and documentation
- 🎯 **Milestones** - Track your long-term goals and celebrate your achievements

---

## 🏗️ Architecture

Ripple follows **Clean Architecture** principles for maintainable and scalable code:

```
lib/
├── core/           # Shared utilities, config, errors, and widgets
└── features/       # Feature-specific modules
    ├── auth/       # Authentication
    ├── todo/       # Task management
    ├── notes/      # Note-taking
    ├── focus/      # Focus/Pomodoro timer
    └── goals/      # Milestones & goals
```

Each feature module is organized into three layers:
- **Presentation** - UI (Pages, Widgets) and Logic (Bloc/Cubit)
- **Domain** - Entities, Use Cases, Repository Interfaces
- **Data** - DTOs, Repository Implementations, Data Sources

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter (Dart) |
| Backend | Supabase |
| State Management | flutter_bloc |
| Dependency Injection | get_it |

---

## 🚀 Getting Started

### Prerequisites

1. **Flutter SDK** - Ensure Flutter is installed
   ```bash
   flutter doctor
   ```

2. **Environment Setup** - Create a `.env` file in the root directory with your configuration

### Installation

```bash
# Clone the repository
git clone https://github.com/Denifirdaus1/Ripple.git

# Navigate to project directory
cd ripple

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Available Commands

| Command | Description |
|---------|-------------|
| `flutter run` | Run development build |
| `flutter test` | Run unit tests |
| `flutter analyze` | Analyze code for issues |
| `flutter build apk` | Build Android APK |
| `flutter build ios` | Build iOS app (macOS only) |

---

## 📝 Development

### Coding Standards

- Follow standard Dart/Flutter conventions
- Linting enforced via `flutter_lints`
- File naming: `underscore_case`
- Class naming: `PascalCase`

### Project Status

**Current Phase:** MVP (Minimum Viable Product)

---

## 📄 License

This project is private and proprietary.

---

<p align="center">
  Made with ❤️ using Flutter
</p>
