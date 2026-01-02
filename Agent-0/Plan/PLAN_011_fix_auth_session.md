# Fix Auth Session & Data Loading Issues

**ID:** PLAN_011 | **Status:** ✅ Implemented | **Prioritas:** 🔴 High
**Dibuat:** 2025-12-31 | **Update:** 2025-12-31

---

## 🎯 Tujuan

Memperbaiki dua bug kritis pada authentication flow:

1. **Bug 1:** Data (Todo, Notes, Goals) tidak ter-load setelah user re-login
2. **Bug 2:** User tiba-tiba ter-signout secara tidak terduga (session expiry)

### Expected Behavior Setelah Fix:
- ✅ Data langsung ter-load saat user login (tanpa perlu restart app)
- ✅ Session tetap aktif dengan token auto-refresh
- ✅ Graceful handling saat session expired (tidak langsung logout)
- ✅ Clean state saat user logout (no stale data)

---

## 🛠️ Strategi Implementasi

### Phase 1: Auth-Aware Data Loading

#### 1.1 [MODIFY] [app.dart](file:///c:/Project/ripple/lib/app.dart)

**Masalah saat ini:**
```dart
// Bloc langsung subscribe saat app start - SALAH!
BlocProvider<TodosOverviewBloc>(
  create: (_) => sl<TodosOverviewBloc>()..add(TodosOverviewSubscriptionRequested()),
),
```

**Solusi:** Wrap dengan `BlocListener` untuk trigger re-subscription saat auth state berubah:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>()..add(AuthSubscriptionRequested()),
    ),
    // Data Blocs tanpa auto-subscribe
    BlocProvider<TodosOverviewBloc>(create: (_) => sl<TodosOverviewBloc>()),
    BlocProvider<NoteBloc>(create: (_) => sl<NoteBloc>()),
    BlocProvider<GoalsBloc>(create: (_) => sl<GoalsBloc>()),
    BlocProvider<MilestonesBloc>(create: (_) => sl<MilestonesBloc>()),
  ],
  child: BlocListener<AuthBloc, AuthState>(
    listenWhen: (previous, current) {
      // Listen when: login success OR logout
      return (previous is! Authenticated && current is Authenticated) ||
             (previous is Authenticated && current is! Authenticated);
    },
    listener: (context, state) {
      if (state is Authenticated) {
        // User just logged in - trigger data load
        context.read<TodosOverviewBloc>().add(TodosOverviewSubscriptionRequested());
        context.read<NoteBloc>().add(NoteSubscriptionRequested());
        context.read<GoalsBloc>().add(GoalsSubscriptionRequested());
        context.read<MilestonesBloc>().add(MilestonesSubscriptionRequested());
      } else if (state is Unauthenticated) {
        // User logged out - clear data
        context.read<TodosOverviewBloc>().add(TodosOverviewClearRequested());
        context.read<NoteBloc>().add(NoteClearRequested());
        // ... etc
      }
    },
    child: Builder(...),
  ),
)
```

---

#### 1.2 [MODIFY] [todos_overview_bloc.dart](file:///c:/Project/ripple/lib/features/todo/presentation/bloc/todos_overview_bloc.dart)

**Tambahkan event untuk clear data:**

```dart
// Event baru
class TodosOverviewClearRequested extends TodosOverviewEvent {}

// Handler
void _onClearRequested(
  TodosOverviewClearRequested event,
  Emitter<TodosOverviewState> emit,
) {
  _todosSubscription?.cancel();
  emit(const TodosOverviewState()); // Reset ke initial state
}
```

---

#### 1.3 [MODIFY] [note_bloc.dart](file:///c:/Project/ripple/lib/features/notes/presentation/bloc/note_bloc.dart)

**Tambahkan event untuk clear data** (sama seperti Todo):

```dart
class NoteClearRequested extends NoteEvent {}
```

---

#### 1.4 [MODIFY] Goals & Milestones Blocs (jika ada)

Tambahkan `ClearRequested` event ke semua data Blocs.

---

### Phase 2: Session Management & Token Refresh

#### 2.1 [MODIFY] [auth_bloc.dart](file:///c:/Project/ripple/lib/features/auth/presentation/bloc/auth_bloc.dart)

**Masalah saat ini:**
```dart
onError: (error) => add(AuthLogoutRequested()), // Langsung logout!
```

**Solusi:** Tambahkan event untuk session events dan retry logic:

```dart
// Tambah events baru
class AuthTokenRefreshed extends AuthEvent {}
class AuthSessionExpired extends AuthEvent {}

// Ubah subscription handling
Future<void> _onSubscriptionRequested(...) async {
  await _authSubscription?.cancel();
  _authSubscription = _getAuthStream().listen(
    (user) => add(AuthUserChanged(user)),
    onError: (error) {
      // Don't immediately logout - emit error state first
      // User might still have valid refresh token
      if (error.toString().contains('JWT') || 
          error.toString().contains('token')) {
        emit(const AuthSessionExpiring()); // New state
      } else {
        emit(AuthError(error.toString()));
      }
    },
  );
}

// Add new state
class AuthSessionExpiring extends AuthState {
  const AuthSessionExpiring();
}
```

---

#### 2.2 [NEW] [session_service.dart](file:///c:/Project/ripple/lib/core/services/session_service.dart)

**Buat service khusus untuk session management:**

```dart
class SessionService {
  final SupabaseClient _client;
  StreamSubscription? _subscription;

