import 'package:cotizadeprisa/app/screens/intro_screens/introductionScreen.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cotizadeprisa/app/widgets/customButon.dart';

class ConfirmacionPage extends StatefulWidget {
  const ConfirmacionPage({super.key});

  @override
  State<ConfirmacionPage> createState() => _ConfirmacionPageState();
}

class _ConfirmacionPageState extends State<ConfirmacionPage> {
  final int codeLength = 6;
  
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(codeLength, (index) => TextEditingController());
    focusNodes = List.generate(codeLength, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
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
              constraints: const BoxConstraints(maxWidth: 450),
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 330,
                    child: Text(
                      'Código de confirmación',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  const Text(
                    'Se envió un código al correo: correo@hotmail.com',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Fila de inputs para el código
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(codeLength, (index) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                              right: index != codeLength - 1 ? 8.0 : 0.0, // Separación entre cuadros
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 2,
                                  color: Color(0xFF919191), /* Border */
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: TextField(
                              controller: controllers[index],
                              focusNode: focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.text, // Puede ser number si solo son números
                              maxLength: 1, // Restringe a un solo carácter
                              textCapitalization: TextCapitalization.characters, // Fuerza mayúsculas
                              style: const TextStyle(
                                fontSize: 26,
                              ),
                              decoration: const InputDecoration(
                                counterText: "", // Oculta el contador de texto "0/1"
                                border: InputBorder.none, // Oculta la línea default del TextField
                                isDense: true,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  // Avanza al siguiente cuadro si se inserta un carácter
                                  if (index < codeLength - 1) {
                                    FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                                  } else {
                                    // Si es el último cuadro, esconde el teclado
                                    focusNodes[index].unfocus();
                                  }
                                } else {
                                  // Si se borra el carácter, regresa al cuadro anterior
                                  if (index > 0) {
                                    FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '¿No recibiste un código?',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Lógica para reenviar código
                          },
                          child: const Text(
                            'Reenviar',
                            style: TextStyle(
                              color: Color(0xFF008F8F),
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  CustomButton(
                    texto: "Confirmar",
                    funcion: () {
          
                      String fullCode = controllers.map((c) => c.text).join();
                      print("Código ingresado: $fullCode");
                      
                      // Navegar o validar
                      Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(builder: (context) => const IntroductionScreen()),
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