import 'package:flutter/foundation.dart';

import '../data/ferreteria_modelo.dart';
import '../data/ferreteria_repository.dart';

class ListaFerreteriasProvider extends ChangeNotifier {
  final FerreteriaRepository _repo = FerreteriaRepository();

  List<FerreteriaModelo> ferreterias = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> cargar() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      ferreterias = await _repo.listarFerreterias();
    } catch (e) {
      errorMessage = 'No se pudo cargar la lista de ferreterías';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
