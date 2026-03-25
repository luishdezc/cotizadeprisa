
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cotizadeprisa/app/screens/intro_screens/intoPage_1.dart';
import 'package:cotizadeprisa/app/screens/intro_screens/introPage_2.dart';
import 'package:cotizadeprisa/app/screens/intro_screens/introPage_3.dart';
import 'package:cotizadeprisa/app/screens/intro_screens/introPage_4.dart';
import 'package:cotizadeprisa/app/screens/newInvoice.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}
class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _controller = PageController();
  
  // Create controllers here so they persist across pages
  final TextEditingController nombreController = TextEditingController(text: '');
  final TextEditingController sloganController = TextEditingController(text: '');
  final TextEditingController correoController = TextEditingController(text: '');
  final TextEditingController telefonoController = TextEditingController(text: '');
  final TextEditingController usuarioController = TextEditingController(text: '');
  final TextEditingController direccionController = TextEditingController(text: '');
  final TextEditingController rfcController = TextEditingController(text: '');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: [
              IntroPage1(next: () => _controller.nextPage(duration: const Duration(milliseconds: 450), curve: Curves.easeOutSine)),
              IntroPage2(
                next: () => _controller.nextPage(duration: const Duration(milliseconds: 450), curve: Curves.easeOutSine),
                nombreController: nombreController,
                sloganController: sloganController,
                correoController: correoController,
                telefonoController: telefonoController,
              ),
              IntroPage3(
                next: () => _controller.nextPage(duration: const Duration(milliseconds: 450), curve: Curves.easeOutSine),
                usuarioController: usuarioController,
                direccionController: direccionController,
                rfcController: rfcController,
                
              ),
              // Pass controllers to next pages if needed...
              IntroPage4(
                next: () {
                  Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (context) => const NewInvoicePage()));
                },
              ),
            ],
          ),
          Container(
            alignment: const Alignment(0, 0.98),
            child: SmoothPageIndicator(
              controller: _controller,
              count: 4,
              effect: SlideEffect(
                  dotHeight: 8.0,
                  paintStyle: PaintingStyle.stroke,
                  dotColor: Colors.grey,
                  activeDotColor: Theme.of(context).hintColor),
            ),
          ),
        ],
      ),
    );
  }
}
