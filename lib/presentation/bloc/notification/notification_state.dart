import 'package:equatable/equatable.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/notification_preferences_model.dart';
import '../../../data/models/followed_product_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Cargando
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// Suscripción exitosa
class NotificationSubscribed extends NotificationState {
  const NotificationSubscribed();
}

/// Preferencias actualizadas
class NotificationPreferencesUpdated extends NotificationState {
  final NotificationPreferencesModel preferences;

  const NotificationPreferencesUpdated(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

/// Producto seguido
class ProductFollowed extends NotificationState {
  final String productId;

  const ProductFollowed(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Producto dejado de seguir
class ProductUnfollowed extends NotificationState {
  final String productId;

  const ProductUnfollowed(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Historial cargado
class NotificationHistoryLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int total;

  const NotificationHistoryLoaded({
    required this.notifications,
    required this.total,
  });

  @override
  List<Object?> get props => [notifications, total];
}

/// Notificación general enviada
class GeneralNotificationSent extends NotificationState {
  const GeneralNotificationSent();
}

/// Productos seguidos cargados
class FollowedProductsLoaded extends NotificationState {
  final List<FollowedProductModel> products;

  const FollowedProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

/// Preferencias cargadas
class NotificationPreferencesLoaded extends NotificationState {
  final NotificationPreferencesModel preferences;

  const NotificationPreferencesLoaded(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

/// Error
class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Nueva notificación recibida (para mostrar en la app)
class NotificationReceived extends NotificationState {
  final String title;
  final String body;
  final Map<String, dynamic> data;

  const NotificationReceived({
    required this.title,
    required this.body,
    required this.data,
  });

  @override
  List<Object?> get props => [title, body, data];
}
