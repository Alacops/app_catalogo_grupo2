import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

/// Sirve imágenes reales (descargadas a `test/fixtures/img/`) a las peticiones
/// `Image.network` durante los widget tests, para que las capturas muestren las
/// fotos de los productos en lugar del ícono de respaldo.
///
/// Uso:
/// ```dart
/// setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());
/// ```
/// Recuerda bombear dentro de `tester.runAsync` para dar tiempo a que la red
/// simulada y la decodificación de la imagen se completen.
class FakeImageHttpOverrides extends HttpOverrides {
  FakeImageHttpOverrides({this.carpeta = 'test/fixtures/img'});

  final String carpeta;
  final Map<String, Uint8List> _cache = {};
  Uint8List? _fallback;

  /// Reconstruye el nombre de archivo a partir de la URL: `<id>_w<ancho>.jpg`.
  String _nombreDeUrl(Uri url) {
    final id = url.pathSegments.isNotEmpty ? url.pathSegments.last : 'img';
    final w = url.queryParameters['w'] ?? '500';
    return '${id}_w$w.jpg';
  }

  Uint8List _bytesPara(Uri url) {
    final clave = url.toString();
    final enCache = _cache[clave];
    if (enCache != null) return enCache;

    final archivo = File('$carpeta/${_nombreDeUrl(url)}');
    if (archivo.existsSync()) {
      final bytes = archivo.readAsBytesSync();
      _cache[clave] = bytes;
      return bytes;
    }
    // Respaldo: primer archivo disponible (evita fallos si falta una imagen).
    _fallback ??= _buscarFallback();
    return _fallback ?? Uint8List(0);
  }

  Uint8List? _buscarFallback() {
    final dir = Directory(carpeta);
    if (!dir.existsSync()) return null;
    for (final f in dir.listSync()) {
      if (f is File && f.path.endsWith('.jpg')) return f.readAsBytesSync();
    }
    return null;
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _FakeHttpClient(_bytesPara);
}

class _FakeHttpClient implements HttpClient {
  _FakeHttpClient(this._resolver);

  final Uint8List Function(Uri) _resolver;

  @override
  bool autoUncompress = true;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  Duration? connectionTimeout;
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      _FakeHttpClientRequest(_resolver(url));

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeHttpClientRequest(_resolver(url));

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClientRequest implements HttpClientRequest {
  _FakeHttpClientRequest(this._bytes);

  final Uint8List _bytes;

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse(_bytes);

  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClientResponse implements HttpClientResponse {
  _FakeHttpClientResponse(this._bytes);

  final Uint8List _bytes;

  @override
  int get statusCode => 200;
  @override
  int get contentLength => _bytes.length;
  @override
  String get reasonPhrase => 'OK';
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable(<List<int>>[_bytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
