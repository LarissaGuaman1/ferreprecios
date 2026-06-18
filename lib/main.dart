import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/materiales/providers/material_provider.dart';
import 'features/perfil/providers/perfil_provider.dart';
import 'features/reportes/providers/reporte_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider registra varios ChangeNotifier a la vez. Cada
    // pantalla descendiente puede pedir el que necesite con
    // context.watch/read<TipoDeProvider>().
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MaterialProvider()),
        ChangeNotifierProvider(create: (_) => ReporteProvider()),
        ChangeNotifierProvider(create: (_) => PerfilProvider()),
      ],
      child: MaterialApp(
        title: 'FerrePrecios Quito',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
