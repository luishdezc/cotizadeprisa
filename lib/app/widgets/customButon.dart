import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  CustomButton({
    super.key,
    this.texto,
    this.child,
    required this.funcion,
  });

  final String? texto;
  final Function() funcion;
  Widget? child;


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Theme.of(context).canvasColor,),
      width: double.infinity,
      child: CupertinoButton(
        child: 
        
        (child != null)

        ? child!
        
        : (texto != null)
        
          ? Text(texto!, style: const TextStyle( color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.5),) 
          
          : const SizedBox(),

        
        onPressed: (){
            funcion();
          }
      ),
    );
  }
}