import 'dart:async';

/// Event Bus global para comunicar eventos entre widgets sin acoplamiento
class AppEvents {
  static final AppEvents _instance = AppEvents._internal();
  factory AppEvents() => _instance;
  AppEvents._internal();

  // Stream para eventos de recarga de datos
  final _reloadDataController = StreamController<void>.broadcast();
  Stream<void> get onReloadData => _reloadDataController.stream;

  void triggerReloadData() {
    _reloadDataController.add(null);
  }

  void dispose() {
    _reloadDataController.close();
  }
}
