import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_components.dart';
import '../data/ferreteria_modelo.dart';
import '../providers/lista_ferreterias_provider.dart';
import 'mapa_ferreterias_screen.dart';

class ListaFerreteriasScreen extends StatefulWidget {
  const ListaFerreteriasScreen({super.key});

  @override
  State<ListaFerreteriasScreen> createState() => _ListaFerreteriasScreenState();
}

class _ListaFerreteriasScreenState extends State<ListaFerreteriasScreen> {
  final _busquedaController = TextEditingController();
  String _termino = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListaFerreteriasProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListaFerreteriasProvider>();

    final filtradas = provider.ferreterias.where((f) {
      if (_termino.isEmpty) return true;
      final t = _termino.toLowerCase();
      return f.nombre.toLowerCase().contains(t) ||
          f.direccion.toLowerCase().contains(t) ||
          f.sector.toLowerCase().contains(t);
    }).toList();

    return AppBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Encabezado
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.store_outlined, color: AppColors.primary, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ferreterías',
                      style: TextStyle(
                        color: context.colorOnSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.map_outlined, color: AppColors.primary),
                    tooltip: 'Ver en mapa',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MapaFerreteriasScreen()),
                    ),
                  ),
                  if (provider.isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                      onPressed: () => context.read<ListaFerreteriasProvider>().cargar(),
                    ),
                ],
              ),
            ),
            // Buscador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _busquedaController,
                style: TextStyle(color: context.colorOnSurface),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, sector…',
                  hintStyle: TextStyle(color: context.colorOnSurfaceDim),
                  prefixIcon: Icon(Icons.search, color: context.colorOnSurfaceDim),
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (v) => setState(() => _termino = v.trim()),
              ),
            ),
            const SizedBox(height: 12),
            // Lista
            Expanded(
              child: provider.errorMessage != null
                  ? Center(
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : filtradas.isEmpty && !provider.isLoading
                      ? const Center(
                          child: Text(
                            'No se encontraron ferreterías',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: filtradas.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => _TarjetaFerreteria(ferreteria: filtradas[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaFerreteria extends StatelessWidget {
  final FerreteriaModelo ferreteria;

  const _TarjetaFerreteria({required this.ferreteria});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.sector(ferreteria.sector);

    return GlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto o placeholder
          if (ferreteria.fotoUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Image.network(
                ferreteria.fotoUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _PlaceholderFoto(),
              ),
            )
          else
            const _PlaceholderFoto(),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ferreteria.nombre,
                        style: TextStyle(
                          color: context.colorOnSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Badge sector
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
                    if (ferreteria.tieneDueno) ...[
                      const SizedBox(width: 6),
                      Tooltip(
                        message: 'Ferretería registrada por su dueño',
                        child: Icon(Icons.verified, color: AppColors.priceColor, size: 16),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                _InfoFila(icon: Icons.location_on_outlined, texto: ferreteria.direccion),
                if (ferreteria.telefono != null)
                  _InfoFila(icon: Icons.phone_outlined, texto: ferreteria.telefono!),
                if (ferreteria.horario != null)
                  _InfoFila(icon: Icons.schedule_outlined, texto: ferreteria.horario!),
                if (ferreteria.descripcion != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    ferreteria.descripcion!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderFoto extends StatelessWidget {
  const _PlaceholderFoto();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: const Icon(Icons.store_outlined, size: 40, color: AppColors.textSecondary),
    );
  }
}

class _InfoFila extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _InfoFila({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
