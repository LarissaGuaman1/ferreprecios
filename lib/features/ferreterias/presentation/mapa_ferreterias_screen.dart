import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../data/ferreteria_modelo.dart';
import '../providers/lista_ferreterias_provider.dart';

class MapaFerreteriasScreen extends StatefulWidget {
  const MapaFerreteriasScreen({super.key});

  @override
  State<MapaFerreteriasScreen> createState() => _MapaFerreteriasScreenState();
}

class _MapaFerreteriasScreenState extends State<MapaFerreteriasScreen> {
  final _mapController = MapController();
  FerreteriaModelo? _seleccionada;

  // Centro aproximado de Quito
  static const _centroQuito = LatLng(-0.1807, -78.4678);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ListaFerreteriasProvider>();
      if (provider.ferreterias.isEmpty && !provider.isLoading) {
        provider.cargar();
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _mostrarInfo(FerreteriaModelo f) {
    setState(() => _seleccionada = f);
  }

  void _cerrarInfo() {
    setState(() => _seleccionada = null);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListaFerreteriasProvider>();
    final conUbicacion = provider.ferreterias.where((f) => f.tieneUbicacion).toList();

    return Scaffold(
      backgroundColor: context.colorNavBg,
      appBar: AppBar(
        backgroundColor: context.colorNavBg,
        foregroundColor: context.colorOnSurface,
        title: const Text('Mapa de Ferreterías'),
        actions: [
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centroQuito,
              initialZoom: 11.5,
              onTap: (_, __) => _cerrarInfo(),
            ),
            children: [
              TileLayer(
                urlTemplate: context.isDark
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'ec.ferreprecios.app',
                retinaMode: RetinaMode.isHighDensity(context),
              ),
              MarkerLayer(
                markers: conUbicacion.map((f) {
                  final esSeleccionada = _seleccionada?.id == f.id;
                  final color = AppColors.sector(f.sector);
                  return Marker(
                    point: LatLng(f.lat!, f.lng!),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _mostrarInfo(f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: esSeleccionada ? color : color.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: esSeleccionada ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: esSeleccionada ? 12 : 6,
                              spreadRadius: esSeleccionada ? 2 : 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.store,
                          color: Colors.white,
                          size: esSeleccionada ? 22 : 18,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Panel info ferretería seleccionada
          if (_seleccionada != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: _TarjetaInfoMapa(
                ferreteria: _seleccionada!,
                onCerrar: _cerrarInfo,
                onCentrar: () => _mapController.move(
                  LatLng(_seleccionada!.lat!, _seleccionada!.lng!),
                  14,
                ),
              ),
            ),

          // Contador de tiendas en el mapa
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.colorNavBg.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colorCardBorder, width: 0.5),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
              ),
              child: Text(
                '${conUbicacion.length} ferreterías',
                style: TextStyle(color: context.colorOnSurfaceDim, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaInfoMapa extends StatelessWidget {
  final FerreteriaModelo ferreteria;
  final VoidCallback onCerrar;
  final VoidCallback onCentrar;

  const _TarjetaInfoMapa({
    required this.ferreteria,
    required this.onCerrar,
    required this.onCentrar,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.sector(ferreteria.sector);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colorNavBg.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colorCardBorder, width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ferreteria.nombre,
                  style: TextStyle(
                    color: context.colorOnSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
                ),
                child: Text(
                  ferreteria.sector,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onCerrar,
                child: const Icon(Icons.close, color: Colors.white54, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Fila(icon: Icons.location_on_outlined, texto: ferreteria.direccion),
          if (ferreteria.horario != null) _Fila(icon: Icons.schedule_outlined, texto: ferreteria.horario!),
          if (ferreteria.telefono != null) _Fila(icon: Icons.phone_outlined, texto: ferreteria.telefono!),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onCentrar,
              icon: const Icon(Icons.my_location, size: 16),
              label: const Text('Centrar en mapa'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _Fila({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: context.colorOnSurfaceDim),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(color: context.colorOnSurfaceDim, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
