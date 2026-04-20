import 'package:cotizadeprisa/app/screens/homePage.dart';
import 'package:cotizadeprisa/app/screens/login_process/registro.dart';
import 'package:cotizadeprisa/app/services/auth_service.dart';
import 'package:cotizadeprisa/app/widgets/customButon.dart';
import 'package:cotizadeprisa/app/widgets/customTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = correoController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Por favor completa todos los campos.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmail(email: email, password: password);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const HomePage()),
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

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) return; // Cancelado por el usuario
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      _showError('Error al iniciar con Google. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
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
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadows: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inicio de sesión',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),

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
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿No tienes cuenta? ',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(builder: (context) => const RegistroPage()),
                          );
                        },
                        child: const Text(
                          'Registrarse',
                          style: TextStyle(
                            color: Color(0xFF008F8F),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            CustomButton(
                              texto: "Ingresar",
                              funcion: _handleLogin,
                            ),
                            const SizedBox(height: 16),

                            const Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text("o", style: TextStyle(color: Colors.grey)),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 16),

                            OutlinedButton.icon(
                              onPressed: _isLoading ? null : _handleGoogleLogin,
                              icon: Image.network(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvUEPcQkCb9DNjiN5j_uL51VMehMlc6ye5AQ&s',
                                height: 20,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_circle),
                              ),
                              label: const Text(
                                'Continuar con Google',
                                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
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
