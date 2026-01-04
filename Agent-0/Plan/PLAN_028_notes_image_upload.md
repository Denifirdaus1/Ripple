# PLAN_028: Notes Image Upload Feature

**ID:** PLAN_028 | **Status:** ✅ Implemented | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-04 | **Update:** 2026-01-04

## 🎯 Tujuan
1. Add image upload capability to Notes editor
2. Create Supabase storage bucket for note images
3. Compress images before upload (save bandwidth & storage)
4. Display images properly sized in Quill editor canvas

---

## 📊 Research Findings

### Required Packages
| Package | Purpose | Status |
|---------|---------|--------|
| `flutter_quill_extensions` | Image embed support for Quill | ✅ Already installed (v11.0.0) |
| `image_picker` | Pick image from gallery/camera | ❌ Need to add |
| `flutter_image_compress` | Compress images before upload | ❌ Need to add |

### Why These Packages?
**flutter_image_compress**:
- Best compression ratio in Flutter ecosystem
- Supports JPEG/PNG/WebP output
- Native implementation (Kotlin for Android, Obj-C for iOS)
- Quality control (0-100)
- Can resize + compress simultaneously

**flutter_quill_extensions**:
- Already includes `QuillEditorImageEmbedConfig`
- Supports custom `imageProviderBuilder` for URL images
- Handles image sizing in editor

---

## 🏗️ Architecture

### Flow Diagram
```
User taps camera icon → Image Picker (gallery/camera)
         ↓
    Raw image bytes
         ↓
    Flutter Image Compress (quality: 70, maxWidth: 1200)
         ↓
    Compressed bytes (~70-80% reduction)
         ↓
    Supabase Storage Upload (bucket: note-images)
         ↓
    Get Public URL
         ↓
    Insert into Quill Editor as BlockEmbed.image
         ↓
    Save Delta JSON (contains URL reference)
```

### Supabase Storage Setup
- **Bucket Name:** `note-images`
- **Bucket Type:** Public (for easy URL access)
- **RLS Policy:** 
  - Upload: Only authenticated users, path must start with their user_id
  - Delete: Only owner can delete their images

### Image Sizing in Editor
- Set `maxWidth: 1200px` before compress (for quality)
- In editor display: constrain to `MediaQuery.of(context).size.width - 40` (with padding)
- Use `QuillEditorImageEmbedConfig` for custom sizing

---

## 🛠️ Strategi Implementasi

### Phase 1: Add Dependencies
- [ ] Add `image_picker: ^1.1.2` to pubspec.yaml
- [ ] Add `flutter_image_compress: ^2.4.0` to pubspec.yaml
- [ ] Run `flutter pub get`

### Phase 2: Create Supabase Storage Bucket
- [ ] Create bucket `note-images` via Supabase MCP
- [ ] Set bucket to public
- [ ] Add RLS policy for upload (user can only upload to their folder)

### Phase 3: Create Image Upload Service
- [ ] Create `lib/core/services/image_upload_service.dart`
- [ ] Implement `pickAndCompressImage()` method
- [ ] Implement `uploadToSupabase()` method
- [ ] Return public URL after upload

### Phase 4: Integrate with Note Editor
- [ ] Update `note_keyboard_toolbar.dart` - camera icon action
- [ ] Update `note_editor_page.dart` - handle image insert
- [ ] Configure `FlutterQuillEmbeds.editorBuilders()` for image display
- [ ] Handle image sizing in editor

### Phase 5: Cleanup
- [ ] Handle image deletion when note is deleted (optional)
- [ ] Add loading indicator during upload

---

## 📁 Files Affected

### [NEW] [image_upload_service.dart](file:///c:/Project/ripple/lib/core/services/image_upload_service.dart)
- Image picker, compression, and Supabase upload logic

### [MODIFY] [pubspec.yaml](file:///c:/Project/ripple/pubspec.yaml)
- Add `image_picker` and `flutter_image_compress` dependencies

### [MODIFY] [note_keyboard_toolbar.dart](file:///c:/Project/ripple/lib/features/notes/presentation/widgets/note_keyboard_toolbar.dart)
- Add onImageTap callback implementation

### [MODIFY] [note_editor_page.dart](file:///c:/Project/ripple/lib/features/notes/presentation/pages/note_editor_page.dart)
- Handle image upload flow
- Configure QuillEditor with FlutterQuillEmbeds

### [MODIFY] [injection_container.dart](file:///c:/Project/ripple/lib/core/injection/injection_container.dart)
- Register ImageUploadService

---

## ✅ Kriteria Sukses
1. Tap camera icon → Image picker opens (gallery/camera) ✅
2. Select image → Image is compressed (~70% size reduction) ✅
3. Image uploads to Supabase storage bucket ✅
4. Image appears in editor properly sized (not overflowing) ✅
5. Image URL is saved in note's Delta JSON ✅
6. Reopen note → Image displays correctly from URL ✅

---

## 🧪 Verification Plan

### Static Analysis
```bash
flutter analyze
```

### Manual Testing
1. **Test Image Upload:**
   - Open note editor
   - Tap camera icon
   - Select image from gallery
   - Verify loading indicator appears
   - Verify image appears in editor
   - Verify image is properly sized (not overflowing)

2. **Test Image Persistence:**
   - After image upload, exit editor
   - Reopen the same note
   - Verify image still displays correctly

3. **Test Compression (Developer):**
   - Check Supabase storage bucket
   - Verify uploaded image size is smaller than original

---

## 🔗 Terkait
- [PLAN_027](PLAN_027_system_back_autodate.md) - System Back Fix
- [PLAN_024](PLAN_024_ui_refinement_tags.md) - Note Editor UI
