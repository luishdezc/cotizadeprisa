
import 'package:cotizadeprisa/app/screens/historial.dart';
import 'package:cotizadeprisa/app/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:cotizadeprisa/app/screens/newInvoice.dart';
import 'package:cotizadeprisa/app/screens/sat.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Inicializamos en 1 para que la pantalla por defecto sea "Nuevo Invoice" al entrar.
  int currentPageIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dependiendo del index seleccionado, mostramos la pantalla correspondiente
      body:  [
        const HistorialPage(),
        const NewInvoicePage(),
        const SatPage(),
        const ProfileScreen(),
      ][currentPageIndex],

      // NavigationBar con el formato de tu archivo bNavPage.dart
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (value) {
          setState(() {
            currentPageIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(

            icon: Icon(LucideIcons.history),
            label: "Historial",
          ),
          NavigationDestination(

            icon: Icon(LucideIcons.filePlus),
            label: "Cotizar",
          ),
          NavigationDestination(

            icon: Icon(LucideIcons.landmark),
            label: "SAT",
          ),
          NavigationDestination(

            icon: Icon(LucideIcons.userCog),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}