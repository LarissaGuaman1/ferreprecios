import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_components.dart';
import '../../../core/navigation/main_shell.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    // Si el Form tiene algún campo inválido, no seguimos.
    if (!_formKey.currentState!.validate()) return;

    // "read" en vez de "watch": solo necesitamos llamar a login() una
    // vez, no nos interesa reconstruir esta función cuando cambie el estado.
    final authProvider = context.read<AuthProvider>();
    final exito = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    // Después de un "await", el widget pudo haber sido removido de la
    // pantalla (ej: el usuario navegó a otro lado mientras esperaba).
    // "mounted" confirma que el widget todavía existe antes de usar su context.
    if (!mounted) return;

    if (exito) {
      // pushReplacement en vez de push: así el botón "atrás" del
      // celular no regresa al Login una vez que ya iniciaste sesión.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  Future<void> _irARegistro() async {
    final cuentaCreada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    if (cuentaCreada == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada! Ahora ingresa tu correo y contraseña.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // "watch" SÍ suscribe esta pantalla a reconstruirse cuando
    // AuthProvider llame notifyListeners() (ej: al cambiar isLoading).
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset('assets/images/logo.png', height: 160),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'FerrePrecios Quito',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: context.colorOnSurface,
                      ),
                    ),
                    Text(
                      'Compara precios de materiales en Quito',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colorOnSurfaceDim),
                    ),
                    const SizedBox(height: 32),
                    AuthTextField(
                      label: 'Correo electrónico',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Ingresa tu correo';
                        if (!value.contains('@')) return 'Correo no válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Contraseña',
                      controller: _passwordController,
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Ingresa tu contraseña';
                        if (value.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    // Solo se muestra si el provider tiene un mensaje de error
                    // guardado (ej: el backend respondió "credenciales inválidas").
                    if (authProvider.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        authProvider.errorMessage!,
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Iniciar sesión',
                      isLoading: authProvider.isLoading,
                      onPressed: _iniciarSesion,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _irARegistro,
                      child: const Text('¿No tienes cuenta? Regístrate'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
