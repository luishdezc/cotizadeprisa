import 'package:cotizadeprisa/app/providers/app_provider.dart';
import 'package:cotizadeprisa/app/screens/homePage.dart';
import 'package:cotizadeprisa/app/screens/login_process/login.dart';
import 'package:cotizadeprisa/app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AppProvider>().init(user);
          });
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
