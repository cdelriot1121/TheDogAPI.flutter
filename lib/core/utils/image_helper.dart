import 'package:flutter/foundation.dart';

/// Retorna la URL de la imagen formateada.
/// Si se ejecuta en Flutter Web (`kIsWeb`), redirige la petición a través de un proxy CORS
/// para evitar que el navegador (CanvasKit/WebGL) bloquee la carga de píxeles desde el CDN de TheDogAPI.
String getImageUrl(String? originalUrl) {
  if (originalUrl == null || originalUrl.isEmpty) {
    return '';
  }
  if (kIsWeb) {
    if (originalUrl.startsWith('https://corsproxy.io/?')) {
      return originalUrl;
    }
    return 'https://corsproxy.io/?${Uri.encodeComponent(originalUrl)}';
  }
  return originalUrl;
}
