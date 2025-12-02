class ApiConstants {
  // URL del backend (configurada para web en Chrome)
  static const String baseUrl = 'https://prueba-tecnica-backend-footloose.onrender.com';
  static const String apiVersion = '/api/v1';

  // Auth Endpoints
  static const String register = '$apiVersion/auth/register';
  static const String login = '$apiVersion/auth/login';
  static const String me = '$apiVersion/auth/me';

  // Products Endpoints
  static const String products = '$apiVersion/products';
  static String productById(String id) => '$apiVersion/products/$id';
  static String updatePrice(String id) => '$apiVersion/products/$id/price';

  // Services Endpoints
  static const String importExcel = '$apiVersion/services/import/excel';
  static const String exportExcel = '$apiVersion/services/export/excel';
  static String generatePdf(String id) =>
      '$apiVersion/services/pdf/product/$id';
  static String uploadPdf(String id) =>
      '$apiVersion/services/pdf/product/$id/upload';

  // Notifications Endpoints
  static const String notificationSubscribe =
      '$apiVersion/notifications/subscribe';
  static String notificationPreferences(String userId) =>
      '$apiVersion/notifications/preferences/$userId';
  static String notificationHistory(String userId, {int limit = 50}) =>
      '$apiVersion/notifications/history/$userId?limit=$limit';
  static String notificationMarkAsRead(String notificationId) =>
      '$apiVersion/notifications/$notificationId/read';
  static String notificationDelete(String notificationId) =>
      '$apiVersion/notifications/$notificationId';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
