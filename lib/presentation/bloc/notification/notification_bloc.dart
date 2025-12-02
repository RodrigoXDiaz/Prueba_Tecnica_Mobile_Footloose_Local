import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;

  NotificationBloc(this._notificationRepository)
      : super(const NotificationInitial()) {
    on<SubscribeToNotifications>(_onSubscribeToNotifications);
    on<UpdateNotificationPreferences>(_onUpdateNotificationPreferences);
    on<LoadNotificationHistory>(_onLoadNotificationHistory);
    on<LoadNotificationPreferences>(_onLoadNotificationPreferences);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<DeleteNotification>(_onDeleteNotification);
  }

  Future<void> _onSubscribeToNotifications(
    SubscribeToNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(const NotificationLoading());

      await _notificationRepository.subscribe(
        userId: event.userId,
        fcmToken: event.fcmToken,
        preferences: event.preferences,
      );

      emit(const NotificationSubscribed());
    } catch (e) {
      emit(NotificationError('Error al suscribirse: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateNotificationPreferences(
    UpdateNotificationPreferences event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(const NotificationLoading());

      await _notificationRepository.updatePreferences(
        userId: event.userId,
        preferences: event.preferences,
      );

      emit(NotificationPreferencesUpdated(event.preferences));
    } catch (e) {
      emit(NotificationError(
          'Error al actualizar preferencias: ${e.toString()}'));
    }
  }

  Future<void> _onLoadNotificationHistory(
    LoadNotificationHistory event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(const NotificationLoading());

      final response = await _notificationRepository.getHistory(
        userId: event.userId,
        limit: event.limit,
      );

      emit(NotificationHistoryLoaded(
        notifications: response.notifications,
        total: response.total,
      ));
    } catch (e) {
      emit(NotificationError('Error al cargar historial: ${e.toString()}'));
    }
  }

  Future<void> _onLoadNotificationPreferences(
    LoadNotificationPreferences event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(const NotificationLoading());

      final preferences = await _notificationRepository.getPreferences(
        userId: event.userId,
      );

      emit(NotificationPreferencesLoaded(preferences));
    } catch (e) {
      emit(NotificationError('Error al cargar preferencias: ${e.toString()}'));
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Marcar como leída en el backend
      await _notificationRepository.markAsRead(
        notificationId: event.notificationId,
      );

      debugPrint('Notificación marcada como leída en backend');

      final response = await _notificationRepository.getHistory(
        userId: event.userId,
        limit: 50,
      );

      emit(NotificationHistoryLoaded(
        notifications: response.notifications,
        total: response.total,
      ));
    } catch (e) {
      debugPrint('Error al marcar como leída: $e');
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Eliminar en el backend
      await _notificationRepository.deleteNotification(
        notificationId: event.notificationId,
      );

      debugPrint('Notificación eliminada en backend');

      final response = await _notificationRepository.getHistory(
        userId: event.userId,
        limit: 50,
      );

      emit(NotificationHistoryLoaded(
        notifications: response.notifications,
        total: response.total,
      ));
    } catch (e) {
      debugPrint('Error al eliminar notificación: $e');
      emit(NotificationError('Error al eliminar: ${e.toString()}'));
    }
  }
}
