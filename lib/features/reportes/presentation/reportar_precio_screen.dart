import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_components.dart';
import '../providers/reporte_provider.dart';

class ReportarPrecioScreen extends StatefulWidget {
  const ReportarPrecioScreen({super.key});

  @override
  State<ReportarPrecioScreen> createState() => _ReportarPrecioScreenState();
}

class _ReportarPrecioScreenState extends State<ReportarPrecioScreen> {
  final _busquedaController = TextEditingController();
  final _precioController = TextEditingController();
  final _marcaController = TextEditingController();
  final _caracteristicasController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _busquedaController.dispose();
    _precioController.dispose();
    _marcaController.dispose();
    _caracteristicasController.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto(ImageSource source) async {
    // pickImage abre la cámara o la galería según "source", y devuelve
    // null si el usuario cancela (por eso el "if (archivo == null) return").
    final archivo = await _picker.pickImage(source: source, imageQuality: 80);
    if (archivo == null) return;

    final bytes = await archivo.readAsBytes();
    if (!mounted) return;
    context.read<ReporteProvider>().setFoto(bytes, archivo.name);
  }

  Future<void> _enviar() async {
    final provider = context.read<ReporteProvider>();
    final mensaje = await provider.enviarReporte();
    if (!mounted) return;

    if (mensaje != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
      _busquedaController.clear();
      _precioController.clear();
      _marcaController.clear();
      _caracteristicasController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReporteProvider>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.colorAppBarBorder, width: 0.5)),
          ),
          child: AppBar(title: const Text('Reportar precio')),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _IndicadorPasos(pasoActual: provider.pasoActual),
              ),
              Expanded(child: _construirPaso(provider)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirPaso(ReporteProvider provider) {
    switch (provider.pasoActual) {
      case 0:
        return _PasoMaterial(controller: _busquedaController);
      case 1:
        return _PasoPrecioYFoto(
          controller: _precioController,
          marcaController: _marcaController,
          caracteristicasController: _caracteristicasController,
          onElegirFoto: _elegirFoto,
        );
      default:
        return _PasoFerreteria(onEnviar: _enviar);
    }
  }
}

// Tres puntitos arriba, indicando en qué paso está el usuario.
class _IndicadorPasos extends StatelessWidget {
  final int pasoActual;

  const _IndicadorPasos({required this.pasoActual});

