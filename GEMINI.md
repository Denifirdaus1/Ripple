# Ripple - Project Context

## Project Overview
**Ripple** is a productivity application built with Flutter. It integrates Todo List, Focus Mode (Pomodoro), Notes, and Milestone tracking into a single, cohesive platform. It aims to support users in managing daily tasks and achieving long-term goals, with optional AI integration.

**Current Phase:** MVP (Minimum Viable Product) focusing on core features: Todo, Focus Mode, Notes, and Milestones.

## Architecture & Tech Stack

### Core Technologies
*   **Framework:** Flutter (Dart)
*   **Backend:** Supabase (Auth, PostgreSQL Database, Realtime)
*   **State Management:** `flutter_bloc`
*   **Dependency Injection:** `get_it`
*   **Comparison**: `equatable`
*   **Configuration:** `flutter_dotenv`

### Architectural Pattern
The project follows **Clean Architecture** principles:
*   `lib/core`: Shared utilities, config, errors, and widgets.
*   `lib/features`: Feature-specific modules (e.g., `auth`, `todo`, `notes`).
    *   `presentation`: UI (Pages, Widgets) and Logic (Bloc/Cubit).
    *   `domain`: Entities, Use Cases, Repository Interfaces.
    *   `data`: DTOs, Repository Implementations, Data Sources.

## Building and Running

### Prerequisites
1.  **Flutter SDK**: Ensure Flutter is installed (`flutter doctor`).
2.  **Environment Variables**: Create a `.env` file in the root directory.
    ```env
    SUPABASE_URL=your_supabase_url
    SUPABASE_ANON_KEY=your_supabase_anon_key
    ```

### Commands
*   **Run Development:** `flutter run`
*   **Run Tests:** `flutter test`
*   **Analyze Code:** `flutter analyze`
*   **Build Android:** `flutter build apk`
*   **Build iOS:** `flutter build ios` (requires macOS)

## Development Conventions

### Coding Standards
*   Follow standard Dart/Flutter conventions.
*   Linting is enforced via `flutter_lints` in `analysis_options.yaml`.
*   Use `underscore_case` for file names and `PascalCase` for classes.

### Agent Workflow (Agent-0)
This project maintains an external memory and documentation system in the `Agent-0/` directory.
*   **Standards**: Refer to `.agent/STANDARDS.md` for strict naming and logging conventions.
*   **Topics**: Feature definitions and discussions in `Agent-0/Topic/`.
*   **Knowledge**: Technical findings and best practices in `Agent-0/Knowledge/`.
*   **Plans**: Implementation plans in `Agent-0/Plan/`.
*   **Logs**: Activity and failure logs in `Agent-0/Log/`.

**Note**: When creating new documentation or planning files, strictly adhere to the ID format (`TOPIC_NNN`, `PLAN_NNN`) defined in `STANDARDS.md`.
