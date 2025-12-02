// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationPreferencesModel _$NotificationPreferencesModelFromJson(
        Map<String, dynamic> json) =>
    NotificationPreferencesModel(
      priceDrops: json['priceDrops'] as bool? ?? true,
      newDiscounts: json['newDiscounts'] as bool? ?? true,
      stockAlerts: json['stockAlerts'] as bool? ?? false,
      generalNews: json['generalNews'] as bool? ?? false,
    );

Map<String, dynamic> _$NotificationPreferencesModelToJson(
        NotificationPreferencesModel instance) =>
    <String, dynamic>{
      'priceDrops': instance.priceDrops,
      'newDiscounts': instance.newDiscounts,
      'stockAlerts': instance.stockAlerts,
      'generalNews': instance.generalNews,
    };
