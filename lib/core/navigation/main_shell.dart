import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_components.dart';
import '../../features/materiales/presentation/busqueda_screen.dart';
import '../../features/perfil/presentation/perfil_screen.dart';
import '../../features/reportes/presentation/reportar_precio_screen.dart';

// Punto de entrada principal de la app después del login: una barra
// inferior con las 4 secciones del MVP. Buscador, Reporte y Perfil ya
// son reales; Mapa sigue como placeholder hasta que tengamos la API
// key de Google Maps.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _indiceActual = 0;

  // IndexedStack mantiene viva cada pestaña en memoria (no la destruye
  // al cambiar de tab), así no se pierde el scroll ni la búsqueda
  // escrita si el usuario va y vuelve.
  static const List<Widget> _pestanas = [
    BusquedaScreen(),
    ProximamenteScreen(titulo: 'Mapa', icono: Icons.map_outlined),
    ReportarPrecioScreen(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indiceActual, children: _pestanas),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0A1628),
          border: Border(top: BorderSide(color: Color(0x1AFFFFFF), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _indiceActual,
          onTap: (index) => setState(() => _indiceActual = index),
          backgroundColor: Colors.transparent,
          // BottomNavigationBar necesita estos dos colores explícitos;
          // si no, usa los valores por defecto del tema (pensados para
          // fondo claro) y los íconos inactivos casi no se verían.
          selectedItemColor: AppColors.primary,
          unselectedItemColor: const Color(0x4DFFFFFF),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Mapa'),
            BottomNavigationBarItem(icon: Icon(Icons.add_a_photo_outlined), label: 'Reportar'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}
