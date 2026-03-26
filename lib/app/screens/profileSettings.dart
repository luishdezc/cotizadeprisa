import 'package:cotizadeprisa/app/widgets/Texts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cotizadeprisa/app/widgets/customCard.dart';
import 'package:cotizadeprisa/app/widgets/customTextField.dart';
import 'package:cotizadeprisa/app/widgets/logoButton.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController nombre = TextEditingController();
  final TextEditingController slogan = TextEditingController();
  final TextEditingController correo = TextEditingController();
  final TextEditingController telefono = TextEditingController();
  final TextEditingController usuario = TextEditingController();
  final TextEditingController direccion = TextEditingController();
  final TextEditingController rfc = TextEditingController();
  final TextEditingController impuesto = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const TitleText(text: 'Actualizar Datos',),
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: ()  {
        },
        backgroundColor: const Color.fromARGB(255, 253, 170, 41),
        child: const Icon(LucideIcons.save, color: Colors.white),
      ),

      body: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      
                      const SizedBox(height: 20),
                      DatosDeEmpresaSection(
                        nombre: nombre,
                        slogan: slogan,
                        correo: correo,
                        telefono: telefono,
                        usuario: usuario,
                        direccion: direccion,
                        rfc: rfc,
                      ),
                      const SizedBox(height: 20),
                      DatosDePagoSection(impuesto: impuesto),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}



class DatosDeEmpresaSection extends StatelessWidget {
  final TextEditingController nombre;
  final TextEditingController slogan;
  final TextEditingController correo;
  final TextEditingController telefono;
  final TextEditingController usuario;
  final TextEditingController direccion;
  final TextEditingController rfc;

  const DatosDeEmpresaSection({
    super.key,
    required this.nombre,
    required this.slogan,
    required this.correo,
    required this.telefono,
    required this.usuario,
    required this.direccion,
    required this.rfc,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datos de la empresa',
            style: TextStyle(
              color: Color.fromARGB(255, 53, 53, 53),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 25),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: listOfForm(nombre, slogan, correo, telefono, usuario, direccion, rfc).length,
            separatorBuilder: (_, __) => const SizedBox(height: 25),
            itemBuilder: (context, index) => listOfForm(nombre, slogan, correo, telefono, usuario, direccion, rfc)[index],
          ),

          const LogoButton(),
        ],
      ),
    );
  }
}

class DatosDePagoSection extends StatelessWidget {
  final TextEditingController impuesto;

  const DatosDePagoSection({
    super.key,
    required this.impuesto,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datos del pago',
            style: TextStyle(
              color: Color.fromARGB(255, 53, 53, 53),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 25),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: listOfPriceForm(impuesto).length,
            separatorBuilder: (_, __) => const SizedBox(height: 25),
            itemBuilder: (context, index) => listOfPriceForm(impuesto)[index],
          ),
        ],
      ),
    );
  }
}

List<CustomTextField> listOfForm(
  TextEditingController nombre,
  TextEditingController slogan,
  TextEditingController correo,
  TextEditingController telefono,
  TextEditingController usuario,
  TextEditingController direccion,
  TextEditingController rfc,
) {
  return [
    CustomTextField(
      icon: LucideIcons.building,
      name: "Nombre de la empresa",
      variable: nombre,
    ),
    CustomTextField(
      icon: LucideIcons.signature,
      name: "Slogan",
      variable: slogan,
    ),
    CustomTextField(
      icon: LucideIcons.mail,
      name: "Correo",
      variable: correo,
    ),
    CustomTextField(
      icon: LucideIcons.phone,
      name: "Teléfono",
      variable: telefono,
    ),
    CustomTextField(
      icon: LucideIcons.user,
      name: "Nombre Completo",
      variable: usuario,
    ),
    CustomTextField(
      icon: LucideIcons.mapPin,
      name: "Direccion",
      variable: direccion,
    ),
    CustomTextField(
      icon: LucideIcons.idCardLanyard,
      name: "RFC",
      variable: rfc,
    ),
  ];
}

List<CustomTextField> listOfPriceForm(TextEditingController impuesto) {
  return [
    CustomTextField(
      icon: LucideIcons.percent,
      name: "Porcentaje de impuesto",
      variable: impuesto,
    ),
  ];
}