import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_components.dart';
import '../data/material_repository.dart';
import '../data/precio_reportado.dart';

// Esta pantalla solo necesita cargar datos UNA vez al abrirse, y nadie
// más en la app necesita esos datos. Por eso no usamos un Provider:
// basta con un FutureBuilder directo sobre el repositorio.
class DetalleMaterialScreen extends StatelessWidget {
  final String materialId;
  final String nombre;

  const DetalleMaterialScreen({super.key, required this.materialId, required this.nombre});

  @override
  Widget build(BuildContext context) {
    final repository = MaterialRepository();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0x26FFFFFF), width: 0.5)),
          ),
          child: AppBar(title: Text(nombre)),
        ),
      ),
      body: AppBackground(
        // FutureBuilder reconstruye la pantalla automáticamente cuando
        // el Future (la petición HTTP) termina, sin que tengamos que
        // manejar setState ni isLoading a mano.
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
                // El backend ya los manda ordenados de menor a mayor,
                // así que el índice 0 siempre es el más barato.
                final esElMasBarato = index == 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    destacado: esElMasBarato,
                    child: Row(
                      children: [
                        Icon(
                          esElMasBarato ? Icons.emoji_events : Icons.storefront,
                          color: esElMasBarato ? AppColors.priceColor : const Color(0x99FFFFFF),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                precio.ferreteriaNombre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                precio.ferreteriaDireccion,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
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
                                      // Labels de sector: blanco 35% opacidad sobre el
                                      // color de fondo del sector (ya translúcido).
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
                        Text(
                          '\$${precio.valor.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: esElMasBarato ? AppColors.priceColor : Colors.white,
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
