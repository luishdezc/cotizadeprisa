import 'package:cotizadeprisa/app/screens/intro_screens/introductionScreen.dart';
import 'package:cotizadeprisa/app/services/auth_service.dart';
import 'package:cotizadeprisa/app/widgets/customButon.dart';
import 'package:cotizadeprisa/app/widgets/customTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistro() async {
    final nombre = nombreController.text.trim();
    final email = correoController.text.trim();
    final password = passwordController.text;

    if (nombre.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Por favor completa todos los campos.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await _authService.registerWithEmail(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(nombre);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const IntroductionScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _showError(AuthService.getErrorMessage(e));
    } catch (_) {
      _showError('Ocurrió un error inesperado. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color.fromARGB(255, 245, 245, 245),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadows: [
                  BoxShadow(color: Theme.of(context).shadowColor.withAlpha(30), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Crea una cuenta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    name: "Nombre completo",
                    variable: nombreController,
                    icon: LucideIcons.user,
                  ),
                  const SizedBox(height: 15),

                  CustomTextField(
                    name: "Correo electrónico",
                    variable: correoController,
                    icon: LucideIcons.mail,
                  ),
                  const SizedBox(height: 15),

                  CustomTextField(
                    name: "Contraseña",
                    variable: passwordController,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '¿Ya tienes cuenta? ',
                        style: TextStyle(fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: Color(0xFF008F8F),
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          texto: "Registrarse",
                          funcion: _handleRegistro,
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
