import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_property_option.dart';
import '../../domain/entities/entity_property.dart';
import '../../domain/repositories/property_repository.dart';

part 'property_options_state.dart';

/// Cubit for managing property options and entity properties
class PropertyOptionsCubit extends Cubit<PropertyOptionsState> {
  final PropertyRepository _repository;

  PropertyOptionsCubit({required PropertyRepository repository})
      : _repository = repository,
        super(const PropertyOptionsState());

  /// Load options for a specific property
  Future<void> loadOptions(String propertyId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final options = await _repository.getOptions(propertyId);
      emit(state.copyWith(
        isLoading: false,
        options: {...state.options, propertyId: options},
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Load entity properties
  Future<void> loadEntityProperties({
    required String entityType,
    required String entityId,
  }) async {
    try {
      final properties = await _repository.getEntityProperties(
        entityType: entityType,
        entityId: entityId,
      );
      emit(state.copyWith(
        enabledProperties: properties.map((p) => p.propertyId).toList().cast<String>(),
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Create a new option
  Future<void> createOption({
    required String propertyId,
    required String optionId,
    required String label,
    String? color,
  }) async {
    try {
      final option = await _repository.createOption(
        propertyId: propertyId,
        optionId: optionId,
        label: label,
        color: color,
      );
      final currentOptions = state.options[propertyId] ?? [];
      emit(state.copyWith(
        options: {...state.options, propertyId: [...currentOptions, option]},
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Update an option
  Future<void> updateOption(UserPropertyOption option) async {
    try {
      final updated = await _repository.updateOption(option);
      final currentOptions = state.options[option.propertyId] ?? <UserPropertyOption>[];
      final updatedOptions = currentOptions
          .map((o) => o.id == updated.id ? updated : o)
          .toList();
      emit(state.copyWith(
        options: {...state.options, option.propertyId: updatedOptions},
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Delete an option
  Future<void> deleteOption(String propertyId, String id) async {
    try {
      await _repository.deleteOption(id);
      final currentOptions = state.options[propertyId] ?? [];
      final updatedOptions = currentOptions.where((o) => o.id != id).toList();
      emit(state.copyWith(
        options: {...state.options, propertyId: updatedOptions},
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Enable a property on an entity
  Future<void> enableProperty({
    required String entityType,
    required String entityId,
    required String propertyId,
  }) async {
    try {
      await _repository.enableProperty(
        entityType: entityType,
        entityId: entityId,
        propertyId: propertyId,
      );
      emit(state.copyWith(
        enabledProperties: [...state.enabledProperties, propertyId],
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Disable a property on an entity
  Future<void> disableProperty({
    required String entityType,
    required String entityId,
    required String propertyId,
  }) async {
    try {
      await _repository.disableProperty(
        entityType: entityType,
        entityId: entityId,
        propertyId: propertyId,
      );
      emit(state.copyWith(
        enabledProperties: state.enabledProperties.where((p) => p != propertyId).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
