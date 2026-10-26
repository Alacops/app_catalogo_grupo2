import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Servicio para interacción con la Cámara y Galería multimedia (ImagePicker).
/// Almacena una copia persistente en el directorio de documentos de la aplicación.
class CamaraService {
  static final ImagePicker _picker = ImagePicker();

  /// Captura una fotografía usando la cámara del dispositivo.
  /// Retorna la ruta absoluta del archivo persistido localmente, o null si se cancela.
  static Future<String?> tomarFotoComprobante() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      if (foto == null) return null;
      return await _persistirArchivo(foto);
    } catch (e) {
      debugPrint('Error en CamaraService.tomarFotoComprobante: $e');
      return null;
    }
  }

  /// Selecciona una imagen desde la galería multimedia del dispositivo.
  static Future<String?> seleccionarDeGaleria() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      if (foto == null) return null;
      return await _persistirArchivo(foto);
    } catch (e) {
      debugPrint('Error en CamaraService.seleccionarDeGaleria: $e');
      return null;
    }
  }

  /// Copia el archivo temporal a una carpeta persistente 'comprobantes/' de la app
  static Future<String> _persistirArchivo(XFile archivoTemporal) async {
    final docDir = await getApplicationDocumentsDirectory();
    final carpetaComprobantes = Directory(p.join(docDir.path, 'comprobantes'));

    if (!await carpetaComprobantes.exists()) {
      await carpetaComprobantes.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = p.extension(archivoTemporal.path).isNotEmpty
        ? p.extension(archivoTemporal.path)
        : '.jpg';
    final nombreArchivo = 'comprobante_$timestamp$extension';
    final rutaDestino = p.join(carpetaComprobantes.path, nombreArchivo);

    final archivoDestino = await File(archivoTemporal.path).copy(rutaDestino);
    return archivoDestino.path;
  }
}
