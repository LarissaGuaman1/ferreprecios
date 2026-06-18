import 'package:flutter/material.dart';

import 'app_colors.dart';

// Guarda todos los estilos de texto de la app en un solo lugar,
// igual que AppColors hace con los colores.
class AppTextStyles {
  // Constructor privado: esta clase es solo una caja de constantes,
  // no se debe crear un objeto de ella.
  AppTextStyles._();

  // Título grande. FontWeight.bold = letra gruesa (negrita).
  // Úsalo para el título principal de una pantalla.
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Subtítulo. FontWeight.w600 es un poco menos grueso que "bold"
  // (que es w700), útil para destacar sin gritar tanto como heading1.
  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Texto normal de contenido (el tamaño "por defecto" de la app).
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  // Igual que "body" pero en color gris (textSecondary), para texto
  // que acompaña al principal sin competir por atención.
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Texto pequeño: fechas, etiquetas, notas al pie.
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Texto de botones. Color blanco (AppColors.surface) porque los
  // botones normalmente tienen fondo de color (AppColors.primary),
  // y el blanco es el que mejor contrasta sobre el verde.
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
  );
}