  @override
  Widget build(BuildContext context) {
    const titulos = ['1. Material', '2. Precio y foto', '3. Ferretería'];

    return Row(
      children: List.generate(3, (index) {
        final activo = index == pasoActual;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: activo ? AppColors.tealGlass : context.colorChipUnselectedBg,
              border: Border.all(
                color: activo ? const Color(0x991D9E75) : context.colorCardBorder,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              titulos[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: activo ? Colors.white : context.colorChipUnselectedText,
                fontSize: 11,
                fontWeight: activo ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// --- Paso 1: elegir material ---
class _PasoMaterial extends StatelessWidget {
  final TextEditingController controller;

  const _PasoMaterial({required this.controller});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReporteProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: controller,
            style: TextStyle(color: context.colorOnSurface),
            decoration: const InputDecoration(
              hintText: '¿Qué material vas a reportar?',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (texto) => context.read<ReporteProvider>().buscarMateriales(texto),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _DialogoNuevoMaterial(nombreInicial: controller.text),
              ),
              icon: const Icon(Icons.add_box_outlined, color: AppColors.priceColor),
              label: const Text(
                '¿No lo encuentras? Agrégalo',
                style: TextStyle(color: AppColors.priceColor),
              ),
            ),
          ),
        ),
        Expanded(
          child: provider.buscandoMateriales
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.resultadosBusqueda.length,
                  itemBuilder: (context, index) {
                    final material = provider.resultadosBusqueda[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        child: InkWell(
                          onTap: () => context.read<ReporteProvider>().seleccionarMaterial(material),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      material.nombre,
                                      style: TextStyle(color: context.colorOnSurface, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '${material.categoria} · ${material.unidadMedida}',
                                      style: TextStyle(color: context.colorOnSurfaceDim, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: context.colorOnSurfaceDim),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// --- Paso 2: precio + marca + foto ---
class _PasoPrecioYFoto extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController marcaController;
  final TextEditingController caracteristicasController;
  final Future<void> Function(ImageSource source) onElegirFoto;

  const _PasoPrecioYFoto({
    required this.controller,
    required this.marcaController,
    required this.caracteristicasController,
    required this.onElegirFoto,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReporteProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reportando: ${provider.materialSeleccionado?.nombre ?? ''}',
            style: TextStyle(color: context.colorOnSurface, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            style: TextStyle(color: context.colorOnSurface),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Precio (USD)',
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: marcaController,
            style: TextStyle(color: context.colorOnSurface),
            decoration: const InputDecoration(
              labelText: 'Marca *',
              hintText: 'Ej: Holcim, Condor, Sika',
              prefixIcon: Icon(Icons.label_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: caracteristicasController,
            style: TextStyle(color: context.colorOnSurface),
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Características (opcional)',
              hintText: 'Ej: resistencia 42.5 MPa, saco 50kg',
              prefixIcon: Icon(Icons.info_outline),
            ),
          ),
          const SizedBox(height: 20),
          if (provider.fotoBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.memory(provider.fotoBytes!, height: 180, fit: BoxFit.cover, width: double.infinity),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onElegirFoto(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Cámara'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onElegirFoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galería'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          AnimatedBuilder(
            animation: Listenable.merge([controller, marcaController]),
            builder: (context, _) {
              final precioValido = double.tryParse(controller.text.replaceAll(',', '.'));
              final puedeContinuar = precioValido != null &&
                  precioValido > 0 &&
                  marcaController.text.trim().isNotEmpty &&
                  provider.fotoBytes != null;

              return Row(
                children: [
                  TextButton(
                    onPressed: () => context.read<ReporteProvider>().retroceder(),
                    child: const Text('Atrás'),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Siguiente',
                    onPressed: puedeContinuar
                        ? () {
                            final rp = context.read<ReporteProvider>();
                            rp.setPrecio(precioValido);
                            rp.setMarcaYCaracteristicas(
                              marcaController.text.trim(),
                              caracteristicasController.text,
                            );
                            rp.avanzarAFerreteria();
                          }
                        : null,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- Paso 3: elegir ferretería + enviar ---
class _PasoFerreteria extends StatelessWidget {
  final Future<void> Function() onEnviar;

  const _PasoFerreteria({required this.onEnviar});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReporteProvider>();

    if (provider.cargandoFerreterias) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const _DialogoNuevaFerreteria(),
              ),
              icon: const Icon(Icons.add_business_outlined, color: AppColors.priceColor),
              label: const Text(
                '¿No está en la lista? Agrégala',
                style: TextStyle(color: AppColors.priceColor),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.ferreterias.length,
            itemBuilder: (context, index) {
              final ferreteria = provider.ferreterias[index];
              final seleccionada = provider.ferreteriaSeleccionada?.id == ferreteria.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  destacado: seleccionada,
                  child: InkWell(
                    onTap: () => context.read<ReporteProvider>().seleccionarFerreteria(ferreteria),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ferreteria.nombre,
                                style: TextStyle(color: context.colorOnSurface, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${ferreteria.sector} · ${ferreteria.direccion}',
                                style: TextStyle(color: context.colorOnSurfaceDim, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (seleccionada)
                          const Icon(Icons.check_circle, color: AppColors.priceColor),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (provider.errorMessage != null) ...[
                Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  TextButton(
                    onPressed: () => context.read<ReporteProvider>().retroceder(),
                    child: const Text('Atrás'),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Enviar reporte',
                    isLoading: provider.enviando,
                    onPressed: provider.ferreteriaSeleccionada != null ? onEnviar : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Formulario para registrar una ferretería que no estaba en la lista.
// Va dentro de un showDialog(), por eso es un widget separado: así
// maneja su propio estado (loading, error, controllers) sin mezclarlo
// con el resto de la pantalla del wizard.
class _DialogoNuevaFerreteria extends StatefulWidget {
  const _DialogoNuevaFerreteria();

  @override
  State<_DialogoNuevaFerreteria> createState() => _DialogoNuevaFerreteriaState();
}

class _DialogoNuevaFerreteriaState extends State<_DialogoNuevaFerreteria> {
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  String? _sectorElegido;
  bool _guardando = false;
  String? _error;

  static const _sectores = ['Norte', 'Sur', 'Centro', 'Valles'];

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_nombreController.text.trim().isEmpty ||
        _direccionController.text.trim().isEmpty ||
        _sectorElegido == null) {
      setState(() => _error = 'Completa nombre, dirección y sector');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      await context.read<ReporteProvider>().agregarFerreteria(
            nombre: _nombreController.text.trim(),
            direccion: _direccionController.text.trim(),
            sector: _sectorElegido!,
          );
      if (!mounted) return;
      Navigator.pop(context);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'No se pudo conectar al servidor');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar ferretería'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nombreController,
            style: TextStyle(color: context.colorOnSurface),
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _direccionController,
            style: TextStyle(color: context.colorOnSurface),
            decoration: const InputDecoration(labelText: 'Dirección'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _sectores.map((sector) {
              final elegido = _sectorElegido == sector;
              return ChoiceChip(
                label: Text(sector),
                selected: elegido,
                labelStyle: TextStyle(
                  color: elegido ? Colors.white : context.colorChipUnselectedText,
                ),
                backgroundColor: context.colorChipUnselectedBg,
                selectedColor: AppColors.tealGlass,
                onSelected: (_) => setState(() => _sectorElegido = sector),
              );
            }).toList(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        PrimaryButton(label: 'Guardar', isLoading: _guardando, onPressed: _guardar),
      ],
    );
  }
}

// Formulario para registrar un material que no aparecía en la búsqueda.
// Mismo patrón que _DialogoNuevaFerreteria: vive dentro de un showDialog()
// y maneja su propio estado (loading, error, controllers).
class _DialogoNuevoMaterial extends StatefulWidget {
  final String nombreInicial;

  const _DialogoNuevoMaterial({required this.nombreInicial});

  @override
  State<_DialogoNuevoMaterial> createState() => _DialogoNuevoMaterialState();
}

class _DialogoNuevoMaterialState extends State<_DialogoNuevoMaterial> {
  late final _nombreController = TextEditingController(text: widget.nombreInicial);
  final _categoriaController = TextEditingController();
  final _unidadController = TextEditingController();
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _nombreController.dispose();
    _categoriaController.dispose();
    _unidadController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_nombreController.text.trim().isEmpty ||
        _categoriaController.text.trim().isEmpty ||
        _unidadController.text.trim().isEmpty) {
      setState(() => _error = 'Completa nombre, categoría y unidad de medida');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      await context.read<ReporteProvider>().agregarMaterial(
            nombre: _nombreController.text.trim(),
            categoria: _categoriaController.text.trim(),
            unidadMedida: _unidadController.text.trim(),
          );
      if (!mounted) return;
      Navigator.pop(context);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'No se pudo conectar al servidor');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar material'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nombreController,
            style: TextStyle(color: context.colorOnSurface),
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _categoriaController,
            style: TextStyle(color: context.colorOnSurface),
            decoration: const InputDecoration(
              labelText: 'Categoría',
              hintText: 'Ej: Cemento, Pintura, Sellantes',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _unidadController,
            style: TextStyle(color: context.colorOnSurface),
            decoration: const InputDecoration(
              labelText: 'Unidad de medida',
              hintText: 'Ej: saco 50kg, galón, tubo 280ml',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        PrimaryButton(label: 'Guardar', isLoading: _guardando, onPressed: _guardar),
      ],
    );
  }
}
