import '../../../core/services/api_service.dart';
import 'material_resultado.dart';
import 'precio_reportado.dart';

class MaterialRepository {
  final ApiService _api = ApiService.instance;

  // Construye el "?clave=valor&clave2=valor2" a partir de un Map,
  // omitiendo las claves que vengan null o vacías. Uri.encodeQueryComponent
  // escapa espacios y caracteres especiales para que la URL sea válida.
  String _query(Map<String, String?> parametros) {
    final entradas = parametros.entries.where((e) => e.value != null && e.value!.isNotEmpty);
    if (entradas.isEmpty) return '';
    final partes = entradas.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value!)}');
    return '?${partes.join('&')}';
  }

  Future<List<MaterialResultado>> buscar({String? busqueda, String? sector}) async {
    final query = _query({'busqueda': busqueda, 'sector': sector});
    final respuesta = await _api.get('/materiales$query');

    // El backend responde una LISTA JSON directamente (no envuelta en
    // un objeto), por eso "respuesta" es una List aquí.
    return (respuesta as List)
        .map((item) => MaterialResultado.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<PrecioReportado>> obtenerPrecios(String materialId, {String? sector}) async {
    final query = _query({'sector': sector});
    final respuesta = await _api.get('/materiales/$materialId/precios$query');

    final precios = respuesta['precios'] as List;
    return precios.map((item) => PrecioReportado.fromJson(item as Map<String, dynamic>)).toList();
  }
}
