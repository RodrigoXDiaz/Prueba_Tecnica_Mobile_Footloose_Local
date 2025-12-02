import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? productId;
  final double? oldPrice;
  final double? newPrice;
  final int? discount;
  final String? imageUrl;
  final DateTime sentAt;
  final bool read;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.productId,
    this.oldPrice,
    this.newPrice,
    this.discount,
    this.imageUrl,
    required this.sentAt,
    this.read = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Manejo flexible de tipos
    double? convertToDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    int? convertToInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Convertir Firestore Timestamp a DateTime
    DateTime convertToDateTime(dynamic value) {
      if (value == null) return DateTime.now();

      // Si es un Map con _seconds (Firestore Timestamp)
      if (value is Map && value.containsKey('_seconds')) {
        final seconds = value['_seconds'] as int;
        final nanoseconds = value['_nanoseconds'] as int? ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds / 1000000).round(),
        );
      }

      // Si es un String ISO 8601
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }

      // Si es un timestamp en milisegundos
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }

      return DateTime.now();
    }

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      productId: json['productId']?.toString(),
      oldPrice: convertToDouble(json['oldPrice']),
      newPrice: convertToDouble(json['newPrice']),
      discount: convertToInt(json['discount']),
      imageUrl: json['imageUrl']?.toString(),
      sentAt: convertToDateTime(json['sentAt']),
      read: json['read'] == true,
    );
  }

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    String? productId,
    double? oldPrice,
    double? newPrice,
    int? discount,
    String? imageUrl,
    DateTime? sentAt,
    bool? read,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      productId: productId ?? this.productId,
      oldPrice: oldPrice ?? this.oldPrice,
      newPrice: newPrice ?? this.newPrice,
      discount: discount ?? this.discount,
      imageUrl: imageUrl ?? this.imageUrl,
      sentAt: sentAt ?? this.sentAt,
      read: read ?? this.read,
    );
  }
}

@JsonSerializable()
class NotificationHistoryResponse {
  final int total;
  final List<NotificationModel> notifications;

  const NotificationHistoryResponse({
    required this.total,
    required this.notifications,
  });

  factory NotificationHistoryResponse.fromJson(Map<String, dynamic> json) {
    // El backend envía la respuesta en formato: {success, message, data: {total, notifications}}
    final data = json['data'] as Map<String, dynamic>? ?? json;

    final notificationsList = (data['notifications'] as List<dynamic>?)
            ?.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return NotificationHistoryResponse(
      total: data['total'] as int? ?? 0,
      notifications: notificationsList,
    );
  }

  Map<String, dynamic> toJson() => _$NotificationHistoryResponseToJson(this);
}
