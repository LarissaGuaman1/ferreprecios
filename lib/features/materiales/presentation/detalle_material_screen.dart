import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_components.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/material_repository.dart';
import '../data/precio_reportado.dart';

class DetalleMaterialScreen extends StatefulWidget {
  final String materialId;
  final String nombre;

  const DetalleMaterialScreen({super.key, required this.materialId, required this.nombre});

  @override
  State<DetalleMaterialScreen> createState() => _DetalleMaterialScreenState();
}

class _DetalleMaterialScreenState extends State<DetalleMaterialScreen> {
  late Future<List<PrecioReportado>> _futurePrecios;

  @override
  void initState() {
    super.initState();
    _futurePrecios = MaterialRepository().obtenerPrecios(widget.materialId);
  }

  void _recargar() {
    setState(() {
      _futurePrecios = MaterialRepository().obtenerPrecios(widget.materialId);
    });
  }

  void _verFoto(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarEliminar(String reporteId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar reporte'),
        content: const Text('¿Seguro? Perderás los puntos ganados por este reporte.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    try {
      await ApiService.instance.delete('/reportes/$reporteId');
      if (!mounted) return;
      _recargar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarioId = context.read<AuthProvider>().usuarioId;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.colorAppBarBorder, width: 0.5)),
          ),
          child: AppBar(title: Text(widget.nombre)),
        ),
      ),
      body: AppBackground(
        child: FutureBuilder<List<PrecioReportado>>(
          future: _futurePrecios,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('No se pudo conectar al servidor', style: TextStyle(color: AppColors.error)),
              );
            }

            final precios = snapshot.data!;
            if (precios.isEmpty) {
              return Center(
                child: Text(
                  'Nadie ha reportado un precio para este material todavía',
                  style: TextStyle(color: context.colorOnSurfaceDim),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: precios.length,
              itemBuilder: (context, index) {
                final precio = precios[index];
                final esElMasBarato = index == 0;
                final esMio = usuarioId != null && precio.usuarioId == usuarioId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    destacado: esElMasBarato,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Icon(
                                  esElMasBarato ? Icons.emoji_events : Icons.storefront,
                                  color: esElMasBarato ? AppColors.priceColor : context.colorOnSurfaceDim,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      precio.ferreteriaNombre,
                                      style: TextStyle(
                                        color: context.colorOnSurface,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      precio.ferreteriaDireccion,
                                      style: TextStyle(color: context.colorOnSurfaceDim, fontSize: 12),
                                    ),
                                    if (precio.marca != null) ...[
                                      const SizedBox(height: 5),
                                      Row(children: [
                                        const Icon(Icons.label_outline, size: 13, color: AppColors.priceColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          precio.marca!,
                                          style: const TextStyle(
                                            color: AppColors.priceColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ]),
                                    ],
                                    if (precio.caracteristicas != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        precio.caracteristicas!,
                                        style: TextStyle(color: context.colorOnSurfaceDim, fontSize: 11),
                                      ),
                                    ],
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.sector(precio.ferreteriaSector).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            precio.ferreteriaSector,
                                            style: TextStyle(
                                              color: context.colorOnSurfaceDim,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        EstadoBadge(estado: precio.estado),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${precio.valor.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: esElMasBarato ? AppColors.priceColor : context.colorOnSurface,
                                    ),
                                  ),
                                  if (esMio)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      tooltip: 'Eliminar mi reporte',
                                      onPressed: () => _confirmarEliminar(precio.id),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (precio.fotoUrl != null)
                          GestureDetector(
                            onTap: () => _verFoto(precio.fotoUrl!),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                              child: Image.network(
                                precio.fotoUrl!,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, progress) {
                                  if (progress == null) return child;
                                  return SizedBox(
                                    height: 180,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        value: progress.expectedTotalBytes != null
                                            ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
