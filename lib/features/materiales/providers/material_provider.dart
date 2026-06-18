import 'package:flutter/foundation.dart';

import '../data/material_repository.dart';
import '../data/material_resultado.dart';

class MaterialProvider extends ChangeNotifier {
  final MaterialRepository _repository = MaterialRepository();

  List<MaterialResultado> resultados = [];
  bool isLoading = false;
  String? errorMessage;

  // null = "Todos los sectores" (sin filtro).
  String? sectorSeleccionado;
  String terminoBusqueda = '';

  // Lo llamamos al abrir la pantalla, y de nuevo cada vez que el
  // usuario busca o cambia el filtro de sector.
  Future<void> buscar({String? texto}) async {
    if (texto != null) terminoBusqueda = texto;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      resultados = await _repository.buscar(
        busqueda: terminoBusqueda,
        sector: sectorSeleccionado,
      );
    } catch (_) {
      errorMessage = 'No se pudo conectar al servidor';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Cambia el sector y vuelve a buscar automáticamente con ese filtro.
  void cambiarSector(String? sector) {
    sectorSeleccionado = sector;
    buscar();
  }
}