  SessionService(this._client);

  /// Initialize session monitoring
  void initialize() {
    _subscription = _client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      
      switch (event) {
        case AuthChangeEvent.tokenRefreshed:
          AppLogger.i('Session: Token refreshed successfully');
          break;
        case AuthChangeEvent.signedOut:
          AppLogger.i('Session: User signed out');
          break;
        case AuthChangeEvent.signedIn:
          AppLogger.i('Session: User signed in');
          break;
        default:
          break;
      }
    });
  }

  /// Check if current session is valid
  bool get hasValidSession {
    final session = _client.auth.currentSession;
    return session != null && !session.isExpired;
  }

  /// Attempt to refresh session manually
  Future<bool> tryRefreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      return response.session != null;
    } catch (e) {
      AppLogger.e('Session refresh failed', e);
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
```

---

#### 2.3 [MODIFY] [main.dart](file:///c:/Project/ripple/lib/main.dart)

**Pastikan auto refresh enabled dan initialize session service:**

```dart
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  authOptions: const FlutterAuthClientOptions(
    autoRefreshToken: true, // Explicit (sudah default true)
  ),
);

// Initialize session service
sl<SessionService>().initialize();
```

---

#### 2.4 [MODIFY] [injection_container.dart](file:///c:/Project/ripple/lib/core/injection/injection_container.dart)

**Register SessionService:**

```dart
sl.registerLazySingleton<SessionService>(
  () => SessionService(Supabase.instance.client),
);
```

---

### Phase 3: Enhanced Auth State Handling

#### 3.1 [MODIFY] [auth_remote_datasource.dart](file:///c:/Project/ripple/lib/features/auth/data/datasources/auth_remote_datasource.dart)

**Enhance authStateChanges to include event info:**

```dart
// Tambah class untuk wrap auth event
class AuthStateData {
  final UserModel? user;
  final AuthChangeEvent event;
  
  AuthStateData({this.user, required this.event});
}

// Update stream
Stream<AuthStateData> get authStateChangesWithEvent {
  return _supabaseClient.auth.onAuthStateChange.map((authState) {
    final user = authState.session?.user;
    return AuthStateData(
      user: user != null ? UserModel.fromSupabase(user) : null,
      event: authState.event,
    );
  });
}
```

---

## ✅ Kriteria Sukses

1. [ ] **Build berhasil** - `flutter analyze` tanpa error
2. [ ] **Login flow correct** - Data ter-load langsung setelah login
3. [ ] **Logout flow correct** - Data ter-clear saat logout
4. [ ] **Re-login flow correct** - Login ulang → data fresh, bukan stale
5. [ ] **Session persistence** - Token auto-refresh bekerja (test dengan session expire)
6. [ ] **Existing tests pass** - `flutter test` semua pass

---

## 🧪 Verification Plan

### Automated Tests

**Run existing tests:**
```powershell
cd c:\Project\ripple
flutter test
```

**Existing test coverage:**
- `auth_bloc_test.dart` - Tests basic auth states (Authenticated, Unauthenticated)
- `todos_overview_bloc_test.dart` - Tests todo subscription

**New tests needed:**
- [ ] Test `TodosOverviewClearRequested` event
- [ ] Test `NoteClearRequested` event
- [ ] Test auth state transitions trigger data reload

### Manual Verification (User Testing)

> ⚠️ **PENTING:** Karena ini melibatkan session dan real Supabase, perlu testing manual di device.

**Test Case 1: Login → Data Load**
1. Fresh install app / clear app data
2. Login dengan akun yang sudah ada data
3. ✅ Expected: Data langsung tampil tanpa delay

**Test Case 2: Logout → Login → Data Load**
1. Dari state logged in dengan data
2. Logout
3. Login kembali dengan akun yang sama
4. ✅ Expected: Data langsung tampil (bukan kosong)

**Test Case 3: Switch Account**
1. Login dengan Akun A (ada data)
2. Logout
3. Login dengan Akun B (data berbeda)
4. ✅ Expected: Data Akun B tampil (bukan data Akun A)

**Test Case 4: Session Persistence**
1. Login, tutup app (don't kill)
2. Buka app lagi setelah 5-10 menit
3. ✅ Expected: Tetap logged in, data tampil

---

## 📋 Implementation Checklist

### Phase 1: Auth-Aware Data Loading
- [ ] Modify `app.dart` - Add BlocListener for auth state
- [ ] Add `TodosOverviewClearRequested` event + handler
- [ ] Add `NoteClearRequested` event + handler
- [ ] Add clear events to Goals/Milestones Blocs if needed

### Phase 2: Session Management
- [ ] Create `SessionService` 
- [ ] Register in DI container
- [ ] Initialize in `main.dart`
- [ ] Update `AuthBloc` error handling

### Phase 3: Testing
- [ ] Run `flutter analyze`
- [ ] Run `flutter test`
- [ ] Manual testing on device

---

## 🔗 Terkait

- **Finding:** [FIND_002](../Find/FIND_002_auth_session_data_load.md) - Data Tidak Ter-load & Unexpected Signout
- **Topic:** [TOPIC_001](../Topic/TOPIC_001_ripple_mvp/_main.md) - Ripple MVP
- **Plan:** [PLAN_007](PLAN_007_authentication.md) - Original Authentication Implementation
