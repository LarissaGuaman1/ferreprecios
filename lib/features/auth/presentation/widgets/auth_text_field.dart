import 'package:flutter/material.dart';

// Campo de texto reutilizado en Login y Registro (correo, contraseña,
// nombre, etc.). Centraliza la apariencia para que ambas pantallas
// se vean consistentes.
class AuthTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;

  // Si es true, el texto se oculta (••••) y se muestra el botón de
  // mostrar/ocultar. Lo usamos para los campos de contraseña.
  final bool isPassword;

  final TextInputType keyboardType;

  // Función de validación que usa el Form del padre (login_screen,
  // register_screen) para decidir si el dato ingresado es válido.
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  // Estado PROPIO de este widget: solo decide si SE VE el texto de la
  // contraseña o no. No le interesa a ninguna otra pantalla, por eso
  // no vive en AuthProvider, vive aquí con un simple setState.
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  // setState le dice a Flutter "algo cambió, vuelve a
                  // dibujar este widget". Solo se redibuja este campo,
                  // no toda la pantalla.
                  setState(() => _obscureText = !_obscureText);
                },
              )
            : null,
      ),
    );
  }
}
