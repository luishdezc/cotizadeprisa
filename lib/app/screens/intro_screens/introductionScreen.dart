import 'package:cotizadeprisa/app/providers/app_provider.dart';
import 'package:cotizadeprisa/app/screens/intro_screens/intoPage_1.dart';
import 'package:cotizadeprisa/app/screens/intro_screens/introPage_2.dart';
import 'package:cotizadeprisa/app/screens/intro_screens/introPage_3.dart';
import 'package:cotizadeprisa/app/screens/intro_screens/introPage_4.dart';
import 'package:cotizadeprisa/app/screens/intro_screens/introPage_5.dart';
import 'package:cotizadeprisa/app/screens/homePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _controller = PageController();

  final nombreController = TextEditingController();
  final sloganController = TextEditingController();
  final correoController = TextEditingController();
  final telefonoController = TextEditingController();

  final usuarioController = TextEditingController();
  final direccionController = TextEditingController();
  final rfcController = TextEditingController();
  final codigoPostalController = TextEditingController();
  final regimenFiscalController =
      TextEditingController(text: '601');

  bool _guardando = false;

  void _nextPage() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutSine,
    );
  }

  Future<void> _guardarYTerminar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _nextPage();
      return;
    }

    setState(() => _guardando = true);

    final provider = context.read<AppProvider>();
    final ok = await provider.guardarOnboarding(
      uid: uid,
      nombre: nombreController.text,
      slogan: sloganController.text,
      correo: correoController.text,
      telefono: telefonoController.text,
      usuario: usuarioController.text,
      direccion: direccionController.text,
      codigoPostal: codigoPostalController.text,
      rfc: rfcController.text,
      regimenFiscal: regimenFiscalController.text,
    );

    setState(() => _guardando = false);

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(provider.errorMessage ?? 'Error al guardar datos'),
          backgroundColor: Colors.red,
        ),
      );
    }

    _nextPage();
  }

  @override
  void dispose() {
    nombreController.dispose();
    sloganController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    usuarioController.dispose();
    direccionController.dispose();
    rfcController.dispose();
    codigoPostalController.dispose();
    regimenFiscalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              IntroPage1(next: _nextPage),
              IntroPage2(
                next: _nextPage,
                nombreController: nombreController,
                sloganController: sloganController,
                correoController: correoController,
                telefonoController: telefonoController,
              ),
              IntroPage3(
                next: _nextPage,
                usuarioController: usuarioController,
                direccionController: direccionController,
                rfcController: rfcController,
                codigoPostalController: codigoPostalController,
                regimenFiscalController: regimenFiscalController,
              ),
              IntroPage5(
                next: _guardando ? () {} : _guardarYTerminar,
                guardando: _guardando,
              ),
              IntroPage4(
                next: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    CupertinoPageRoute(
                        builder: (_) => const HomePage()),
                    (_) => false,
                  );
                },
              ),
            ],
          ),
          Container(
            alignment: const Alignment(0, 0.98),
            child: SmoothPageIndicator(
              controller: _controller,
              count: 5,
              effect: SlideEffect(
                dotHeight: 8.0,
                paintStyle: PaintingStyle.stroke,
                dotColor: Colors.grey,
                activeDotColor: Theme.of(context).hintColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
