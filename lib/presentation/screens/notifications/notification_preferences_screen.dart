import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/notification_preferences_model.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/notification/notification_event.dart';
import '../../bloc/notification/notification_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart' as auth_state;

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  bool _priceDrops = true;
  bool _newDiscounts = true;
  bool _stockAlerts = false;
  bool _generalNews = false;

  bool _isLoadingPreferences = false; // Cambio: no cargar del backend
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Los valores por defecto se usan (true, true, false, false)
  }

  void _loadData() {
    setState(() {
      _isLoadingPreferences = false;
      _hasError = false;
    });
  }

  void _updatePreferences() {
    // El backend maneja las preferencias automáticamente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferencias de Notificaciones'),
        backgroundColor: const Color(0xFF2D1B4E),
        foregroundColor: Colors.white,
      ),
      body: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationPreferencesLoaded) {
            setState(() {
              _priceDrops = state.preferences.priceDrops;
              _newDiscounts = state.preferences.newDiscounts;
              _stockAlerts = state.preferences.stockAlerts;
              _generalNews = state.preferences.generalNews;
              _isLoadingPreferences = false;
            });
          } else if (state is NotificationPreferencesUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Preferencias guardadas'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );
          } else if (state is NotificationError) {
            if (_isLoadingPreferences) {
              setState(() {
                _isLoadingPreferences = false;
                _hasError = true;
              });
            } else {
              debugPrint('Error al actualizar preferencias: ${state.message}');
            }
          }
        },
        child: _isLoadingPreferences
            ? const Center(child: CircularProgressIndicator())
            : _hasError
                ? _buildBackendNotReadyMessage()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPreferencesSection(),
                        const SizedBox(height: 24),
                        _buildAutomaticNotificationsInfo(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildBackendNotReadyMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 80,
              color: Colors.blue[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Backend de Notificaciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Los siguientes endpoints están disponibles. Puedes usar el modo demo para probar la interfaz sin conexión.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEndpointInfo('POST', '/api/v1/notifications/subscribe'),
                  const SizedBox(height: 8),
                  _buildEndpointInfo(
                      'PUT', '/api/v1/notifications/preferences/:userId'),
                  const SizedBox(height: 8),
                  _buildEndpointInfo(
                      'GET', '/api/v1/notifications/history/:userId'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar conexión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D1B4E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Permitir usar la interfaz aunque no haya backend
                setState(() {
                  _hasError = false;
                  _isLoadingPreferences = false;
                });
              },
              child: const Text('Usar de todos modos (modo demo)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndpointInfo(String method, String path) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: method == 'GET'
                ? Colors.green[100]
                : method == 'POST'
                    ? Colors.blue[100]
                    : Colors.orange[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            method,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: method == 'GET'
                  ? Colors.green[800]
                  : method == 'POST'
                      ? Colors.blue[800]
                      : Colors.orange[800],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            path,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: const Color(0xFF2D1B4E)),
                const SizedBox(width: 8),
                const Text(
                  'Tipos de Notificaciones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPreferenceSwitch(
              title: 'Bajadas de Precio',
              subtitle: 'Recibe alertas de TODAS las ofertas automáticamente',
              icon: Icons.trending_down,
              value: _priceDrops,
              onChanged: (value) {
                setState(() => _priceDrops = value);
              },
            ),
            const Divider(),
            _buildPreferenceSwitch(
              title: 'Ofertas y Descuentos',
              subtitle: 'Notificaciones sobre nuevas ofertas',
              icon: Icons.local_offer,
              value: _newDiscounts,
              onChanged: (value) {
                setState(() => _newDiscounts = value);
              },
            ),
            const Divider(),
            _buildPreferenceSwitch(
              title: 'Alertas de Stock',
              subtitle: 'Cuando un producto vuelva a estar disponible',
              icon: Icons.inventory,
              value: _stockAlerts,
              onChanged: (value) {
                setState(() => _stockAlerts = value);
              },
            ),
            const Divider(),
            _buildPreferenceSwitch(
              title: 'Noticias Generales',
              subtitle: 'Novedades y anuncios de FOOTLOOSE',
              icon: Icons.newspaper,
              value: _generalNews,
              onChanged: (value) {
                setState(() => _generalNews = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceSwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2D1B4E)),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF2D1B4E),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildAutomaticNotificationsInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 48,
              color: Colors.green[700],
            ),
            const SizedBox(height: 16),
            Text(
              '¡Notificaciones Automáticas!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cuando actives "Bajadas de Precio", recibirás notificaciones de TODAS las ofertas automáticamente. Ya no necesitas seguir productos manualmente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Sin configuración adicional requerida',
                    style: TextStyle(
                      color: Colors.green[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
