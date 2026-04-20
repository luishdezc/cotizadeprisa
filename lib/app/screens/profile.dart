import 'package:cotizadeprisa/app/auth_gate.dart';
import 'package:cotizadeprisa/app/services/auth_service.dart';
import 'package:cotizadeprisa/app/screens/profileSettings.dart';
import 'package:cotizadeprisa/app/widgets/Texts.dart';
import 'package:cotizadeprisa/app/widgets/customButon.dart';
import 'package:cotizadeprisa/app/widgets/customCard.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/cupertino.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  final double spacing = 10;


  @override
  Widget build(BuildContext context) {
    bool isDarkMode = false;
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const TitleText(text: "Perfil"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          spacing: spacing,
        
          children: [



            CustomCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  const Text("Modo obscuro", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),


                  Switch(
                    value: isDarkMode, 
                    onChanged: (bool newValue){
                      showCupertinoDialog(
                      context: context,
                      builder: (_) => CupertinoAlertDialog(
                        title: const Text('Modo obscuro'),
                        content: const Text(
                          'Se implementará luego',
                        ),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Entendido'),
                          ),
                        ],
                      ),
                    );
                    }
                  )

                ],
              ),
            ),


            

            CustomCard(
              child: Column(
                spacing: spacing,
                children: [

                  Row(
        
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Datos de la empresa", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
        
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()),
                          );
        
                        },
                        child: const Padding(
                          padding:  EdgeInsets.all(8.0),
                          child: Icon(LucideIcons.pencil),
                        )
                      )
                    ],
                  ),

                  
        

        
                  
        
                  Row(
                    spacing: (spacing*2),
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset("assets/images/LogoFacturasGrisOscuro.png", height: 100,),
                      Expanded(
                        child: Column(
                          spacing: spacing,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Nombre de la empresa"),
                        
                            Text("correo"),
                                    
                            Text("Teléfono"),
                          ],
                        ),
                      ),
        
        
                      Expanded(
                        child: Column(
                          spacing: spacing,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const  [
                            Text("Nombre completo"),
                        
                            Text("Direccion"),
                            
                                    
                            Text("RFC"),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              )
            ),
        
        
        
        
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: spacing,
                children: [
                  const Text("Cuenta", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
        
                  const Text("correo de la cuenta"),


        
                  CustomButton(
                    texto: "Cerrar sesión",
                    funcion: () async {
                      await authService.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const AuthGate()),
                          (_) => false,
                        );
                      }
                    },
                  )
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}