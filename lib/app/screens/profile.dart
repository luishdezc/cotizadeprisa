import 'dart:io';
import 'package:cotizadeprisa/app/auth_gate.dart';
import 'package:cotizadeprisa/app/config/app_config.dart';
import 'package:cotizadeprisa/app/providers/app_provider.dart';
import 'package:cotizadeprisa/app/services/auth_service.dart';
import 'package:cotizadeprisa/app/services/theme_service.dart';
import 'package:cotizadeprisa/app/screens/profileSettings.dart';
import 'package:cotizadeprisa/app/widgets/Texts.dart';
import 'package:cotizadeprisa/app/widgets/customButon.dart';
import 'package:cotizadeprisa/app/widgets/customCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final provider    = context.watch<AppProvider>();
    final perfil      = provider.perfil;
    final logoPath    = provider.logoPath;
    final user        = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const TitleText(text: 'Perfil'),
          backgroundColor: Colors.transparent, scrolledUnderElevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          CustomCard(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Modo oscuro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeService.instance,
              builder: (_, mode, __) => Switch(
                value: mode == ThemeMode.dark,
                onChanged: (_) => ThemeService.instance.toggle(),
              ),
            ),
          ])),
          const SizedBox(height: 10),

          CustomCard(child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Datos de la empresa',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ProfileSettingsScreen())),
                child: const Padding(padding: EdgeInsets.all(8), child: Icon(LucideIcons.pencil)),
              ),
            ]),
            const SizedBox(height: 10),
            if (perfil == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Completa tu perfil para comenzar a facturar.',
                    textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF919191))),
              )
            else
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Avatar(logoPath: logoPath, nombre: perfil.nombre),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(perfil.nombre.isNotEmpty ? perfil.nombre : 'Sin nombre',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  if (perfil.slogan.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(perfil.slogan, style: const TextStyle(fontSize: 12, color: Color(0xFF919191))),
                  ],
                  const SizedBox(height: 6),
                  _Chip(LucideIcons.idCardLanyard, perfil.rfc.isNotEmpty ? perfil.rfc : 'RFC no configurado'),
                  const SizedBox(height: 4),
                  _Chip(LucideIcons.mail, perfil.correo.isNotEmpty ? perfil.correo : 'Correo no configurado'),
                  if (perfil.codigoPostal.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _Chip(LucideIcons.mapPin, 'C.P. ${perfil.codigoPostal}'),
                  ],
                  if (perfil.telefono.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _Chip(LucideIcons.phone, perfil.telefono),
                  ],
                ])),
              ]),
          ])),
          const SizedBox(height: 10),

          CustomCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Certificados SAT (CSD)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Consumer<AppProvider>(builder: (_, p, __) => Row(children: [
              Icon(p.certificadosCargados ? LucideIcons.shieldCheck : LucideIcons.shieldAlert,
                  size: 16, color: p.certificadosCargados ? const Color(0xFF3D8F8F) : Colors.orange),
              const SizedBox(width: 8),
              Text(p.certificadosCargados
                      ? 'CSD cargado — listo para timbrar'
                      : 'Sin CSD — requerido para timbrar',
                  style: TextStyle(fontSize: 12,
                      color: p.certificadosCargados ? const Color(0xFF3D8F8F) : Colors.orange.shade700)),
            ])),
          ])),
          const SizedBox(height: 10),

          CustomCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Cuenta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(LucideIcons.mail, size: 16, color: Color(0xFF919191)),
              const SizedBox(width: 6),
              Text(user?.email ?? 'Sin correo',
                  style: const TextStyle(color: Color(0xFF919191), fontSize: 14)),
            ]),
            const SizedBox(height: 10),
            CustomButton(
              texto: 'Cerrar sesión',
              funcion: () async {
                context.read<AppProvider>().limpiarStreams();
                await authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AuthGate()), (_) => false);
                }
              },
            ),
          ])),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? logoPath; final String nombre;
  const _Avatar({this.logoPath, required this.nombre});
  @override
  Widget build(BuildContext context) {
    final hasLogo = logoPath != null && File(logoPath!).existsSync();
    if (hasLogo) return ClipRRect(borderRadius: BorderRadius.circular(12),
        child: Image.file(File(logoPath!), width: 70, height: 70, fit: BoxFit.cover));
    return Container(width: 70, height: 70,
        decoration: BoxDecoration(color: const Color(0xFFA5D9D9), borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))));
  }
}

class _Chip extends StatelessWidget {
  final IconData icon; final String text;
  const _Chip(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 13, color: const Color(0xFF919191)),
    const SizedBox(width: 4),
    Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF919191)),
        overflow: TextOverflow.ellipsis)),
  ]);
}
