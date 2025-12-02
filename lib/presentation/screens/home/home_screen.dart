import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/firebase_messaging_service.dart';
import '../../../core/utils/app_events.dart';
import '../../../data/datasources/local/storage_service.dart';
import '../../../data/models/notification_preferences_model.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/notification/notification_event.dart';
import '../../bloc/notification/notification_state.dart';
import '../auth/auth_screen.dart';
import '../products/product_list_screen.dart';
import '../products/product_form_screen.dart';
import '../notifications/notification_history_screen.dart';
import '../notifications/notification_preferences_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProductBloc>()..add(const LoadProducts()),
      child: const HomeScreenView(),
    );
  }
}

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView>
    with WidgetsBindingObserver {
  bool _isLoggingOut = false;
  bool _hasSubscribed = false;
  StreamSubscription<void>? _reloadSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Escuchar eventos de recarga global
    _reloadSubscription = AppEvents().onReloadData.listen((_) {
      debugPrint('Evento de recarga recibido');
      _reloadData();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscribeToNotifications();
      _loadNotifications();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reloadSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed - Recargando datos');
      _reloadData();
    }
  }

  void _reloadData() {
    context.read<ProductBloc>().add(const LoadProducts());
    _loadNotifications();
  }

  void _loadNotifications() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && !authState.user.isAdmin) {
      try {
        debugPrint('📥 Cargando historial de notificaciones...');
        context.read<NotificationBloc>().add(
              LoadNotificationHistory(
                userId: authState.user.id,
                limit: 50,
              ),
            );
      } catch (e) {
        debugPrint('No se pudo cargar historial (backend no listo): $e');
      }
    }
  }

  void _subscribeToNotifications() async {
    if (_hasSubscribed) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && !authState.user.isAdmin) {
      try {
        debugPrint('🔔 Intentando suscribir usuario: ${authState.user.id}');
        final messagingService = getIt<FirebaseMessagingService>();
        final fcmToken = await messagingService.getToken();

        if (fcmToken != null) {
          debugPrint('Token FCM obtenido: ${fcmToken.substring(0, 20)}...');

          // Preferencias por defecto
          final preferences = NotificationPreferencesModel(
            priceDrops: true,
            newDiscounts: true,
            stockAlerts: false,
            generalNews: false,
          );

          debugPrint('Enviando suscripción al backend...');
          debugPrint('userId: ${authState.user.id}');
          debugPrint('fcmToken: $fcmToken');
          debugPrint('preferences: priceDrops=true, newDiscounts=true');

          context.read<NotificationBloc>().add(
                SubscribeToNotifications(
                  userId: authState.user.id,
                  fcmToken: fcmToken,
                  preferences: preferences,
                ),
              );
          _hasSubscribed = true;
          debugPrint('Evento SubscribeToNotifications enviado');
        } else {
          debugPrint('No se pudo obtener token FCM');
        }
      } catch (e) {
        debugPrint('Error al suscribir a notificaciones: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state is NotificationSubscribed) {
          debugPrint('Usuario suscrito a notificaciones exitosamente');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notificaciones activadas'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is NotificationError) {
          if (!state.message.contains('Recurso no encontrado') &&
              !state.message.contains('404')) {
            debugPrint('Error en notificaciones: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            debugPrint('Backend de notificaciones no disponible (esperado)');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.appName),
          actions: [
            // Botón de notificaciones con badge (solo para vendedores)
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated && !authState.user.isAdmin) {
                  return BlocBuilder<NotificationBloc, NotificationState>(
                    builder: (context, notifState) {
                      int unreadCount = 0;

                      if (notifState is NotificationHistoryLoaded) {
                        unreadCount = notifState.notifications
                            .where((n) => !n.read)
                            .length;
                      }

                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications),
                            tooltip: 'Notificaciones',
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NotificationHistoryScreen(),
                                ),
                              );

                              // Al regresar, recargar productos y notificaciones para ver cambios
                              if (context.mounted) {
                                debugPrint(
                                    'Recargando productos después de ver notificaciones');
                                context
                                    .read<ProductBloc>()
                                    .add(const LoadProducts());
                                _loadNotifications();
                              }
                            },
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  unreadCount > 9 ? '9+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Menú de usuario
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.account_circle),
                    onSelected: (value) {
                      if (value == 'logout') {
                        _showLogoutDialog(context);
                      } else if (value == 'preferences') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const NotificationPreferencesScreen(),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              state.user.email,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Chip(
                              label: Text(
                                state.user.isAdmin
                                    ? AppStrings.admin
                                    : AppStrings.seller,
                                style: const TextStyle(fontSize: 10),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      // Opción de preferencias de notificaciones (solo para vendedores)
                      if (!state.user.isAdmin)
                        const PopupMenuItem(
                          value: 'preferences',
                          child: Row(
                            children: [
                              Icon(Icons.settings),
                              SizedBox(width: 8),
                              Text('Preferencias de notificaciones'),
                            ],
                          ),
                        ),
                      if (!state.user.isAdmin) const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text(AppStrings.logout),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: const ProductListScreen(),
        floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated && state.user.isAdmin) {
              return FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (_) => const ProductFormScreen(),
                    ),
                  )
                      .then((result) {
                    if (result == true) {
                      // Recargar productos después de agregar/editar
                      context.read<ProductBloc>().add(const LoadProducts());
                    }
                  });
                },
                backgroundColor: const Color(0xFFE63946),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Agregar',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                elevation: 4,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }

  void _performLogout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      // Limpiar storage directamente
      final storageService = getIt<StorageService>();
      await storageService.clearAll();

      // Navegar al login
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _isLoggingOut = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
