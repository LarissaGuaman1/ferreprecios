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
  final _picker = ImagePicker();

  @override
  void dispose() {
    _busquedaController.dispose();
    _precioController.dispose();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReporteProvider>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0x26FFFFFF), width: 0.5)),
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
              color: activo ? AppColors.tealGlass : AppColors.glassWhite,
              border: Border.all(
                color: activo ? const Color(0x991D9E75) : AppColors.glassBorder,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              titulos[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: activo ? Colors.white : AppColors.textSecondary,
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
            style: const TextStyle(color: Colors.white),
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
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '${material.categoria} · ${material.unidadMedida}',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
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

// --- Paso 2: precio + foto ---
class _PasoPrecioYFoto extends StatelessWidget {
  final TextEditingController controller;
  final Future<void> Function(ImageSource source) onElegirFoto;

  const _PasoPrecioYFoto({required this.controller, required this.onElegirFoto});

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
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Precio (USD)',
              prefixIcon: Icon(Icons.attach_money),
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
                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                  label: const Text('Cámara', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onElegirFoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
                  label: const Text('Galería', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // AnimatedBuilder escucha "controller" (un TextEditingController
          // también es un Listenable) y reconstruye SOLO este Row cuando
          // el texto cambia. Así el botón "Siguiente" se habilita o
          // deshabilita en vivo, sin envolver toda la pantalla en setState.
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final precioValido = double.tryParse(controller.text.replaceAll(',', '.'));
              final puedeContinuar =
                  precioValido != null && precioValido > 0 && provider.fotoBytes != null;

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
                            context.read<ReporteProvider>().setPrecio(precioValido);
                            context.read<ReporteProvider>().avanzarAFerreteria();
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
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${ferreteria.sector} · ${ferreteria.direccion}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _direccionController,
            style: const TextStyle(color: Colors.white),
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
                labelStyle: TextStyle(color: elegido ? Colors.white : const Color(0x80FFFFFF)),
                backgroundColor: const Color(0x0DFFFFFF),
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
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _categoriaController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Categoría',
              hintText: 'Ej: Cemento, Pintura, Sellantes',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _unidadController,
            style: const TextStyle(color: Colors.white),
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
