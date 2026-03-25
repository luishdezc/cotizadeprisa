import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomCard extends StatelessWidget {
  CustomCard({
    super.key,
    required this.child,

  });

  Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(

      decoration:  BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [BoxShadow(color: Color.fromARGB(37, 65, 65, 65), offset: Offset(0, 1), blurRadius: 5),],
      ),


      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}