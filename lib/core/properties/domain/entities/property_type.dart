/// Supported property types for the reusable property system.
/// Each type determines the UI widget and value handling.
enum PropertyType {
  /// Single line text input
  text,
  
  /// Multi-line text input
  multilineText,
  
  /// Numeric value (int or double)
  number,
  
  /// Date only (no time)
  date,
  
  /// Date and time
  datetime,
  
  /// Single selection from options
  select,
  
  /// Multiple selection from options (tags)
  multiSelect,
  
  /// Boolean checkbox
  checkbox,
  
  /// URL with validation
  url,
  
  /// Email with validation
  email,
  
  /// Phone number
  phone,
  
  /// Reference to another entity (e.g., Todo, Milestone)
  relation,
}

/// Extension methods for PropertyType
extension PropertyTypeExtension on PropertyType {
  /// Whether this property type requires predefined options
  bool get requiresOptions {
    return this == PropertyType.select || this == PropertyType.multiSelect;
  }
  
  /// Whether this property type stores a list of values
  bool get isMultiValue {
    return this == PropertyType.multiSelect;
  }
  
  /// Human-readable label for the property type
  String get label {
    switch (this) {
      case PropertyType.text:
        return 'Teks';
      case PropertyType.multilineText:
        return 'Teks Panjang';
      case PropertyType.number:
        return 'Angka';
      case PropertyType.date:
        return 'Tanggal';
      case PropertyType.datetime:
        return 'Tanggal & Waktu';
      case PropertyType.select:
        return 'Pilihan';
      case PropertyType.multiSelect:
        return 'Multi Pilihan';
      case PropertyType.checkbox:
        return 'Centang';
      case PropertyType.url:
        return 'URL';
      case PropertyType.email:
        return 'Email';
      case PropertyType.phone:
        return 'Telepon';
      case PropertyType.relation:
        return 'Relasi';
    }
  }
}
