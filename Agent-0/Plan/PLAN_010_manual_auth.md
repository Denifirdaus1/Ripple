# Manual Email Registration & Sign-In

**ID:** PLAN_010 | **Status:** ✅ Implemented | **Prioritas:** 🔴 High
**Dibuat:** 2025-12-30 | **Update:** 2025-12-30

## 🎯 Tujuan

Menambahkan fitur **Registrasi** dan **Sign-In Manual menggunakan Email/Password** dengan verifikasi email (OTP). Fitur ini akan **melengkapi** (bukan menggantikan) Google Sign-In yang sudah ada.

Ketika Google Sign-In billing aktif kembali, user yang sudah mendaftar dengan email yang sama akan otomatis terhubung ke akun yang sama (identity linking by email via Supabase Auth).

## 📋 Prerequisite Supabase

Pastikan di **Supabase Dashboard > Authentication > Providers**:
1.  ✅ **Email Provider** aktif (default sudah aktif).
2.  ✅ **Confirm email** diaktifkan (untuk verifikasi OTP).
3.  ✅ Template email "Confirm signup" sudah dikonfigurasi (jika ingin custom).

## 🛠️ Strategi Implementasi

### Phase 1: Data Layer

1. [ ] **Update `AuthRemoteDataSource`** (`lib/features/auth/data/datasources/auth_remote_datasource.dart`):
   - Tambahkan method abstrak:
     - `Future<void> signUpWithEmail(String email, String password);`
     - `Future<UserModel> signInWithEmail(String email, String password);`
     - `Future<UserModel> verifyOtp(String email, String token);`
     - `Future<void> resendConfirmationEmail(String email);`
   - Implementasikan menggunakan Supabase Auth API:
     ```dart
     // signUp
     await _supabaseClient.auth.signUp(email: email, password: password);
     
     // signIn
     final response = await _supabaseClient.auth.signInWithPassword(email: email, password: password);
     
     // verifyOtp
     final response = await _supabaseClient.auth.verifyOTP(type: OtpType.signup, email: email, token: token);
     
     // resendConfirmation
     await _supabaseClient.auth.resend(type: OtpType.signup, email: email);
     ```

2. [ ] **Update `AuthRepository`** (`lib/features/auth/domain/repositories/auth_repository.dart`):
   - Tambahkan method interface untuk operasi baru.

3. [ ] **Update `AuthRepositoryImpl`** (`lib/features/auth/data/repositories/auth_repository_impl.dart`):
   - Implementasikan delegasi ke `AuthRemoteDataSource`.

### Phase 2: Domain Layer (Use Cases)

4. [ ] **Buat Use Case baru** di `lib/features/auth/domain/usecases/`:
   - `sign_up_with_email.dart`
   - `sign_in_with_email.dart`
   - `verify_email_otp.dart`
   - `resend_confirmation_email.dart`

5. [ ] **Update `auth_usecases.dart`** barrel file.

### Phase 3: Presentation Layer (BLoC & Pages)

6. [ ] **Update/Buat `LoginCubit`** atau buat `AuthFormCubit` terpisah:
   - States: `initial`, `loading`, `success`, `error`, `awaitingVerification`
   - Events/Methods: `signUp`, `signIn`, `verifyOtp`, `resendOtp`

7. [ ] **Update `LoginPage`** (`lib/features/auth/presentation/pages/login_page.dart`):
   - Tambahkan Tab/Toggle: "Masuk" | "Daftar"
   - Tambahkan form fields: Email, Password, Confirm Password (untuk register)
   - Tambahkan link/button "Lupa Password?" (opsional, Phase 2)

8. [ ] **Buat `OtpVerificationPage`**:
   - Input 6-digit OTP code.
   - Button "Verifikasi" dan "Kirim Ulang Kode".
   - Timer countdown untuk resend (60 detik).

### Phase 4: Dependency Injection & Routing

9. [ ] **Update `injection_container.dart`**:
   - Register use cases baru.
   - Inject ke Cubit/Bloc yang relevan.

10. [ ] **Update `AppRouter`**:
    - Tambahkan route `/verify-otp` jika diperlukan (atau handle via modal).

### Phase 5: Error Handling & UX

11. [ ] **Implementasi Error Handling**:
    - "Email sudah terdaftar" -> arahkan ke Sign In.
    - "Email belum diverifikasi" -> arahkan ke halaman OTP.
    - "Password salah" -> tampilkan error.

## ✅ Kriteria Sukses

- [ ] User bisa mendaftar dengan email/password.
- [ ] User menerima email verifikasi OTP.
- [ ] User bisa sign-in setelah verifikasi.
- [ ] Data user tersimpan di `auth.users` Supabase dengan `email_confirmed_at` terisi.
- [ ] Google Sign-In **tetap berfungsi** (tidak terpengaruh).
- [ ] User dengan email yang sama dari Google Sign-In dan manual akan terhubung (identity linking).

## 🔗 Terkait

- Topic: [TOPIC_001_ripple_mvp](../Topic/TOPIC_001_ripple_mvp/_main.md)
- Plan: [PLAN_007_authentication.md](PLAN_007_authentication.md) (Google Sign-In)
