import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Resultado del servicio de ubicación con metadatos y estado de degradación elegante.
class ResultadoUbicacion {
  final double latitud;
  final double longitud;
  final bool esUbicacionReal;
  final String mensaje;

  const ResultadoUbicacion({
    required this.latitud,
    required this.longitud,
    required this.esUbicacionReal,
    required this.mensaje,
  });
}

/// Servicio para interacción con el sensor GPS (Geolocator).
/// Conforme a la Sesión 7: Manejo de permisos en tiempo de ejecución y degradación elegante.
class UbicacionService {
  // Coordenadas de referencia: Plaza de Armas del Cusco (Ombligo del Mundo)
  static const double latPlazaArmasCusco = -13.5167;
  static const double lngPlazaArmasCusco = -71.9788;

  /// Obtiene la posición geográfica actual del dispositivo.
  /// Si los permisos son denegados o el GPS está desactivado, aplica degradación elegante
  /// retornando las coordenadas de referencia de la Plaza de Armas del Cusco.
  static Future<ResultadoUbicacion> obtenerUbicacionActual() async {
    try {
      bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicioHabilitado) {
        return const ResultadoUbicacion(
          latitud: latPlazaArmasCusco,
          longitud: lngPlazaArmasCusco,
          esUbicacionReal: false,
          mensaje: 'Servicio GPS desactivado. Usando Plaza de Armas Cusco como referencia.',
        );
      }

      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) {
          return const ResultadoUbicacion(
            latitud: latPlazaArmasCusco,
            longitud: lngPlazaArmasCusco,
            esUbicacionReal: false,
            mensaje: 'Permiso de ubicación denegado. Usando Plaza de Armas Cusco.',
          );
        }
      }

      if (permiso == LocationPermission.deniedForever) {
        return const ResultadoUbicacion(
          latitud: latPlazaArmasCusco,
          longitud: lngPlazaArmasCusco,
          esUbicacionReal: false,
          mensaje: 'Permiso permanentemente denegado. Usando ubicación de referencia.',
        );
      }

      // Obtener posición con timeout para evitar bloqueos
      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      return ResultadoUbicacion(
        latitud: posicion.latitude,
        longitud: posicion.longitude,
        esUbicacionReal: true,
        mensaje: 'Coordenadas GPS capturadas con precisión.',
      );
    } catch (e) {
      debugPrint('Error en UbicacionService: $e');
      return const ResultadoUbicacion(
        latitud: latPlazaArmasCusco,
        longitud: lngPlazaArmasCusco,
        esUbicacionReal: false,
        mensaje: 'Error de sensor GPS. Coordenadas de referencia asignadas.',
      );
    }
  }

  /// Calcula la distancia en kilómetros desde unas coordenadas dadas
  /// hasta el punto central de entrega (Plaza de Armas del Cusco).
  static double calcularDistanciaPlazaDeArmas(double lat, double lng) {
    final metros = Geolocator.distanceBetween(
      lat,
      lng,
      latPlazaArmasCusco,
      lngPlazaArmasCusco,
    );
    return metros / 1000.0;
  }
}
