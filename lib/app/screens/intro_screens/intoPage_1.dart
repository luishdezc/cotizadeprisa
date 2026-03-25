
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key, required this.next});

  final void Function() next;
 
  @override
  Widget build(BuildContext context) {
    return Stack(
    children: [
      Image.asset('assets/images/decorations/FirstTop.png', width: 159,),
      Align( alignment: Alignment.bottomRight,child: Image.asset('assets/images/decorations/FirstBot.png', width: 75,)),
      Center(
        child: SizedBox(
        width: 900,
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(height: 10,),
              const Padding(
                padding: EdgeInsets.only(top: 18.0),
                child: Text("Cotiza en segundos", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 29, ),textAlign: TextAlign.start,),
              ),
              
              //SizedBox(height: 200,child: Lottie.asset('assets/images/animations/Welcome.json', frameRate: FrameRate(15))),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Text("Antes de empezar, primero debes configurar tus datos. Añade la información de tu empresa y los detalles de tus productos o servicios para generar cotizaciones personalizadas al instante.",textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).hintColor),),
              ),


              CupertinoButton(
                color: Theme.of(context).canvasColor,
                child: const Text("Empezar a Configurar",style: TextStyle(fontWeight: FontWeight.w500,)), 
                onPressed: () {
                next();

              },
              ),

            const SizedBox(height: 10,)
              //Lottie.asset('assets/images/Animation - 1719074046436.json', frameRate: FrameRate.max)
              //Image.asset('assets/images/payment-success-8709261-7033327.gif')
            ],
          ),
        ),
      )
    ]
    );
  }
}