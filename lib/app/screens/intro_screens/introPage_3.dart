import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cotizadeprisa/app/widgets/customTextField.dart';
import 'package:cotizadeprisa/app/widgets/logoButton.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class IntroPage3 extends StatelessWidget {
  final VoidCallback next;
  final TextEditingController usuarioController;
  final TextEditingController direccionController;
  final TextEditingController rfcController;

  const IntroPage3({
    super.key,
    required this.next,
    required this.usuarioController,
    required this.direccionController,
    required this.rfcController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset('assets/images/decorations/Third.png', width: 40),
          ),
          Center(
            child: SizedBox(
              width: 950,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    "Por Último Lo Legal",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 29),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          icon: LucideIcons.user,
                          name: "Nombre Completo",
                          variable: usuarioController,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          icon: LucideIcons.mapPin,
                          name: "Dirección",
                          variable: direccionController,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          icon: LucideIcons.idCardLanyard,
                          name: "RFC",
                          variable: rfcController,
                        ),
                        const SizedBox(height: 20),
                        const LogoButton(),
                        const SizedBox(height: 8),
                        const Text(
                          "Se podrá editar más adelante",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    color: Theme.of(context).canvasColor,
                    onPressed: next,
                    child: const Text(
                      "Guardar y Continuar",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


