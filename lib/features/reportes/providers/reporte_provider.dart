import 'package:flutter/foundation.dart';

import '../../../core/services/api_service.dart';
import '../../materiales/data/material_resultado.dart';
import '../data/ferreteria.dart';
import '../data/reporte_repository.dart';

class ReporteProvider extends ChangeNotifier {
  final ReporteRepository _repository = ReporteRepository();

  // 0 = elegir material, 1 = precio + foto, 2 = elegir ferretería.
  int pasoActual = 0;

  // --- Paso 1: material ---
  List<MaterialResultado> resultadosBusqueda = [];
  bool buscandoMateriales = false;
  MaterialResultado? materialSeleccionado;

  // --- Paso 2: precio + foto ---
  double? precio;
  Uint8List? fotoBytes;
  String? fotoNombre;

  // --- Paso 3: ferretería ---
  List<Ferreteria> ferreterias = [];
  bool cargandoFerreterias = false;
  Ferreteria? ferreteriaSeleccionada;

  // --- Envío final ---
  bool enviando = false;
  String? errorMessage;

  Future<void> buscarMateriales(String texto) async {
    if (texto.trim().isEmpty) {
      resultadosBusqueda = [];
      notifyListeners();
      return;
    }
    buscandoMateriales = true;
    notifyListeners();
    try {
      resultadosBusqueda = await _repository.buscarMateriales(texto.trim());
    } catch (_) {
      resultadosBusqueda = [];
    } finally {
      buscandoMateriales = false;
      notifyListeners();
    }
  }

  void seleccionarMaterial(MaterialResultado material) {
    materialSeleccionado = material;
    pasoActual = 1;
    notifyListeners();
  }

  // Crea un material nuevo (no estaba en la búsqueda) y lo deja
  // seleccionado de inmediato, avanzando al paso 2. Lanza ApiException
  // si falla, para que el diálogo que la llama muestre el motivo exacto.
  Future<void> agregarMaterial({
    required String nombre,
    required String categoria,
    required String unidadMedida,
  }) async {
    final nuevo = await _repository.crearMaterial(
      nombre: nombre,
      categoria: categoria,
      unidadMedida: unidadMedida,
    );
    seleccionarMaterial(nuevo);
  }

  void setFoto(Uint8List bytes, String nombre) {
    fotoBytes = bytes;
    fotoNombre = nombre;
    notifyListeners();
  }

  void setPrecio(double valor) {
    precio = valor;
  }

  // Pide la lista de ferreterías la primera vez que se entra al paso 3.
  Future<void> cargarFerreteriasSiNecesario() async {
    if (ferreterias.isNotEmpty || cargandoFerreterias) return;
    cargandoFerreterias = true;
    notifyListeners();
    try {
      ferreterias = await _repository.listarFerreterias();
    } catch (_) {
      ferreterias = [];
    } finally {
      cargandoFerreterias = false;
      notifyListeners();
    }
  }

  void avanzarAFerreteria() {
    pasoActual = 2;
    notifyListeners();
    // No esperamos (no "await") a que termine: la pantalla ya se
    // actualiza con notifyListeners() de arriba, y cuando la lista de
    // ferreterías llegue, este método dispara OTRO notifyListeners()
    // internamente para mostrarla.
    cargarFerreteriasSiNecesario();
  }

  void retroceder() {
    if (pasoActual > 0) {
      pasoActual--;
      notifyListeners();
    }
  }

  void seleccionarFerreteria(Ferreteria ferreteria) {
    ferreteriaSeleccionada = ferreteria;
    notifyListeners();
  }

  // Crea una ferretería nueva (el usuario no la encontró en la lista)
  // y la deja seleccionada de inmediato. Lanza ApiException si falla,
  // para que el diálogo que la llama muestre el motivo exacto.
  Future<void> agregarFerreteria({
    required String nombre,
    required String direccion,
    required String sector,
  }) async {
    final nueva = await _repository.crearFerreteria(
      nombre: nombre,
      direccion: direccion,
      sector: sector,
    );
    ferreterias = [...ferreterias, nueva];
    ferreteriaSeleccionada = nueva;
    notifyListeners();
  }

  // Devuelve el mensaje de éxito del backend (incluye los puntos
  // ganados) si todo salió bien, o null si falló (el error queda en
  // errorMessage para que la pantalla lo muestre).
  Future<String?> enviarReporte() async {
    enviando = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Primero la foto: necesitamos su URL antes de poder crear el
      // reporte, porque el reporte la guarda como un campo más.
      final fotoUrl = await _repository.subirFoto(fotoBytes!, fotoNombre!);

      final mensaje = await _repository.crearReporte(
        materialId: materialSeleccionado!.id,
        ferreteriaId: ferreteriaSeleccionada!.id,
        precio: precio!,
        fotoUrl: fotoUrl,
      );

      _reiniciar();
      return mensaje;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return null;
    } catch (_) {
      errorMessage = 'No se pudo conectar al servidor';
      return null;
    } finally {
      enviando = false;
      notifyListeners();
    }
  }

  // Limpia todo para que el usuario pueda reportar otro precio desde cero.
  void _reiniciar() {
    pasoActual = 0;
    materialSeleccionado = null;
    precio = null;
    fotoBytes = null;
    fotoNombre = null;
    ferreteriaSeleccionada = null;
    resultadosBusqueda = [];
  }
}
