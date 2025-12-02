import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper para descargas multiplataforma
class DownloadHelper {
  /// Descarga/guarda un archivo en la plataforma actual
  /// Retorna la ruta del archivo guardado o null si falla
  static Future<String?> saveFile({
    required List<int> bytes,
    required String fileName,
  }) async {
    if (kIsWeb) {
      // En web, esto se maneja de forma diferente con dart:html
      // La implementación web usa el stub web_download_stub.dart
      return null;
    } else {
      // Para móvil, guardamos el archivo localmente
      return _saveForMobile(bytes, fileName);
    }
  }

  static Future<String?> _saveForMobile(
      List<int> bytes, String fileName) async {
    try {
      // Obtener directorio de descargas o documentos
      Directory? directory;

      if (Platform.isAndroid) {
        // En Android, intentar usar Downloads o fallback a documentos
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getApplicationDocumentsDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath = '${directory.path}/$fileName';

      // Guardar archivo
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      debugPrint('Archivo guardado en: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error al guardar archivo: $e');
      return null;
    }
  }

  /// Abre un archivo con la aplicación predeterminada del sistema
  static Future<bool> openFile(String filePath) async {
    try {
      final uri = Uri.file(filePath);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      return false;
    } catch (e) {
      debugPrint('Error al abrir archivo: $e');
      return false;
    }
  }
}
