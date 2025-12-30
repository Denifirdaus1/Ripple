# K_001: Flutter Optimistic UI dengan Supabase

**Domain:** Flutter / Supabase  
**Tags:** `flutter`, `bloc`, `supabase`, `realtime`, `optimistic-ui`  
**Source:** Pengalaman debugging session 2025-12-30

---

## Ringkasan

Ketika menggunakan Supabase Realtime Stream untuk memperbarui UI, ada delay atau potensi kegagalan sinkronisasi. Solusinya adalah **Optimistic Update**: langsung perbarui state lokal setelah operasi database berhasil, tanpa menunggu sinyal balik dari Stream.

---

## Masalah

1. **Gejala:** Todo/Goal yang baru ditambahkan tidak langsung muncul di UI. Baru muncul setelah keluar-masuk aplikasi.
2. **Penyebab:** Aplikasi mengandalkan `Supabase Realtime Stream` untuk memperbarui list. Jika Realtime lambat/tidak aktif, UI tidak update.
3. **Error Tersembunyi:** `onError` pada listener Stream dikosongkan (`onError: (_) {}`), sehingga error tidak terlihat di log.

---

## Solusi: Optimistic Update Pattern

### 1. Ubah Return Type Repository

**Sebelum:**
```dart
Future<void> saveTodo(Todo todo);
```

**Sesudah:**
```dart
Future<Todo> saveTodo(Todo todo);
```

### 2. Implementasi Repository dengan `.select().single()`

```dart
@override
Future<Todo> saveTodo(Todo todo) async {
  final model = TodoModel.fromEntity(todo);
  final json = model.toJson();
  Map<String, dynamic> data;
  
  if (model.id.isEmpty) {
    data = await _supabase.from('todos').insert(json).select().single();
  } else {
    data = await _supabase.from('todos').upsert(json).select().single();
  }
  
  return TodoModel.fromJson(data);
}
```

### 3. Update State Lokal di Bloc

```dart
Future<void> _onTodoSaved(
  TodosOverviewTodoSaved event,
  Emitter<TodosOverviewState> emit,
) async {
  try {
    final savedTodo = await _saveTodo(event.todo);
    final currentTodos = List<Todo>.from(state.todos);
    final index = currentTodos.indexWhere((t) => t.id == savedTodo.id);
    
    if (index >= 0) {
      currentTodos[index] = savedTodo; // Update existing
    } else {
      currentTodos.add(savedTodo); // Add new
    }
    
    emit(state.copyWith(status: TodosOverviewStatus.success, todos: currentTodos));
  } catch (_) {
    emit(state.copyWith(status: TodosOverviewStatus.failure));
  }
}
```

### 4. Tambahkan Logging ke Stream Error

```dart
_subscription = _getTodosStream().listen(
  (todos) => add(_TodosUpdated(todos)),
  onError: (e, s) {
    AppLogger.e('Todos Stream Error', e, s);
    emit(state.copyWith(status: TodosOverviewStatus.failure));
  },
);
```

---

## Keuntungan

- ✅ UI update **instan** (tidak perlu tunggu Realtime)
- ✅ Jika Realtime mati/lambat, aplikasi tetap responsif
- ✅ Stream tetap berfungsi sebagai **sync mechanism** jika ada perubahan dari device lain

---

## Related

- **Topic:** TOPIC_001 (Ripple MVP)
- **Finding:** FINDING_001 (Todo Save UUID Error)

---

_Created: 2025-12-30 22:11 WIB_
