import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents a user-defined tag with custom color
class NoteTag extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String colorHex;
  final DateTime? createdAt;

  const NoteTag({
    required this.id,
    required this.userId,
    required this.name,
    required this.colorHex,
    this.createdAt,
  });

  /// Default tags with predefined colors
  static const List<NoteTag> defaults = [
    NoteTag(id: 'default_ide', userId: '', name: 'Ide', colorHex: '#4A5568'),
    NoteTag(id: 'default_catatan', userId: '', name: 'Catatan', colorHex: '#D69E2E'),
    NoteTag(id: 'default_pengingat', userId: '', name: 'Pengingat', colorHex: '#C53030'),
  ];

  /// Get Color object from hex string
  Color get color {
    try {
      final hex = colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  /// Get background color with opacity for chips
  Color get backgroundColor => color.withOpacity(0.2);

  NoteTag copyWith({
    String? id,
    String? userId,
    String? name,
    String? colorHex,
    DateTime? createdAt,
  }) {
    return NoteTag(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, colorHex, createdAt];
}
