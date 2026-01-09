import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/logger.dart';

class ImageUploadService {
  final SupabaseClient _supabaseClient;
  final ImagePicker _picker;

  ImageUploadService({
    required SupabaseClient supabaseClient,
    ImagePicker? picker,
  }) : _supabaseClient = supabaseClient,
       _picker = picker ?? ImagePicker();

  /// Picks an image from [source], compresses it, and uploads to Supabase.
  /// Returns the public URL of the uploaded image.
  Future<String?> pickAndUploadImage({
    required ImageSource source,
    int quality =
        50, // Lower quality = smaller file size (90% reduction target)
    int maxWidth = 1200,
  }) async {
    try {
      // 1. Pick Image
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return null;

      final File originalFile = File(pickedFile.path);
      final String fileExt = pickedFile.path.split('.').last;

      // 2. Compress Image
      final String targetPath =
          '${originalFile.parent.path}/${const Uuid().v4()}_compressed.$fileExt';
      final XFile?
      compressedFile = await FlutterImageCompress.compressAndGetFile(
        originalFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight:
            maxWidth, // Aspect ratio is preserved by package usually, but minWidth/Height acts as constraints
      );

      final File fileToUpload = compressedFile != null
          ? File(compressedFile.path)
          : originalFile;

      // 3. Upload to Supabase
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 8)}.$fileExt';
      final path = '$userId/$fileName';

      await _supabaseClient.storage
          .from('note-images')
          .upload(
            path,
            fileToUpload,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get public URL (bucket is public, no signed URL needed)
      final publicUrl = _supabaseClient.storage
          .from('note-images')
          .getPublicUrl(path);

      // Cleanup compressed file if it exists
      if (compressedFile != null) {
        try {
          await fileToUpload.delete();
        } catch (_) {}
      }

      AppLogger.i('Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      AppLogger.e('Error uploading image', e);
      rethrow;
    }
  }
}
