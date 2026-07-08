import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_components.dart';
import '../providers/auth_provider.dart';
import 'widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();
  final _picker = ImagePicker();

  // Todavía no hay cuenta (ni token) mientras se completa este
  // formulario, así que la foto se queda en memoria y se sube recién
  // después de que el registro sea exitoso.
  Uint8List? _fotoBytes;
  String? _fotoNombre;
  String _rol = 'comprador';

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    final origen = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.colorSurfaceBg,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: ctx.colorOnSurface),
              title: Text('Cámara', style: TextStyle(color: ctx.colorOnSurface)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: ctx.colorOnSurface),
              title: Text('Galería', style: TextStyle(color: ctx.colorOnSurface)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (origen == null) return;

    final archivo = await _picker.pickImage(source: origen, imageQuality: 80);
    if (archivo == null) return;

    final bytes = await archivo.readAsBytes();
    if (!mounted) return;
    setState(() {
      _fotoBytes = bytes;
      _fotoNombre = archivo.name;
    });
  }

  Future<void> _crearCuenta() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final exito = await authProvider.register(
      _nombreController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      rol: _rol,
      fotoBytes: _fotoBytes,
      fotoNombre: _fotoNombre,
    );

    if (!mounted) return;

    if (exito) {
      // Limpiamos la sesión que el backend devolvió automáticamente:
      // el usuario debe iniciar sesión de forma explícita.
      context.read<AuthProvider>().logout();
      if (!mounted) return;
      // Pasamos "true" al login para que muestre el mensaje de éxito.
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.colorAppBarBorder, width: 0.5)),
          ),
          child: AppBar(title: const Text('Crear cuenta')),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Selector de tipo de cuenta
                  Text(
                    'Tipo de cuenta',
                    style: TextStyle(color: context.colorOnSurfaceDim, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _SelectorRol(
                          icon: Icons.person_outline,
                          titulo: 'Comprador',
                          subtitulo: 'Busco los mejores precios',
                          seleccionado: _rol == 'comprador',
                          onTap: () => setState(() => _rol = 'comprador'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SelectorRol(
                          icon: Icons.storefront_outlined,
                          titulo: 'Ferretería',
                          subtitulo: 'Gestiono mi tienda',
                          seleccionado: _rol == 'ferreteria',
                          onTap: () => setState(() => _rol = 'ferreteria'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: _elegirFoto,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.tealGlass,
                            backgroundImage: _fotoBytes != null ? MemoryImage(_fotoBytes!) : null,
                            child: _fotoBytes == null
                                ? const Icon(Icons.person_outline, size: 36, color: Colors.white)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _fotoBytes == null ? 'Agrega una foto (opcional)' : 'Foto seleccionada',
                      style: TextStyle(color: context.colorOnSurfaceDim, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    label: 'Nombre completo',
                    controller: _nombreController,
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Ingresa tu nombre';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                        return 'Ingresa una contraseña';
                      if (value.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    label: 'Confirmar contraseña',
                    controller: _confirmarPasswordController,
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) {
                      if (value != _passwordController.text)
                        return 'Las contraseñas no coinciden';
                      return null;
                    },
                  ),
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
                    label: 'Crear cuenta',
                    isLoading: authProvider.isLoading,
                    onPressed: _crearCuenta,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectorRol extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final bool seleccionado;
  final VoidCallback onTap;

  const _SelectorRol({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.tealGlass : context.colorCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? AppColors.primary : context.colorCardBorder,
            width: seleccionado ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: seleccionado ? AppColors.primary : context.colorOnSurfaceDim,
            ),
            const SizedBox(height: 6),
            Text(
              titulo,
              style: TextStyle(
                color: seleccionado ? Colors.white : context.colorOnSurfaceDim,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colorOnSurfaceDim, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
