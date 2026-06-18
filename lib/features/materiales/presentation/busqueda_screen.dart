import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_components.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../perfil/presentation/perfil_screen.dart';
import '../../reportes/presentation/reportar_precio_screen.dart';
import '../providers/material_provider.dart';
import 'detalle_material_screen.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({super.key});

  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  final _searchController = TextEditingController();

  // Los sectores que se muestran como filtro. "null" representa
  // "Todos" (sin filtrar).
  static const List<String?> _sectores = [null, 'Norte', 'Sur', 'Centro', 'Valles'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialProvider>().buscar();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _cerrarSesion() {
    context.read<AuthProvider>().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _irA(Widget pantalla) {
    Navigator.pop(context); // cierra el drawer antes de navegar
    Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
  }

  void _mostrarAcercaDe() {
    Navigator.pop(context);
    showAboutDialog(
      context: context,
      applicationName: 'FerrePrecios Quito',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.storefront, color: AppColors.primary),
      children: const [
        SizedBox(height: 12),
        Text('Comparación colaborativa de precios de materiales de construcción en Quito.'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final materialProvider = context.watch<MaterialProvider>();

    return Scaffold(
      // PreferredSize + Container es el patrón que SÍ funciona en Flutter
      // para personalizar el AppBar más allá de sus colores básicos
      // (flexibleSpace no pinta de forma confiable en un AppBar normal).
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0x26FFFFFF), width: 0.5)),
          ),
          child: AppBar(title: const Text('Buscar materiales')),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF0D1F16),
        shape: const RoundedRectangleBorder(),
        child: DecoratedBox(
          // Borde derecho de 0.5px blanco 15%, pedido en la spec.
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: Color(0x26FFFFFF), width: 0.5)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _CabeceraDrawer(
                  nombre: context.watch<AuthProvider>().nombreUsuario ?? 'FerrePrecios Quito',
                  correo: context.watch<AuthProvider>().emailUsuario,
                  fotoUrl: context.watch<AuthProvider>().fotoUrlUsuario,
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.home_outlined, color: Color(0xB3FFFFFF)),
                  title: const Text('Inicio', style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.add_a_photo_outlined, color: Color(0xB3FFFFFF)),
                  title: const Text('Reportar precio', style: TextStyle(color: Colors.white)),
                  onTap: () => _irA(const ReportarPrecioScreen()),
                ),
                ListTile(
                  leading: const Icon(Icons.map_outlined, color: Color(0xB3FFFFFF)),
                  title: const Text('Mapa', style: TextStyle(color: Colors.white)),
                  onTap: () => _irA(const ProximamenteScreen(titulo: 'Mapa', icono: Icons.map_outlined)),
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline, color: Color(0xB3FFFFFF)),
                  title: const Text('Perfil', style: TextStyle(color: Colors.white)),
                  onTap: () => _irA(const PerfilScreen()),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Color(0xB3FFFFFF)),
                  title: const Text('Acerca de', style: TextStyle(color: Colors.white)),
                  onTap: _mostrarAcercaDe,
                ),
                const Spacer(),
                const Divider(color: Color(0x26FFFFFF), height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Color(0xB3FFFFFF)),
                  title: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
                  onTap: _cerrarSesion,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      body: AppBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Ej: cemento, varilla, pintura...',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (texto) => context.read<MaterialProvider>().buscar(texto: texto),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _sectores.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final sector = _sectores[index];
                  final seleccionado = materialProvider.sectorSeleccionado == sector;

                  return ChoiceChip(
                    label: Text(sector ?? 'Todos'),
                    labelStyle: TextStyle(
                      color: seleccionado ? Colors.white : const Color(0x80FFFFFF),
                      fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
                    ),
                    selected: seleccionado,
                    backgroundColor: const Color(0x0DFFFFFF),
                    selectedColor: AppColors.tealGlass,
                    side: BorderSide(
                      color: seleccionado ? const Color(0x991D9E75) : const Color(0x26FFFFFF),
                      width: 0.5,
                    ),
                    onSelected: (_) => context.read<MaterialProvider>().cambiarSector(sector),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildResultados(materialProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultados(MaterialProvider materialProvider) {
    if (materialProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (materialProvider.errorMessage != null) {
      return Center(
        child: Text(materialProvider.errorMessage!, style: const TextStyle(color: AppColors.error)),
      );
    }

    if (materialProvider.resultados.isEmpty) {
      return const Center(
        child: Text('No se encontraron materiales', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: materialProvider.resultados.length,
      itemBuilder: (context, index) {
        final material = materialProvider.resultados[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetalleMaterialScreen(materialId: material.id, nombre: material.nombre),
                  ),
                );
              },
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${material.categoria} · ${material.unidadMedida}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  material.mejorPrecio == null
                      ? const Text('Sin precios', style: TextStyle(color: AppColors.textSecondary))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${material.mejorPrecio!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.priceColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            EstadoBadge(estado: material.estado!),
                          ],
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Cabecera del drawer: avatar circular, nombre del usuario y su correo,
// sobre el degradado verde de la marca (mismo patrón que la captura de
// referencia, con los colores propios de FerrePrecios).
class _CabeceraDrawer extends StatelessWidget {
  final String nombre;
  final String? correo;
  final String? fotoUrl;

  const _CabeceraDrawer({required this.nombre, required this.correo, required this.fotoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl!) : null,
            child: fotoUrl == null ? const Icon(Icons.storefront, size: 28, color: AppColors.primary) : null,
          ),
          const SizedBox(height: 12),
          Text(
            nombre,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (correo != null) ...[
            const SizedBox(height: 2),
            Text(correo!, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 12)),
          ],
        ],
      ),
    );
  }
}
