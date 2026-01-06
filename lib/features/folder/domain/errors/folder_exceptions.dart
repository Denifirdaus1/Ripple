/// Custom exceptions for the Folder feature.
/// Provides user-friendly error messages in Indonesian.

/// Base exception for folder-related errors
class FolderException implements Exception {
  final String message;
  final String? details;
  final dynamic originalError;

  FolderException(this.message, {this.details, this.originalError});

  @override
  String toString() => 'FolderException: $message${details != null ? ' ($details)' : ''}';
}

/// Thrown when user is not authenticated
class FolderAuthException extends FolderException {
  FolderAuthException() : super('Silakan login terlebih dahulu');
}

/// Thrown when folder is not found
class FolderNotFoundException extends FolderException {
  FolderNotFoundException(String folderId) 
    : super('Folder tidak ditemukan', details: 'ID: $folderId');
}

/// Thrown when circular dependency would be created
class FolderCircularDependencyException extends FolderException {
  FolderCircularDependencyException() 
    : super('Tidak dapat memindahkan folder ke dalam sub-folder-nya sendiri');
}

/// Thrown when folder name is invalid
class FolderInvalidNameException extends FolderException {
  FolderInvalidNameException() 
    : super('Nama folder tidak boleh kosong');
}

/// Thrown when item already exists in folder
class FolderItemDuplicateException extends FolderException {
  FolderItemDuplicateException() 
    : super('Item sudah ada di folder ini');
}

/// Thrown when network/database error occurs
class FolderNetworkException extends FolderException {
  FolderNetworkException({String? details, dynamic originalError}) 
    : super('Gagal terhubung ke server', details: details, originalError: originalError);
}

/// Error handler utility for folder operations
class FolderErrorHandler {
  /// Convert any exception to a user-friendly FolderException
  static FolderException handle(dynamic error, [StackTrace? stackTrace]) {
    // Already a FolderException
    if (error is FolderException) return error;

    final errorString = error.toString().toLowerCase();

    // Check for specific Supabase/PostgreSQL errors
    if (errorString.contains('not authenticated') || 
        errorString.contains('jwt')) {
      return FolderAuthException();
    }

    if (errorString.contains('unique constraint') ||
        errorString.contains('duplicate key')) {
      return FolderItemDuplicateException();
    }

    if (errorString.contains('circular') ||
        errorString.contains('would create loop')) {
      return FolderCircularDependencyException();
    }

    if (errorString.contains('not found') ||
        errorString.contains('0 rows')) {
      return FolderNotFoundException('unknown');
    }

    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('timeout') ||
        errorString.contains('connection')) {
      return FolderNetworkException(
        details: error.toString(),
        originalError: error,
      );
    }

    // Generic fallback
    return FolderException(
      'Terjadi kesalahan pada folder',
      details: error.toString(),
      originalError: error,
    );
  }

  /// Get user-friendly message for display
  static String getMessage(dynamic error) {
    if (error is FolderException) {
      return error.message;
    }
    return handle(error).message;
  }
}
