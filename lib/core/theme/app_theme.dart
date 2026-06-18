import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

// Construye el ThemeData que main.dart le pasa a MaterialApp.
// Aquí es donde AppColors y AppTextStyles se convierten en el estilo
// real que Flutter aplica a cada widget de la app.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      // Activa los componentes visuales más recientes de Flutter
      // (Material 3), que es el estándar actual.
      useMaterial3: true,

      // Color de fondo de todas las pantallas (Scaffold) que no
      // definan su propio color de fondo. El gradiente real lo pinta
      // AppBackground (en app_components.dart); esto es solo el
      // respaldo sólido para el primer frame antes de que pinte.
      scaffoldBackgroundColor: AppColors.bgGrad2,

      // ColorScheme.dark (en vez de .light): así, cualquier widget de
      // Flutter que dibuje texto/íconos SIN un color explícito (usando
      // "onSurface" por defecto) sale blanco, no negro. Como todo el
      // fondo de la app ahora es oscuro, esto evita "texto invisible".
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.priceColor,
        surface: AppColors.bgGrad2,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),

      // Estilo por defecto de todos los AppBar: transparente para que
      // se vea el gradiente de fondo detrás, con texto/íconos blancos.
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: AppTextStyles.heading2.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Estilo por defecto de los botones rellenos (ElevatedButton).
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Estilo "vidrio" para los campos de texto (buscador, login,
      // registro): fondo blanco casi transparente, borde sutil de
      // 0.5px, placeholder e ícono también translúcidos.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x1AFFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: Color(0x80FFFFFF)),
        prefixIconColor: const Color(0x99FFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.glassBorder, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.glassBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
      ),

      // Estilo "vidrio" para las tarjetas (Card de Flutter, por si se
      // usa directo en algún lugar fuera de nuestro GlassCard propio).
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.glassWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.glassBorder, width: 0.5),
        ),
      ),

      // Conecta nuestros estilos a los "slots" de texto que Flutter
      // usa por nombre en distintos widgets.
      textTheme: TextTheme(
        titleLarge: AppTextStyles.heading1,
        titleMedium: AppTextStyles.heading2,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodySecondary,
        labelSmall: AppTextStyles.caption,
      ),
    );
  }
}
