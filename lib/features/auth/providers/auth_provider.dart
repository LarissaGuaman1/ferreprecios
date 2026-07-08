import 'package:flutter/foundation.dart';

import '../../../core/services/api_service.dart';
import '../data/auth_repository.dart';

// ChangeNotifier es la clase base de Flutter para "estado observable":
// cualquier widget que se suscriba a este provider se reconstruye solo
// cuando llamamos notifyListeners().
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  // true mientras esperamos la respuesta del backend (login/registro).
  bool isLoading = false;

  // Mensaje de error a mostrar en la pantalla, o null si no hay error.
  String? errorMessage;

  // true si hay un usuario con sesión iniciada.
  bool isAuthenticated = false;

  // Datos básicos del usuario logueado, para mostrarlos en el Perfil.
  String? nombreUsuario;
  String? emailUsuario;
  String? fotoUrlUsuario;
  String rolUsuario = 'comprador';

  // true si el usuario es dueño de ferretería (cambia las pestañas del nav).
  bool get esDueno => rolUsuario == 'ferreteria';

  // Devuelve true/false según si el login funcionó, para que la
  // pantalla sepa si debe navegar al Home o quedarse mostrando el error.
  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final respuesta = await _repository.login(email: email, password: password);
      _guardarSesion(respuesta);
      return true;
    } on ApiException catch (e) {
      // Error esperado: el backend respondió pero con un mensaje
      // de error (ej: "Credenciales inválidas").
      errorMessage = e.message;
      return false;
    } catch (_) {
      // Error inesperado: sin conexión a internet, backend caído, etc.
      errorMessage = 'No se pudo conectar al servidor';
      return false;
    } finally {
      // "finally" se ejecuta SIEMPRE, haya salido bien o mal el try.
      // Es el lugar correcto para apagar el loading.
      isLoading = false;
      notifyListeners();
    }
  }

  // fotoBytes/fotoNombre son opcionales: el usuario puede elegir una
  // foto de perfil al registrarse, o saltarse ese paso y agregarla
  // después desde Perfil.
  Future<bool> register(
    String nombre,
    String email,
    String password, {
    String rol = 'comprador',
    Uint8List? fotoBytes,
    String? fotoNombre,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final respuesta = await _repository.register(
        nombre: nombre,
        email: email,
        password: password,
        rol: rol,
      );
      _guardarSesion(respuesta);

      if (fotoBytes != null && fotoNombre != null) {
        // Si la foto falla por algo (ej: sin internet justo en ese
        // instante), no queremos que se pierda la cuenta recién creada:
        // el registro ya se completó, la foto se puede agregar después.
        await _subirFotoInicial(fotoBytes, fotoNombre);
      }

      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (_) {
      errorMessage = 'No se pudo conectar al servidor';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _subirFotoInicial(Uint8List bytes, String nombreArchivo) async {
    try {
      final subida = await ApiService.instance.postArchivo(
        '/uploads/foto',
        bytes: bytes,
        campoArchivo: 'foto',
        nombreArchivo: nombreArchivo,
      );
      final fotoUrl = subida['url'] as String;
      await ApiService.instance.put('/usuarios/me/foto', {'fotoUrl': fotoUrl});
      fotoUrlUsuario = fotoUrl;
    } catch (_) {
      // Silencioso a propósito: ver comentario arriba, en register().
    }
  }

  void logout() {
    ApiService.instance.clearToken();
    isAuthenticated = false;
    nombreUsuario = null;
    emailUsuario = null;
    fotoUrlUsuario = null;
    rolUsuario = 'comprador';
    notifyListeners();
  }

  // Lo llama PerfilProvider después de subir una foto nueva, para que
  // el drawer (que lee de AuthProvider) se actualice también.
  void actualizarFoto(String fotoUrl) {
    fotoUrlUsuario = fotoUrl;
    notifyListeners();
  }

  // Lógica compartida entre login y register: guarda el token en
  // ApiService (para que viaje automático en futuras peticiones) y
  // los datos del usuario en este provider.
  void _guardarSesion(Map<String, dynamic> respuesta) {
    final token = respuesta['token'] as String;
    final usuario = respuesta['usuario'] as Map<String, dynamic>;

    ApiService.instance.setToken(token);
    nombreUsuario = usuario['nombre'] as String?;
    emailUsuario = usuario['email'] as String?;
    fotoUrlUsuario = usuario['fotoUrl'] as String?;
    rolUsuario = usuario['rol'] as String? ?? 'comprador';
    isAuthenticated = true;
  }
}
