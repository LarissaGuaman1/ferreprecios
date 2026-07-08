import 'package:flutter/foundation.dart';

import '../data/ferreteria_modelo.dart';
import '../data/ferreteria_repository.dart';

class MiFerreteriaProvider extends ChangeNotifier {
  final FerreteriaRepository _repo = FerreteriaRepository();

  FerreteriaModelo? ferreteria;
  bool isLoading = false;
  bool guardando = false;
  bool actualizandoFoto = false;
  bool importandoCatalogo = false;
  String? errorMessage;

  Future<void> cargar() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      ferreteria = await _repo.obtenerMiFerreteria();
    } catch (e) {
      errorMessage = 'No se pudieron cargar los datos de la ferretería';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> guardar({
    required String nombre,
    required String direccion,
    required String sector,
    String? telefono,
    String? horario,
    String? descripcion,
  }) async {
    guardando = true;
    errorMessage = null;
    notifyListeners();

    try {
      ferreteria = await _repo.guardarMiFerreteria(
        nombre: nombre,
        direccion: direccion,
        sector: sector,
        telefono: telefono,
        horario: horario,
        descripcion: descripcion,
      );
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

  // Devuelve el resultado { importados, errores } o null si falló la conexión.
  Future<Map<String, dynamic>?> importarCatalogo(String csvContenido) async {
    importandoCatalogo = true;
    notifyListeners();
    try {
      return await _repo.importarCatalogo(csvContenido);
    } catch (e) {
      return null;
    } finally {
      importandoCatalogo = false;
      notifyListeners();
    }
  }

  Future<String?> actualizarFoto(List<int> bytes, String nombreArchivo) async {
    actualizandoFoto = true;
    notifyListeners();

    try {
      final url = await _repo.actualizarFoto(bytes, nombreArchivo);
      ferreteria = ferreteria?.copyWith(fotoUrl: url);
      return null;
    } catch (e) {
      return 'No se pudo actualizar la foto';
    } finally {
      actualizandoFoto = false;
      notifyListeners();
    }
  }
}
