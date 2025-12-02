import 'package:equatable/equatable.dart';
import '../../../data/models/notification_preferences_model.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Suscribir usuario a notificaciones
class SubscribeToNotifications extends NotificationEvent {
  final String userId;
  final String fcmToken;
  final NotificationPreferencesModel preferences;

  const SubscribeToNotifications({
    required this.userId,
    required this.fcmToken,
    required this.preferences,
  });

  @override
  List<Object?> get props => [userId, fcmToken, preferences];
}

/// Actualizar preferencias
class UpdateNotificationPreferences extends NotificationEvent {
  final String userId;
  final NotificationPreferencesModel preferences;

  const UpdateNotificationPreferences({
    required this.userId,
    required this.preferences,
  });

  @override
  List<Object?> get props => [userId, preferences];
}

/// Seguir producto
class FollowProduct extends NotificationEvent {
  final String userId;
  final String productId;

  const FollowProduct({
    required this.userId,
    required this.productId,
  });

  @override
  List<Object?> get props => [userId, productId];
}

/// Dejar de seguir producto
class UnfollowProduct extends NotificationEvent {
  final String userId;
  final String productId;

  const UnfollowProduct({
    required this.userId,
    required this.productId,
  });

  @override
  List<Object?> get props => [userId, productId];
}

/// Cargar historial de notificaciones
class LoadNotificationHistory extends NotificationEvent {
  final String userId;
  final int limit;

  const LoadNotificationHistory({
    required this.userId,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [userId, limit];
}

/// Enviar notificación general (admin)
class SendGeneralNotification extends NotificationEvent {
  final String title;
  final String body;

  const SendGeneralNotification({
    required this.title,
    required this.body,
  });

  @override
  List<Object?> get props => [title, body];
}

/// Cargar productos seguidos
class LoadFollowedProducts extends NotificationEvent {
  final String userId;

  const LoadFollowedProducts({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Cargar preferencias actuales
class LoadNotificationPreferences extends NotificationEvent {
  final String userId;

  const LoadNotificationPreferences({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Marcar notificación como leída
class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;
  final String userId;

  const MarkNotificationAsRead({
    required this.notificationId,
    required this.userId,
  });

  @override
  List<Object?> get props => [notificationId, userId];
}

/// Eliminar notificación
class DeleteNotification extends NotificationEvent {
  final String notificationId;
  final String userId;

  const DeleteNotification({
    required this.notificationId,
    required this.userId,
  });

  @override
  List<Object?> get props => [notificationId, userId];
}
