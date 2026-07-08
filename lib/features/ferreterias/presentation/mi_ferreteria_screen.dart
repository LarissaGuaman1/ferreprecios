import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_components.dart';
import '../providers/mi_ferreteria_provider.dart';

const _sectores = ['Norte', 'Sur', 'Centro', 'Valles'];

class MiFerreteriaScreen extends StatefulWidget {
  const MiFerreteriaScreen({super.key});

  @override
  State<MiFerreteriaScreen> createState() => _MiFerreteriaScreenState();
}

class _MiFerreteriaScreenState extends State<MiFerreteriaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _horarioCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _picker = ImagePicker();

  String _sector = _sectores.first;
  bool _datosInicializados = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MiFerreteriaProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    _horarioCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  // Llena los campos con los datos que llegaron del backend (solo la primera vez).
  void _inicializarCampos(MiFerreteriaProvider provider) {
    if (_datosInicializados || provider.ferreteria == null) return;
    final f = provider.ferreteria!;
    _nombreCtrl.text = f.nombre;
    _direccionCtrl.text = f.direccion;
    _telefonoCtrl.text = f.telefono ?? '';
    _horarioCtrl.text = f.horario ?? '';
    _descripcionCtrl.text = f.descripcion ?? '';
    if (_sectores.contains(f.sector)) _sector = f.sector;
    _datosInicializados = true;
  }

  Future<void> _cambiarFoto() async {
    final origen = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.colorSurfaceBg,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: ctx.colorOnSurface),
              title: Text('Cámara', style: TextStyle(color: ctx.colorOnSurface)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: ctx.colorOnSurface),
              title: Text('Galería', style: TextStyle(color: ctx.colorOnSurface)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (origen == null || !mounted) return;

    final archivo = await _picker.pickImage(source: origen, imageQuality: 80);
    if (archivo == null || !mounted) return;

    final bytes = await archivo.readAsBytes();
    if (!mounted) return;

    final error = await context.read<MiFerreteriaProvider>().actualizarFoto(
          bytes,
          archivo.name,
        );

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await context.read<MiFerreteriaProvider>().guardar(
          nombre: _nombreCtrl.text.trim(),
          direccion: _direccionCtrl.text.trim(),
          sector: _sector,
          telefono: _telefonoCtrl.text.trim(),
          horario: _horarioCtrl.text.trim(),
          descripcion: _descripcionCtrl.text.trim(),
        );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Ferretería guardada con éxito!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _subirCatalogo() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
      withData: true,
    );

    if (resultado == null || resultado.files.isEmpty) return;
    final bytes = resultado.files.first.bytes;
    if (bytes == null || !mounted) return;

    final contenido = utf8.decode(bytes);
    final respuesta = await context.read<MiFerreteriaProvider>().importarCatalogo(contenido);
    if (!mounted) return;

    if (respuesta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo conectar al servidor'), backgroundColor: AppColors.error),
      );
      return;
    }

    final importados = respuesta['importados'] as int;
    final errores = (respuesta['errores'] as List).cast<Map<String, dynamic>>();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.colorDropdownBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Resultado de importación', style: TextStyle(color: ctx.colorOnSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.check_circle, color: AppColors.priceColor, size: 20),
              const SizedBox(width: 8),
              Text(
                '$importados precios importados',
                style: const TextStyle(color: AppColors.priceColor, fontWeight: FontWeight.bold),
              ),
            ]),
            if (errores.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '${errores.length} filas con errores:',
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
              const SizedBox(height: 6),
              ...errores.take(5).map((e) => Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      '• Fila ${e['fila']}: ${e['motivo']}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  )),
              if (errores.length > 5)
                Text(
                  '  ...y ${errores.length - 5} más',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MiFerreteriaProvider>();
    _inicializarCampos(provider);

    return AppBackground(
      child: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título
                      Text(
                        'Mi Ferretería',
                        style: TextStyle(
                          color: context.colorOnSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Esta información aparece en la lista pública de ferreterías',
                        style: TextStyle(color: context.colorOnSurfaceDim, fontSize: 13),
                      ),
                      const SizedBox(height: 24),

                      // Foto de la ferretería
                      Center(
                        child: GestureDetector(
                          onTap: provider.ferreteria == null ? null : _cambiarFoto,
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.tealGlass,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.glassBorder),
                                ),
                                child: provider.actualizandoFoto
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primary,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : provider.ferreteria?.fotoUrl != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: Image.network(
                                              provider.ferreteria!.fotoUrl!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.store_outlined,
                                            size: 48,
                                            color: AppColors.primary,
                                          ),
                              ),
                              if (provider.ferreteria != null && !provider.actualizandoFoto)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (provider.ferreteria == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Center(
                            child: Text(
                              'Guarda los datos primero para agregar foto',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Campos del formulario
                      _Campo(
                        label: 'Nombre de la ferretería *',
                        controller: _nombreCtrl,
                        icon: Icons.storefront_outlined,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
                      ),
                      const SizedBox(height: 14),
                      _Campo(
                        label: 'Dirección *',
                        controller: _direccionCtrl,
                        icon: Icons.location_on_outlined,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'La dirección es obligatoria' : null,
                      ),
                      const SizedBox(height: 14),

                      // Sector (dropdown)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.colorInputFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.colorCardBorder, width: 0.5),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sector,
                            dropdownColor: context.colorDropdownBg,
                            iconEnabledColor: context.colorOnSurfaceDim,
                            style: TextStyle(color: context.colorOnSurface, fontSize: 15),
                            items: _sectores
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) => setState(() => _sector = v ?? _sector),
                            hint: Text(
                              'Sector de Quito *',
                              style: TextStyle(color: context.colorOnSurfaceDim),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _Campo(
                        label: 'Teléfono',
                        controller: _telefonoCtrl,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                      _Campo(
                        label: 'Horario (ej: Lun-Sáb 8:00-18:00)',
                        controller: _horarioCtrl,
                        icon: Icons.schedule_outlined,
                      ),
                      const SizedBox(height: 14),
                      _Campo(
                        label: 'Descripción',
                        controller: _descripcionCtrl,
                        icon: Icons.info_outline,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 28),

                      PrimaryButton(
                        label: provider.ferreteria == null
                            ? 'Registrar ferretería'
                            : 'Guardar cambios',
                        isLoading: provider.guardando,
                        onPressed: _guardar,
                      ),

                      // ── Catálogo de precios ─────────────────────────────
                      if (provider.ferreteria != null) ...[
                        const SizedBox(height: 36),
                        const Divider(color: AppColors.glassBorder),
                        const SizedBox(height: 20),
                        Text(
                          'Catálogo de precios',
                          style: TextStyle(
                            color: context.colorOnSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sube un archivo .csv con todos tus precios de una vez.',
                          style: TextStyle(color: context.colorOnSurfaceDim, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        // Ejemplo de formato
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.glassWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.glassBorder, width: 0.5),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Formato del archivo:',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'material,precio,unidad,categoria\n'
                                'Cemento Portland 50kg,8.50,saco,Cementos\n'
                                'Bloque pómez 10cm,0.45,unidad,Bloques\n'
                                'Varilla corrugada 12mm,18.00,varilla,Acero',
                                style: TextStyle(
                                  color: AppColors.priceColor,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: provider.importandoCatalogo ? null : _subirCatalogo,
                          icon: provider.importandoCatalogo
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                )
                              : const Icon(Icons.upload_file_outlined),
                          label: Text(provider.importandoCatalogo ? 'Importando...' : 'Seleccionar archivo .csv'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _Campo({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: context.colorOnSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: context.colorOnSurfaceDim, fontSize: 14),
        prefixIcon: Icon(icon, color: context.colorOnSurfaceDim, size: 20),
        filled: true,
        fillColor: context.colorInputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colorCardBorder, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colorCardBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      validator: validator,
    );
  }
}
