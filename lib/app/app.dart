import 'package:cotizadeprisa/app/auth_gate.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primary = Color.fromARGB(255, 109, 177, 177);

    return MaterialApp(
      title: 'CotizApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        primaryColor: primary,
        canvasColor: const Color.fromARGB(255, 253, 170, 41),
        hintColor: const Color.fromARGB(255, 60, 60, 60),
        shadowColor: const Color.fromARGB(255, 160, 160, 160),
        primarySwatch: Colors.blue,
      ),
      home: const AuthGate(),
    );
  }
}
