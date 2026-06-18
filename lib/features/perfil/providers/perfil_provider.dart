import 'package:flutter/foundation.dart';

import '../../../core/services/api_service.dart';
import '../data/perfil_repository.dart';
import '../data/perfil_resultado.dart';

class PerfilProvider extends ChangeNotifier {
  final PerfilRepository _repository = PerfilRepository();

  PerfilResultado? perfil;
  bool isLoading = false;
  String? errorMessage;

  // Mientras se sube la foto nueva (para mostrar un loading SOLO en
  // el avatar, sin tapar el resto de la pantalla con un spinner).
  bool actualizandoFoto = false;

  Future<void> cargarPerfil() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      perfil = await _repository.obtenerPerfil();
    } catch (_) {
      errorMessage = 'No se pudo conectar al servidor';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Devuelve un mensaje de error si algo falló, o null si todo salió bien.
  Future<String?> actualizarFoto(List<int> bytes, String nombreArchivo) async {
    actualizandoFoto = true;
    notifyListeners();

    try {
      final fotoUrl = await _repository.actualizarFoto(bytes, nombreArchivo);
      if (perfil != null) {
        perfil = perfil!.copyWith(fotoUrl: fotoUrl);
      }
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo conectar al servidor';
    } finally {
      actualizandoFoto = false;
      notifyListeners();
    }
  }
}
