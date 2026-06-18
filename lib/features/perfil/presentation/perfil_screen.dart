import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_components.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/perfil_provider.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PerfilProvider>().cargarPerfil();
    });
  }

  Future<void> _elegirFoto() async {
    // showModalBottomSheet abre un menú que sube desde abajo, con las
    // dos formas de conseguir una foto: cámara o galería.
    final origen = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF0D1F16),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Colors.white),
              title: const Text('Cámara', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Colors.white),
              title: const Text('Galería', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
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

    final error = await context.read<PerfilProvider>().actualizarFoto(bytes, archivo.name);
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    // Avisamos a AuthProvider para que el drawer (que muestra su
    // propia copia del nombre/foto) también se actualice.
    final nuevaFotoUrl = context.read<PerfilProvider>().perfil?.fotoUrl;
    if (nuevaFotoUrl != null) {
      context.read<AuthProvider>().actualizarFoto(nuevaFotoUrl);
    }
  }

  void _cerrarSesion() {
    context.read<AuthProvider>().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PerfilProvider>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0x26FFFFFF), width: 0.5)),
          ),
          child: AppBar(title: const Text('Mi perfil')),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: _construirContenido(provider),
        ),
      ),
    );
  }

  Widget _construirContenido(PerfilProvider provider) {
    if (provider.isLoading && provider.perfil == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.perfil == null) {
      return Center(
        child: Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
      );
    }

    final perfil = provider.perfil!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: provider.actualizandoFoto ? null : _elegirFoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.tealGlass,
                      backgroundImage: perfil.fotoUrl != null ? NetworkImage(perfil.fotoUrl!) : null,
                      child: provider.actualizandoFoto
                          ? const CircularProgressIndicator(color: Colors.white)
                          : perfil.fotoUrl == null
                              ? Text(
                                  perfil.nombre.isNotEmpty ? perfil.nombre[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
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
              const SizedBox(height: 12),
              Text(
                perfil.nombre,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(perfil.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _TarjetaEstadistica(
                icono: Icons.star_outline,
                valor: '${perfil.puntos}',
                etiqueta: 'Puntos',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TarjetaEstadistica(
                icono: Icons.fact_check_outlined,
                valor: '${perfil.totalReportes}',
                etiqueta: 'Reportes',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 10),
              Text(
                'Miembro desde ${_formatearFecha(perfil.miembroDesde)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: _cerrarSesion,
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  String _formatearFecha(DateTime fecha) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }
}

// Tarjeta chiquita para un número destacado (puntos, reportes, etc.),
// reutilizando GlassCard para mantener el mismo estilo que el resto de la app.
class _TarjetaEstadistica extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String etiqueta;

  const _TarjetaEstadistica({required this.icono, required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Icon(icono, color: AppColors.priceColor, size: 22),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(etiqueta, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
