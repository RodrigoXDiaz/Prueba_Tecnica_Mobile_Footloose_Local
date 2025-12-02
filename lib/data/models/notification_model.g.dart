// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      productId: json['productId'] as String?,
      oldPrice: (json['oldPrice'] as num?)?.toDouble(),
      newPrice: (json['newPrice'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String?,
      sentAt: DateTime.parse(json['sentAt'] as String),
      read: json['read'] as bool? ?? false,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'body': instance.body,
      'productId': instance.productId,
      'oldPrice': instance.oldPrice,
      'newPrice': instance.newPrice,
      'discount': instance.discount,
      'imageUrl': instance.imageUrl,
      'sentAt': instance.sentAt.toIso8601String(),
      'read': instance.read,
    };

NotificationHistoryResponse _$NotificationHistoryResponseFromJson(
        Map<String, dynamic> json) =>
    NotificationHistoryResponse(
      total: (json['total'] as num).toInt(),
      notifications: (json['notifications'] as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NotificationHistoryResponseToJson(
        NotificationHistoryResponse instance) =>
    <String, dynamic>{
      'total': instance.total,
      'notifications': instance.notifications,
    };
