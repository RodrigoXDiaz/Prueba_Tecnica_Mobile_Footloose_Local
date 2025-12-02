import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final StreamController<RemoteMessage> _messageStreamController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<String> _tokenRefreshController =
      StreamController<String>.broadcast();

  Stream<RemoteMessage> get onMessage => _messageStreamController.stream;
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  Future<void> initialize() async {
    await requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Notificación recibida en foreground:');
        print('Título: ${message.notification?.title}');
        print('Cuerpo: ${message.notification?.body}');
        print('Data: ${message.data}');
      }
      _messageStreamController.add(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Usuario abrió notificación:');
        print('Data: ${message.data}');
      }
      _messageStreamController.add(message);
    });

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print('App abierta desde notificación:');
        print('Data: ${initialMessage.data}');
      }
      _messageStreamController.add(initialMessage);
    }

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        print('Token FCM actualizado: $newToken');
      }
      _tokenRefreshController.add(newToken);
    });
  }

  Future<void> requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Estado de permisos: ${settings.authorizationStatus}');
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('Usuario autorizó notificaciones');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('Usuario autorizó notificaciones provisionales');
      }
    } else {
      if (kDebugMode) {
        print('Usuario denegó notificaciones');
      }
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('Token FCM: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener token FCM: $e');
      }
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      if (kDebugMode) {
        print('Token FCM eliminado');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar token FCM: $e');
      }
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Suscrito al topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al suscribirse al topic $topic: $e');
      }
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Desuscrito del topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al desuscribirse del topic $topic: $e');
      }
    }
  }

  void dispose() {
    _messageStreamController.close();
    _tokenRefreshController.close();
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Notificación recibida en background:');
    print('Título: ${message.notification?.title}');
    print('Cuerpo: ${message.notification?.body}');
    print('Data: ${message.data}');
  }
}
