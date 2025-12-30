# PLAN_007: Implement Authentication (Google Sign-In)

**ID:** PLAN_007 | **Status:** 🏗️ In Progress | **Prioritas:** 🔴 High
**Terkait:** [TOPIC_001](../Topic/TOPIC_001_ripple_mvp/_main.md)
**Constraint:** Clean Architecture, Flutter Bloc, Supabase Auth

---

# Goal Description
Implement the **Authentication** layer to secure the app. Users must log in via Google to access their data (`todos`, `notes`, etc. are RLS-protected).

The system includes:
1.  **Auth Logic**: `AppBloc` to handle global authentication state (Authenticated/Unauthenticated).
2.  **UI**: Login Page with Google Sign-In button.
3.  **Navigation**: `GoRouter` redirect logic to protect routes.

## User Review Required
> [!IMPORTANT]
> **Schema Strategy**:
> - We will rely on Supabase's native `auth.users` table.
> - **Public Profile**: We generally recommend a `public.profiles` table to store User Metadata (Avatar, Name) that is accessible via RLS to other users.
>   - *Decision*: Since the user said "schema already exists", we will check if we can just use `auth.currentUser` metadata directly in the client for MVP. If we need to store app-specific user settings later, we can create a `profiles` table then.
>
> **Google Sign-In**:
> - Configuration is already done (`google_sign_in` package, Supabase Dashboard).
> - We just need to wire up the `signInWithOAuth` call.

---

## Proposed Changes

### 1. Domain Layer (Auth)
#### [NEW] [lib/features/auth/domain/entities](file:///c:/Project/ripple/lib/features/auth/domain/entities/)
- `user_entity.dart`: Pure Dart class (`id`, `email`, `displayName`, `photoUrl`).

#### [NEW] [lib/features/auth/domain/repositories](file:///c:/Project/ripple/lib/features/auth/domain/repositories/)
- `auth_repository.dart`: Interface.
    - `Stream<UserEntity> get user`: Real-time auth state changes.
    - `Future<void> signInWithGoogle()`
    - `Future<void> signOut()`

#### [NEW] [lib/features/auth/domain/usecases](file:///c:/Project/ripple/lib/features/auth/domain/usecases/)
- `get_auth_stream.dart`
- `sign_in_google.dart`
- `sign_out.dart`

### 2. Data Layer (Supabase)
#### [NEW] [lib/features/auth/data/models](file:///c:/Project/ripple/lib/features/auth/data/models/)
- `user_model.dart`: Maps `supabase.auth.User` to `UserEntity`.

#### [NEW] [lib/features/auth/data/repositories](file:///c:/Project/ripple/lib/features/auth/data/repositories/)
- `auth_repository_impl.dart`:
    - Wraps `Supabase.instance.client.auth`.
    - Implements `signInWithOAuth(Provider.google)`.

### 3. Presentation Layer
#### [NEW] [lib/features/auth/presentation/bloc](file:///c:/Project/ripple/lib/features/auth/presentation/bloc/)
- `auth_bloc.dart`: Global scope.
    - State: `AuthUnknown`, `Authenticated(user)`, `Unauthenticated`.
    - Event: `AuthSubscriptionRequested`, `AuthLogoutRequested`.
- `login_cubit.dart`: Manages loading state of Login Button.

#### [NEW] [lib/features/auth/presentation/pages](file:///c:/Project/ripple/lib/features/auth/presentation/pages/)
- `login_page.dart`: Simple UI with "Welcome to Ripple" and "Sign in with Google".

### 4. Core & Navigation
#### [MODIFY] [lib/core/router/app_router.dart](file:///c:/Project/ripple/lib/core/router/app_router.dart)
- Update `GoRouter` to listen to `AuthBloc`.
- Add `redirect`:
    - If not logged in & not on Login page -> Go to Login.
    - If logged in & on Login page -> Go to Home.

#### [MODIFY] [lib/injection_container.dart](file:///c:/Project/ripple/lib/injection_container.dart)
- Register Auth dependencies.

---

## Verification Plan

### Automated Tests
```bash
flutter test test/features/auth/presentation/bloc/auth_bloc_test.dart
```

### Manual Verification
1.  **Initial Load**: Open app. Should redirect to `/login` immediately.
2.  **Login**: Tap "Sign in with Google".
    - (Simulator): Mock login or opens browser.
    - (Real Device): Opens Google Sheet.
3.  **Success**: After login, should redirect to `/home`.
4.  **Restart**: Kill app and reopen. Should auto-login (remain on `/home`).
5.  **Logout**: Tap Logout button. Should redirect to `/login`.
