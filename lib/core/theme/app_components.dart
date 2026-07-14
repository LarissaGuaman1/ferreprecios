import 'package:flutter/material.dart';

import 'app_colors.dart';

// Botón principal reutilizable en toda la app (login, registro,
// reportar precio, guardar perfil, etc.).
//
// No le definimos color ni forma aquí: ElevatedButton ya toma esos
// valores automáticamente del "elevatedButtonTheme" que configuramos
// en app_theme.dart. Este widget solo agrega el comportamiento de
// "loading" que cualquier botón conectado a una API va a necesitar.
class PrimaryButton extends StatelessWidget {
  // Texto que se muestra dentro del botón (ej: "Iniciar sesión").
  final String label;

  // Función que se ejecuta al presionar. Si la pasas como null,
  // Flutter deshabilita el botón automáticamente (se ve gris y no
  // responde al toque).
  final VoidCallback? onPressed;

  // Mientras esperamos la respuesta del backend, ponemos esto en true
  // para mostrar un ícono de carga en vez del texto.
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // Si está cargando, pasamos "null" para bloquear el botón aunque
      // el padre sí nos haya dado una función válida en onPressed.
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.surface,
              ),
            )
          : Text(label),
    );
  }
}

// Etiqueta pequeña que muestra la confiabilidad de un precio
// ("reciente", "verificado", "desactualizado"), calculada por el backend.
class EstadoBadge extends StatelessWidget {
  final String estado;

  const EstadoBadge({super.key, required this.estado});

  // Un color y un texto distinto para cada uno de los 3 estados
  // posibles. "default" cubre "desactualizado" y cualquier valor
  // inesperado, para que el widget nunca se rompa por un dato raro.
  // Uso priceColor/primary (claros) en vez de primaryDark: con el
  // fondo oscuro nuevo, un verde muy oscuro como texto sería ilegible.
  Color get _color {
    switch (estado) {
      case 'verificado':
        return AppColors.priceColor;
      case 'reciente':
        return AppColors.primary;
      default:
        return AppColors.warning;
    }
  }

  String get _texto {
    switch (estado) {
      case 'verificado':
        return 'Verificado';
      case 'reciente':
        return 'Reciente';
      default:
        return 'Desactualizado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _texto,
        style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.isDark
        ? const [AppColors.bgGrad1, AppColors.bgGrad2, AppColors.bgGrad3]
        : const [Color(0xFFF0F7F4), Color(0xFFF5F9F7), Color(0xFFECF4FF)];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final bool destacado;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.child,
    this.destacado = false,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: destacado
            ? const Color(0x331D9E75)
            : (dark ? AppColors.glassWhite : Colors.white),
        border: Border.all(
          color: destacado
              ? const Color(0x991D9E75)
              : (dark ? AppColors.glassBorder : const Color(0xFFDCEDE6)),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: dark
            ? null
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}

// Placeholder simple para pestañas del bottom nav que todavía no
// tienen pantalla real (Mapa, Reportar, Perfil). Se reemplaza por la
// pantalla de verdad a medida que avancemos en el roadmap del MVP.
class ProximamenteScreen extends StatelessWidget {
  final String titulo;
  final IconData icono;

  const ProximamenteScreen({super.key, required this.titulo, required this.icono});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 48, color: context.colorOnSurfaceDim),
              const SizedBox(height: 12),
              Text(
                '$titulo — Próximamente',
                style: TextStyle(color: context.colorOnSurfaceDim, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
