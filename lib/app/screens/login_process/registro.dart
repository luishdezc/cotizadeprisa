import 'package:cotizadeprisa/app/screens/login_process/codeConfirmation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cotizadeprisa/app/widgets/customTextField.dart';
import 'package:cotizadeprisa/app/widgets/customButon.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  // Controladores
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
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
                shadows: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
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
                          // Regresar al Login
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

                  CustomButton(
                    texto: "Registrarse",
                    funcion: () {
                      
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => const ConfirmacionPage()),
                      );
                    },
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