import '../../core/constants/api_constants.dart';
import '../datasources/remote/api_service.dart';
import '../models/notification_model.dart';
import '../models/notification_preferences_model.dart';

class NotificationRepository {
  final ApiService _apiService;

  NotificationRepository(this._apiService);

  /// Suscribir usuario a notificaciones push
  Future<void> subscribe({
    required String userId,
    required String fcmToken,
    required NotificationPreferencesModel preferences,
  }) async {
    final fullUrl =
        '${_apiService.dio.options.baseUrl}${ApiConstants.notificationSubscribe}';
    print('🌐 URL COMPLETA de suscripción: $fullUrl');
    print('   - baseUrl: ${_apiService.dio.options.baseUrl}');
    print('   - path: ${ApiConstants.notificationSubscribe}');

    await _apiService.dio.post(
      ApiConstants.notificationSubscribe,
      data: {
        'userId': userId,
        'fcmToken': fcmToken,
        'preferences': preferences.toJson(),
      },
    );
  }

  /// Actualizar preferencias de notificaciones
  Future<void> updatePreferences({
    required String userId,
    required NotificationPreferencesModel preferences,
  }) async {
    await _apiService.dio.put(
      ApiConstants.notificationPreferences(userId),
      data: preferences.toJson(),
    );
  }

  /// Obtener historial de notificaciones
  Future<NotificationHistoryResponse> getHistory({
    required String userId,
    int limit = 50,
  }) async {
    final path = ApiConstants.notificationHistory(userId, limit: limit);
    final fullUrl = '${_apiService.dio.options.baseUrl}$path';
    print('🌐 URL COMPLETA de historial: $fullUrl');

    final response = await _apiService.dio.get(path);

    print('📡 Respuesta del backend:');
    print('   - Status code: ${response.statusCode}');
    print('   - Data type: ${response.data.runtimeType}');
    print('   - Data: ${response.data}');

    final historyResponse = NotificationHistoryResponse.fromJson(response.data);
    print(
        '📊 Historial parseado: ${historyResponse.notifications.length} notificaciones');

    return historyResponse;
  }

  /// Obtener preferencias del usuario
  Future<NotificationPreferencesModel> getPreferences({
    required String userId,
  }) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.notificationPreferences(userId),
      );

      return NotificationPreferencesModel.fromJson(response.data);
    } catch (e) {
      // Si falla, retornar preferencias por defecto
      return const NotificationPreferencesModel();
    }
  }

  /// Marcar notificación como leída
  Future<void> markAsRead({
    required String notificationId,
  }) async {
    await _apiService.dio.patch(
      ApiConstants.notificationMarkAsRead(notificationId),
    );
  }

  /// Eliminar notificación
  Future<void> deleteNotification({
    required String notificationId,
  }) async {
    await _apiService.dio.delete(
      ApiConstants.notificationDelete(notificationId),
    );
  }
}
