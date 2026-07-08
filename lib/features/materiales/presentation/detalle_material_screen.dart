import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_components.dart';
import '../data/material_repository.dart';
import '../data/precio_reportado.dart';

class DetalleMaterialScreen extends StatelessWidget {
  final String materialId;
  final String nombre;

  const DetalleMaterialScreen({super.key, required this.materialId, required this.nombre});

  void _verFoto(BuildContext context, String url) {
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

  @override
  Widget build(BuildContext context) {
    final repository = MaterialRepository();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.colorAppBarBorder, width: 0.5)),
          ),
          child: AppBar(title: Text(nombre)),
        ),
      ),
      body: AppBackground(
        child: FutureBuilder<List<PrecioReportado>>(
          future: repository.obtenerPrecios(materialId),
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
              return const Center(
                child: Text(
                  'Nadie ha reportado un precio para este material todavía',
                  style: TextStyle(color: AppColors.textSecondary),
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
                                  color: esElMasBarato ? AppColors.priceColor : const Color(0x99FFFFFF),
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
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
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
                                            style: const TextStyle(
                                              color: Color(0x59FFFFFF),
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
                              Text(
                                '\$${precio.valor.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: esElMasBarato ? AppColors.priceColor : context.colorOnSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (precio.fotoUrl != null)
                          GestureDetector(
                            onTap: () => _verFoto(context, precio.fotoUrl!),
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
