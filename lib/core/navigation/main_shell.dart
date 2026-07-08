import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/materiales/presentation/busqueda_screen.dart';
import '../../features/perfil/presentation/perfil_screen.dart';
import '../../features/reportes/presentation/reportar_precio_screen.dart';
import '../../features/ferreterias/presentation/lista_ferreterias_screen.dart';
import '../../features/ferreterias/presentation/mi_ferreteria_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _indiceActual = 0;

  @override
  Widget build(BuildContext context) {
    final esDueno = context.watch<AuthProvider>().esDueno;

    // Tab 2 cambia según el rol: dueños gestionan su tienda,
    // compradores reportan precios.
    final pestanas = [
      const BusquedaScreen(),
      const ListaFerreteriasScreen(),
      esDueno ? const MiFerreteriaScreen() : const ReportarPrecioScreen(),
      const PerfilScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _indiceActual, children: pestanas),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.colorNavBg,
          border: Border(top: BorderSide(color: context.colorNavBorder, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _indiceActual,
          onTap: (index) => setState(() => _indiceActual = index),
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: context.colorNavUnselected,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Buscar',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.store_outlined),
              label: 'Ferreterías',
            ),
            BottomNavigationBarItem(
              icon: Icon(esDueno ? Icons.storefront_outlined : Icons.add_a_photo_outlined),
              label: esDueno ? 'Mi Tienda' : 'Reportar',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
