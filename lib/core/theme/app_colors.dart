import 'package:flutter/material.dart';

extension ThemeExt on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get colorOnSurface => isDark ? Colors.white : const Color(0xFF1B3025);
  Color get colorOnSurfaceDim => isDark ? const Color(0x73FFFFFF) : const Color(0xFF5A7A6C);
  Color get colorCardBg => isDark ? AppColors.glassWhite : Colors.white;
  Color get colorCardBorder => isDark ? AppColors.glassBorder : const Color(0xFFDCEDE6);
  Color get colorSurfaceBg => isDark ? const Color(0xFF0D1F16) : Colors.white;
  Color get colorNavBg => isDark ? const Color(0xFF0A1628) : Colors.white;
  Color get colorAppBarBorder => isDark ? const Color(0x26FFFFFF) : const Color(0xFFDCEDE6);
  Color get colorNavBorder => isDark ? const Color(0x1AFFFFFF) : const Color(0xFFDCEDE6);
  Color get colorIconSecondary => isDark ? const Color(0xB3FFFFFF) : const Color(0xFF7A9A8A);
  Color get colorNavUnselected => isDark ? const Color(0x4DFFFFFF) : const Color(0xFF9ABAAC);
  Color get colorChipUnselectedBg => isDark ? const Color(0x0DFFFFFF) : const Color(0x0D1B3025);
  Color get colorChipUnselectedText => isDark ? const Color(0x80FFFFFF) : const Color(0xFF5A7A6C);
  Color get colorInputFill => isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF2FAF7);
  Color get colorDropdownBg => isDark ? const Color(0xFF1A2A4A) : Colors.white;
}

// Esta clase guarda TODOS los colores de la app en un solo lugar.
// Así, si un color cambia, lo editas aquí una sola vez en vez de buscarlo
// en cada pantalla.
class AppColors {
  // Constructor privado: nadie puede escribir "AppColors()" para crear un
  // objeto de esta clase. No tiene sentido instanciarla, solo la usamos
  // como una caja de constantes (ej: AppColors.primary).
  AppColors._();

  // ---------------------------------------------------------------------
  // Colores de marca
  // ---------------------------------------------------------------------

  // El verde teal principal de FerrePrecios. Lo vas a usar en botones,
  // el AppBar, y en cualquier elemento que represente la marca.
  static const Color primary = Color(0xFF1D9E75);

  // Versión muy clara del verde, útil para fondos suaves (ej: detrás de
  // un ícono, o el fondo de una tarjeta seleccionada) sin que se vea
  // tan fuerte como el color principal.
  static const Color primaryLight = Color(0xFFE1F5EE);

  // Versión oscura del verde, útil para texto sobre fondos claros que
  // necesite "sentirse" parte de la marca (ej: un título destacado).
  static const Color primaryDark = Color(0xFF085041);

  // ---------------------------------------------------------------------
  // Colores por sector de Quito
  // Cada sector de la ciudad tiene su propio color para que el usuario
  // identifique de un vistazo en qué zona está un precio o ferretería
  // (ej: una etiqueta de color en el mapa o en la lista de resultados).
  // ---------------------------------------------------------------------

  static const Color sectorNorte = Color(0xFF1D9E75);
  static const Color sectorSur = Color(0xFFD85A30);
  static const Color sectorCentro = Color(0xFF7F77DD);
  static const Color sectorValles = Color(0xFF378ADD);

  // El backend manda el sector como texto ("Norte", "Sur"...). Esta
  // función traduce ese texto al color que le corresponde, para no
  // repetir un if/switch en cada pantalla que muestre un sector.
  static Color sector(String nombreSector) {
    switch (nombreSector) {
      case 'Norte':
        return sectorNorte;
      case 'Sur':
        return sectorSur;
      case 'Centro':
        return sectorCentro;
      case 'Valles':
        return sectorValles;
      default:
        return textSecondary;
    }
  }

  // ---------------------------------------------------------------------
  // Estados semánticos
  // "Semántico" significa que el color comunica un significado fijo:
  // rojo siempre es error, ámbar siempre es advertencia. No los uses
  // para otra cosa, o vas a confundir al usuario.
  // ---------------------------------------------------------------------

  static const Color error = Color(0xFFA32D2D);
  static const Color warning = Color(0xFFBA7517);

  // ---------------------------------------------------------------------
  // Neutros (texto y fondos)
  // Con el rediseño Glassmorphism, TODA la app pasa a fondo oscuro.
  // Por eso estos dos ya no son grises oscuros (eso era para fondo
  // blanco): ahora son blancos, con textSecondary más transparente
  // para marcar la diferencia de jerarquía sin necesitar otro color.
  // ---------------------------------------------------------------------

  // Color del texto principal (títulos). Blanco puro.
  static const Color textPrimary = Color(0xFFFFFFFF);

  // Texto secundario (subtítulos, metadata): blanco al 45% de opacidad.
  static const Color textSecondary = Color(0x73FFFFFF);

  // Fondo general de las pantallas. Ya no se usa para el Scaffold
  // (ahora es el gradiente bgGrad1→bgGrad3), pero lo dejamos por si
  // algún widget puntual todavía necesita un blanco sólido.
  static const Color background = Color(0xFFFFFFFF);

  static const Color surface = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------
  // Glassmorphism: fondo oscuro + vidrio translúcido
  // ---------------------------------------------------------------------

  // Los 3 colores del gradiente de fondo fijo (arriba → centro → abajo).
  static const Color bgGrad1 = Color(0xFF0F4C3A);
  static const Color bgGrad2 = Color(0xFF1A2A4A);
  static const Color bgGrad3 = Color(0xFF2D1B5E);

  // "Vidrio": blanco casi transparente, para el fondo de las tarjetas.
  static const Color glassWhite = Color(0x14FFFFFF);

  // Borde sutil de las tarjetas de vidrio.
  static const Color glassBorder = Color(0x33FFFFFF);

  // Verde teal translúcido, para el chip de sector seleccionado.
  static const Color tealGlass = Color(0x661D9E75);

  // Teal claro, diseñado específicamente para que los precios se
  // lean bien sobre el fondo oscuro (más brillante que "primary").
  static const Color priceColor = Color(0xFF5DCAA5);
}
