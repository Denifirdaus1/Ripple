import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_property_option.dart';
import '../../domain/entities/entity_property.dart';
import '../../domain/repositories/property_repository.dart';
import '../models/user_property_option_model.dart';
import '../models/entity_property_model.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final SupabaseClient _supabaseClient;

  PropertyRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  String get _userId => _supabaseClient.auth.currentUser!.id;

  @override
  Future<List<UserPropertyOption>> getOptions(String propertyId) async {
    final response = await _supabaseClient
        .from('user_property_options')
        .select()
        .eq('user_id', _userId)
        .eq('property_id', propertyId)
        .order('order_index');

    return (response as List)
        .map((json) => UserPropertyOptionModel.fromJson(json))
        .toList();
  }

  @override
  Future<UserPropertyOption> createOption({
    required String propertyId,
    required String optionId,
    required String label,
    String? color,
    String? icon,
    int orderIndex = 0,
  }) async {
    final response = await _supabaseClient
        .from('user_property_options')
        .insert({
          'user_id': _userId,
          'property_id': propertyId,
          'option_id': optionId,
          'label': label,
          'color': color,
          'icon': icon,
          'order_index': orderIndex,
          'is_default': false,
        })
        .select()
        .single();

    return UserPropertyOptionModel.fromJson(response);
  }

  @override
  Future<UserPropertyOption> updateOption(UserPropertyOption option) async {
    final response = await _supabaseClient
        .from('user_property_options')
        .update({
          'label': option.label,
          'color': option.color != null 
              ? '#${option.color!.value.toRadixString(16).substring(2).toUpperCase()}' 
              : null,
          'icon': option.icon,
          'order_index': option.orderIndex,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', option.id)
        .select()
        .single();

    return UserPropertyOptionModel.fromJson(response);
  }

  @override
  Future<void> deleteOption(String id) async {
    await _supabaseClient
        .from('user_property_options')
        .delete()
        .eq('id', id);
  }

  @override
  Future<List<EntityProperty>> getEntityProperties({
    required String entityType,
    required String entityId,
  }) async {
    final response = await _supabaseClient
        .from('entity_properties')
        .select()
        .eq('entity_type', entityType)
        .eq('entity_id', entityId);

    return (response as List)
        .map((json) => EntityPropertyModel.fromJson(json))
        .toList();
  }

  @override
  Future<EntityProperty> enableProperty({
    required String entityType,
    required String entityId,
    required String propertyId,
  }) async {
    final response = await _supabaseClient
        .from('entity_properties')
        .upsert({
          'entity_type': entityType,
          'entity_id': entityId,
          'property_id': propertyId,
          'user_id': _userId,
        }, onConflict: 'entity_type,entity_id,property_id')
        .select()
        .single();

    return EntityPropertyModel.fromJson(response);
  }

  @override
  Future<void> disableProperty({
    required String entityType,
    required String entityId,
    required String propertyId,
  }) async {
    await _supabaseClient
        .from('entity_properties')
        .delete()
        .eq('entity_type', entityType)
        .eq('entity_id', entityId)
        .eq('property_id', propertyId);
  }
}
