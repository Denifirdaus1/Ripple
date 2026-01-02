# Data Tidak Ter-load Setelah Re-login & Unexpected Signout

**ID:** FIND_002 | **Status:** ✅ Resolved | **Prioritas:** 🔴 High
**Dibuat:** 2025-12-31 | **Update:** 2025-12-31
**Plan:** [PLAN_011](../Plan/PLAN_011_fix_auth_session.md) (Implemented)

---

## 📝 Deskripsi Masalah

### Bug 1: Data Tidak Langsung Ter-load Setelah Re-login
Setelah user login kembali ke akun yang sudah berisi data (Todo, Notes, dll), data tidak langsung ter-load dan tampil kosong. Data baru akan ter-load setelah user keluar dari aplikasi (hot restart/cold start).

**Steps to Reproduce:**
1. Login dengan akun yang sudah memiliki data
2. Logout
3. Login kembali dengan akun yang sama
4. **Expected:** Data langsung tampil
5. **Actual:** Data kosong, baru tampil setelah restart app

### Bug 2: Unexpected Signout
User tiba-tiba ter-signout dan diminta login kembali padahal user tidak melakukan logout secara manual. Ini mungkin terjadi setelah beberapa waktu idle atau saat app di-resume dari background.

---

## 🕵️ Analisis & Hipotesis

### Root Cause Analysis

#### Bug 1: Bloc Lifecycle Issue
```dart
// Di app.dart - Bloc di-create SEKALI saat app startup
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>()..add(AuthSubscriptionRequested()),
    ),
    BlocProvider<TodosOverviewBloc>(
      create: (_) => sl<TodosOverviewBloc>()..add(TodosOverviewSubscriptionRequested()),  // ⚠️ Langsung subscribe!
    ),
    BlocProvider<NoteBloc>(
      create: (_) => sl<NoteBloc>()..add(NoteSubscriptionRequested()),  // ⚠️ Langsung subscribe!
    ),
  ],
  // ...
)
```

**Masalah:**
- `TodosOverviewBloc` dan `NoteBloc` langsung trigger subscription saat app start
- Data Blocs subscribe ke Supabase stream yang filtered by `user_id`
- Saat user logout → state kosong, tapi Bloc instance tetap sama
- Saat user login kembali → Bloc tidak di-reset atau re-subscribe
- Subscription lama masih active dengan state lama

#### Bug 2: Session Token Expiry
```dart
// Di auth_bloc.dart
_authSubscription = _getAuthStream().listen(
  (user) => add(AuthUserChanged(user)),
  onError: (error) => add(AuthLogoutRequested()), // ⚠️ Any error triggers logout!
);
```

**Masalah:**
- Tidak ada handling untuk Supabase session refresh
- Supabase access token default expiry: **1 jam**
- Jika token expired dan refresh gagal → stream error → force logout
- Tidak ada retry logic atau session recovery mechanism

### Checklist Investigasi
- [x] Cek `app.dart` - MultiBlocProvider lifecycle
- [x] Cek `auth_bloc.dart` - Session handling
- [x] Cek `todos_overview_bloc.dart` - Subscription pattern
- [ ] Cek Supabase session configuration
- [ ] Cek apakah ada `onAutoRefreshFail` handler

---

## 💡 Ide Solusi

### Solusi Bug 1: Auth-Aware Data Loading

**Option A: BlocListener untuk Reset Data Blocs**
```dart
BlocListener<AuthBloc, AuthState>(
  listenWhen: (previous, current) => 
    previous is! Authenticated && current is Authenticated,
  listener: (context, state) {
    // Re-trigger subscription saat user baru login
    context.read<TodosOverviewBloc>().add(TodosOverviewSubscriptionRequested());
    context.read<NoteBloc>().add(NoteSubscriptionRequested());
  },
)
```

**Option B: Lazy Loading - Subscribe hanya setelah Authenticated** *(Recommended)*
```dart
// Jangan langsung subscribe saat create
BlocProvider<TodosOverviewBloc>(
  create: (_) => sl<TodosOverviewBloc>(), // Tanpa ..add(SubscriptionRequested)
),

// Subscribe di halaman yang membutuhkan setelah auth check
class HomePage extends StatelessWidget {
  @override
  void initState() {
    super.initState();
    // Subscribe hanya kalau authenticated
    context.read<TodosOverviewBloc>().add(TodosOverviewSubscriptionRequested());
  }
}
```

**Option C: Combine - AuthBloc mengelola lifecycle data Blocs**
- Buat event `DataReloadRequested` di masing-masing data Bloc
- AuthBloc trigger reload saat state berubah ke `Authenticated`

### Solusi Bug 2: Session Persistence & Recovery

**1. Enable Auto Refresh di Supabase Init:**
```dart
await Supabase.initialize(
  url: supabaseUrl,
  anonKey: supabaseAnonKey,
  authOptions: const FlutterAuthClientOptions(
    autoRefreshToken: true,  // Default true, tapi pastikan
  ),
);
```

**2. Handle Session Refresh Events:**
```dart
// Di auth_remote_datasource.dart atau dedicated session service
Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  final event = data.event;
  if (event == AuthChangeEvent.tokenRefreshed) {
    // Token refreshed successfully
  } else if (event == AuthChangeEvent.signedOut) {
    // Check if this was unexpected
  }
});
```

**3. Graceful Error Handling di AuthBloc:**
```dart
_authSubscription = _getAuthStream().listen(
  (user) => add(AuthUserChanged(user)),
  onError: (error) {
    // Don't immediately logout, try to recover
    if (error is AuthException && error.message.contains('JWT')) {
      // Try refresh session first
      _tryRefreshSession();
    } else {
      add(AuthLogoutRequested());
    }
  },
);
```

---

## 🔗 Terkait
- **Topic:** [TOPIC_001](../Topic/TOPIC_001_ripple_mvp/_main.md) - Ripple MVP
- **Plan:** TBD (Perlu buat PLAN baru untuk fix)
- **Knowledge:** [K_001](../Knowledge/supabase/K_001_supabase_db_best_practices.md) - Supabase Best Practices

---

## 📋 Next Steps
1. [ ] Research Supabase session management best practices
2. [ ] Buat PLAN untuk implementasi fix
3. [ ] Implement & Test di device
