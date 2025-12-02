import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/utils/app_events.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/bloc/notification/notification_bloc.dart';
import 'presentation/screens/auth/auth_screen.dart';
import 'presentation/screens/products/product_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCEVDiUk-rSpvV1L_zclm2Rz_GVRaudBnI',
      appId: '1:616106295586:web:030a04bf0cc4eeef9ca57b',
      messagingSenderId: '616106295586',
      projectId: 'footloose-prueba',
      authDomain: 'footloose-prueba.firebaseapp.com',
      storageBucket: 'footloose-prueba.firebasestorage.app',
      measurementId: 'G-5L4QDPVPGK',
    ),
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FirebaseMessagingService _messagingService;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    _messagingService = getIt<FirebaseMessagingService>();
    await _messagingService.initialize();

    // Escuchar mensajes de notificaciones
    _messagingService.onMessage.listen((message) {
      debugPrint('Notificación recibida en foreground:');
      debugPrint('Título: ${message.notification?.title}');
      debugPrint('Cuerpo: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');

      if (mounted && message.notification != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showNotificationSnackbar(
              message.notification!.title ?? 'Notificación',
              message.notification!.body ?? '',
              message.data,
            );
          }
        });
      }
    });

    // Escuchar cambios en el token FCM
    _messagingService.onTokenRefresh.listen((newToken) {
      debugPrint('Token FCM renovado: ${newToken.substring(0, 20)}...');
      _updateFcmToken(newToken);
    });
  }

  void _showNotificationSnackbar(
      String title, String body, Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('Contexto no disponible para mostrar snackbar');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.local_offer, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2D1B4E),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          bottom: 20,
          right: 20,
          left: 20,
        ),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'VER',
          textColor: Colors.white,
          onPressed: () async {
            final productId = data['productId']?.toString();
            if (productId != null && productId.isNotEmpty) {
              debugPrint('Navegando al producto: $productId');

              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(productId: productId),
                ),
              );

              AppEvents().triggerReloadData();
            } else {
              debugPrint('No hay productId en la notificación');
            }
          },
        ),
      ),
    );
  }

  void _updateFcmToken(String newToken) async {
    final authBloc = getIt<AuthBloc>();
    if (authBloc.state is AuthAuthenticated) {
      try {
        await getIt<NotificationBloc>().stream.first;
      } catch (e) {
        debugPrint('Error al actualizar token FCM: $e');
      }
    }
  }

  @override
  void dispose() {
    _messagingService.dispose();
    super.dispose();
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AuthBloc>()),
        BlocProvider(create: (context) => getIt<NotificationBloc>()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
