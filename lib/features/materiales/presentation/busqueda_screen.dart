import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_components.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../perfil/presentation/perfil_screen.dart';
import '../../ferreterias/presentation/mapa_ferreterias_screen.dart';
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
      applicationIcon: Image.asset('assets/images/logo.png', height: 56),
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
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.colorAppBarBorder, width: 0.5)),
          ),
          child: AppBar(title: const Text('Buscar materiales')),
        ),
      ),
      drawer: Drawer(
        backgroundColor: context.colorSurfaceBg,
        shape: const RoundedRectangleBorder(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: context.colorAppBarBorder, width: 0.5)),
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
                  leading: Icon(Icons.home_outlined, color: context.colorIconSecondary),
                  title: Text('Inicio', style: TextStyle(color: context.colorOnSurface)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Icon(Icons.add_a_photo_outlined, color: context.colorIconSecondary),
                  title: Text('Reportar precio', style: TextStyle(color: context.colorOnSurface)),
                  onTap: () => _irA(const ReportarPrecioScreen()),
                ),
                ListTile(
                  leading: Icon(Icons.map_outlined, color: context.colorIconSecondary),
                  title: Text('Mapa', style: TextStyle(color: context.colorOnSurface)),
                  onTap: () => _irA(const MapaFerreteriasScreen()),
                ),
                ListTile(
                  leading: Icon(Icons.person_outline, color: context.colorIconSecondary),
                  title: Text('Perfil', style: TextStyle(color: context.colorOnSurface)),
                  onTap: () => _irA(const PerfilScreen()),
                ),
                ListTile(
                  leading: Icon(Icons.info_outline, color: context.colorIconSecondary),
                  title: Text('Acerca de', style: TextStyle(color: context.colorOnSurface)),
                  onTap: _mostrarAcercaDe,
                ),
                ListTile(
                  leading: Icon(
                    context.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    color: context.colorIconSecondary,
                  ),
                  title: Text(
                    context.isDark ? 'Modo claro' : 'Modo oscuro',
                    style: TextStyle(color: context.colorOnSurface),
                  ),
                  onTap: () => context.read<ThemeProvider>().toggle(),
                ),
                const Spacer(),
                Divider(color: context.colorAppBarBorder, height: 1),
                ListTile(
                  leading: Icon(Icons.logout, color: context.colorIconSecondary),
                  title: Text('Cerrar sesión', style: TextStyle(color: context.colorOnSurface)),
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
                      color: seleccionado ? Colors.white : context.colorChipUnselectedText,
                      fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
                    ),
                    selected: seleccionado,
                    backgroundColor: context.colorChipUnselectedBg,
                    selectedColor: AppColors.tealGlass,
                    side: BorderSide(
                      color: seleccionado ? const Color(0x991D9E75) : context.colorAppBarBorder,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl!) : null,
                child: fotoUrl == null ? const Icon(Icons.person, size: 28, color: AppColors.primary) : null,
              ),
              Image.asset('assets/images/logo.png', height: 44),
            ],
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
