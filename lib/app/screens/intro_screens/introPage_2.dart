import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cotizadeprisa/app/widgets/customTextField.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class IntroPage2 extends StatelessWidget {
  final VoidCallback next;
  final TextEditingController nombreController;
  final TextEditingController sloganController;
  final TextEditingController correoController;
  final TextEditingController telefonoController;

  const IntroPage2({
    super.key,
    required this.next,
    required this.nombreController,
    required this.sloganController,
    required this.correoController,
    required this.telefonoController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Stack(
        children: [
          Align(
              alignment: Alignment.bottomLeft,
              child: Image.asset('assets/images/decorations/SecBot.png',
                  width: 75)),

          Center(
            child: SizedBox(
              width: 950,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(height: 3),
                  const Padding(
                    padding: EdgeInsets.only(top: 26, left: 10),
                    child: Text(
                      "Primero Lo Básico",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 29),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    child: Text(
                      "Introduce el nombre de tu empresa y su eslogan para crear cotizaciones únicas.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).hintColor),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                            icon: LucideIcons.building,
                            name: "Nombre de la empresa",
                            variable: nombreController),
                        const SizedBox(height: 25),
                        CustomTextField(
                            icon: LucideIcons.signature,
                            name: "Slogan",
                            variable: sloganController),
                        const SizedBox(height: 25),
                        CustomTextField(
                            icon: LucideIcons.mail,
                            name: "Correo",
                            variable: correoController),
                        const SizedBox(height: 25),
                        CustomTextField(
                            icon: LucideIcons.phone,
                            name: "Telefono",
                            variable: telefonoController),
                        const SizedBox(height: 10),
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
                    ), // Move saving logic to the last screen
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
