// ignore: file_names
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage4 extends StatelessWidget {
  const IntroPage4({super.key, required this.next});

  final void Function() next;

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
      
      Align( alignment: Alignment.topLeft, child: Image.asset('assets/images/decorations/Fourth.png', width: 100,)),
    
      Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
    
        const SizedBox(height: 10,),
    
          const Padding(
            padding: EdgeInsets.only(top: 36,left: 10),
            child: Text("¡Todo Listo!", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 29),),
          ),
          
          SizedBox(height: 300, child: Lottie.network('https://lottie.host/bc60defe-5478-4e04-be9c-186ae942d1c1/uYOquKItEi.json')),            
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 26.0),
            child: Text("¡Perfecto! Has ingresado todos tus datos correctamente. Ahora estás listo para empezar a crear cotizaciones profesionales. Agradecemos tu confianza y estamos aquí para ayudarte de forma rápida y segura.",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w500,)),
          ),
          
          CupertinoButton(
            color: Theme.of(context).canvasColor,
            child: const Text("Empezar",style: TextStyle(fontWeight: FontWeight.w500,)), onPressed: (){ 
              next();
            },
          ),
    
    
          const SizedBox(height: 10,)
           //Lottie.asset('assets/images/Animation - 1719074046436.json', frameRate: FrameRate.max)
           //Image.asset('assets/images/payment-success-8709261-7033327.gif')
        ],
      ),
      )
    ]
    );
  }
}