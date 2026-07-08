import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// Excepción propia para errores de la API. La lanzamos con el mensaje
// que mande el backend (ej: "Credenciales inválidas"), para que la
// pantalla que llama pueda mostrarlo directo al usuario.
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

// Único punto de la app que sabe hacer peticiones HTTP.
// Todo lo demás (auth_repository, y después materiales_repository,
// reportes_repository, etc.) usa esta clase en vez de llamar a
// package:http directamente.
class ApiService {
  // --- Patrón Singleton ---
  // Constructor privado: nadie de afuera puede escribir "ApiService()".
  ApiService._();

  // La única instancia que va a existir en toda la app. Cualquier
  // archivo que quiera hacer una petición usa "ApiService.instance".
  static final ApiService instance = ApiService._();

  // URL base de tu backend. Cuando despliegues en Railway, solo
  // cambias este valor (ej: "https://tu-app.up.railway.app/api").
  static const String _baseUrl = 'http://46.224.5.181:8080/api';

  // Token JWT del usuario logueado. Empieza en null (nadie ha iniciado
  // sesión). Es privado: nadie de afuera lo lee o modifica directamente,
  // solo a través de los métodos de abajo.
  String? _token;

  // Lo llama auth_provider después de un login/registro exitoso.
  void setToken(String token) {
    _token = token;
  }

  // Lo llama auth_provider al cerrar sesión.
  void clearToken() {
    _token = null;
  }

  // Headers que se mandan en CADA petición. Si hay token guardado,
  // se agrega automáticamente: así el backend sabe quién es el usuario.
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Future<dynamic> = "en algún momento va a devolver un valor, todavía
  // no sabemos de qué tipo exacto (puede ser un Map o una List, según
  // el endpoint)". El "await" pausa esta función hasta que la
  // respuesta de la red llegue, sin bloquear el resto de la app.
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers,
    );
    return _procesarRespuesta(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers,
      // jsonEncode convierte el Map de Dart en un String JSON,
      // que es el formato que entiende el backend.
      body: jsonEncode(body),
    );
    return _procesarRespuesta(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _procesarRespuesta(response);
  }

  // Para mandar un ARCHIVO (ej: una foto) no se puede usar JSON normal:
  // se necesita un "multipart/form-data", el mismo formato que usa un
  // <form> HTML con un <input type="file">. http.MultipartRequest es
  // la herramienta de Dart para armar ese tipo de petición.
  Future<dynamic> postArchivo(
    String endpoint, {
    required List<int> bytes,
    required String campoArchivo,
    required String nombreArchivo,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl$endpoint'));

    // No reusamos "_headers" porque ese incluye "Content-Type: application/json",
    // y MultipartRequest necesita poner su propio Content-Type
    // (con un "boundary" especial). Solo agregamos el token manualmente.
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        campoArchivo,
        bytes,
        filename: nombreArchivo,
        // Sin esto, MultipartFile asume "application/octet-stream"
        // (archivo genérico). El backend revisa que el tipo empiece
        // con "image/" para aceptar la foto, así que sin este dato
        // la rechaza aunque el contenido sí sea una imagen válida.
        contentType: _tipoMimeDeImagen(nombreArchivo),
      ),
    );

    // .send() devuelve la respuesta "en pedazos" (streamed); la juntamos
    // en un http.Response normal para poder reusar _procesarRespuesta.
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _procesarRespuesta(response);
  }

  // Deduce el tipo de imagen a partir de la extensión del archivo.
  // "jpeg" es el valor por defecto porque es el formato más común
  // que entregan las cámaras de celular.
  MediaType _tipoMimeDeImagen(String nombreArchivo) {
    final extension = nombreArchivo.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg');
    }
  }

  // Revisa la respuesta UNA sola vez aquí, en vez de repetir esta
  // lógica en cada método (get, post, y los que agreguemos después).
  dynamic _procesarRespuesta(http.Response response) {
    // jsonDecode hace lo contrario a jsonEncode: convierte el String
    // JSON que manda el backend en un Map/List de Dart.
    final decoded = jsonDecode(response.body);

    // Códigos 200-299 = la petición salió bien.
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    // Si el backend manda un campo "message" en el error, lo usamos;
    // si no, mostramos un mensaje genérico con el código de error.
    final mensaje = decoded is Map && decoded['message'] != null
        ? decoded['message'] as String
        : 'Error en la petición (${response.statusCode})';
    throw ApiException(mensaje);
  }
}
