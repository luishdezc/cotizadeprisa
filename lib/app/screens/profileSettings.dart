import 'dart:io';
import 'package:cotizadeprisa/app/models/empresa_perfil.dart';
import 'package:cotizadeprisa/app/providers/app_provider.dart';
import 'package:cotizadeprisa/app/widgets/Texts.dart';
import 'package:cotizadeprisa/app/widgets/customCard.dart';
import 'package:cotizadeprisa/app/widgets/customTextField.dart';
import 'package:cotizadeprisa/app/widgets/logoButton.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';


class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});
  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _nombre     = TextEditingController();
  final _slogan     = TextEditingController();
  final _correo     = TextEditingController();
  final _telefono   = TextEditingController();
  final _usuario    = TextEditingController();
  final _direccion  = TextEditingController();
  final _rfc        = TextEditingController();
  final _cp         = TextEditingController();
  final _impuesto   = TextEditingController();
  final _regimen    = TextEditingController();

  // CSD
  String? _cerPath, _cerNombre, _keyPath, _keyNombre;
  final _pwdCtrl = TextEditingController();
  bool _showPwd = false;

  bool _guardando = false;
  bool _cargado   = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  @override
  void dispose() {
    for (final c in [_nombre,_slogan,_correo,_telefono,_usuario,_direccion,_rfc,_cp,_impuesto,_regimen,_pwdCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _cargar() {
    if (_cargado) return;
    final p = context.read<AppProvider>().perfil;
    if (p == null) return;
    _nombre.text   = p.nombre;
    _slogan.text   = p.slogan;
    _correo.text   = p.correo;
    _telefono.text = p.telefono;
    _usuario.text  = p.usuario;
    _direccion.text= p.direccion;
    _rfc.text      = p.rfc;
    _cp.text       = p.codigoPostal;
    _impuesto.text = p.impuesto.toString();
    _regimen.text  = p.regimenFiscal;
    _cargado = true;
    if (mounted) setState(() {});
  }

  String? _validar() {
    if (_nombre.text.trim().isEmpty) return 'El nombre de la empresa es obligatorio';
    if (_rfc.text.trim().isEmpty) return 'El RFC es obligatorio';
    if (_cp.text.trim().length != 5) return 'El código postal debe tener 5 dígitos';
    return null;
  }

  Future<void> _seleccionarArchivo(String ext) async {
    final r = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: [ext]);
    if (r == null || r.files.isEmpty) return;
    setState(() {
      if (ext == 'cer') { _cerPath = r.files.first.path; _cerNombre = r.files.first.name; }
      else              { _keyPath = r.files.first.path; _keyNombre = r.files.first.name; }
    });
  }

  Future<void> _guardarCertificados() async {
    final provider = context.read<AppProvider>();
    if (_cerPath != null && _keyPath != null && _pwdCtrl.text.isNotEmpty) {
      provider.setCertificados(
          cerPath: _cerPath!, keyPath: _keyPath!, password: _pwdCtrl.text);
      _snack('Certificados cargados correctamente', ok: true);
    } else {
      _snack('Selecciona .cer, .key y escribe la contraseña');
    }
  }

  Future<void> _guardar() async {
    final err = _validar();
    if (err != null) { _snack(err); return; }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _guardando = true);
    final perfil = EmpresaPerfil(
      uid: uid, nombre: _nombre.text.trim(), slogan: _slogan.text.trim(),
      correo: _correo.text.trim(), telefono: _telefono.text.trim(),
      usuario: _usuario.text.trim(), direccion: _direccion.text.trim(),
      codigoPostal: _cp.text.trim(), rfc: _rfc.text.trim().toUpperCase(),
      regimenFiscal: _regimen.text.trim().isNotEmpty ? _regimen.text.trim() : '601',
      impuesto: double.tryParse(_impuesto.text) ?? 16.0,
    );

    final ok = await context.read<AppProvider>().guardarPerfil(perfil);
    setState(() => _guardando = false);
    if (!mounted) return;
    _snack(ok ? 'Perfil guardado' : 'Error al guardar', ok: ok);
    if (ok) Navigator.of(context).pop();
  }

  void _snack(String msg, {bool ok = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: ok ? const Color(0xFF6DB1B1) : Colors.red));

  @override
  Widget build(BuildContext context) {
    if (!_cargado) WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
    final provider  = context.watch<AppProvider>();
    final logoPath  = provider.logoPath;
    final certsCarg = provider.certificadosCargados;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent,
          title: const TitleText(text: 'Datos de la empresa')),
      floatingActionButton: FloatingActionButton(
        onPressed: _guardando ? null : _guardar,
        backgroundColor: const Color(0xFFFDAA29),
        child: _guardando
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : const Icon(LucideIcons.save, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          const SizedBox(height: 20),

          CustomCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Logo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (logoPath != null && File(logoPath).existsSync())
              Center(child: ClipRRect(borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(logoPath), height: 80, fit: BoxFit.contain))),
            const SizedBox(height: 12),
            const LogoButton(),
          ])),
          const SizedBox(height: 16),

          CustomCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Datos de la empresa',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            CustomTextField(icon: LucideIcons.building, name: 'Nombre / Razón Social', variable: _nombre),
            const SizedBox(height: 14),
            CustomTextField(icon: LucideIcons.signature, name: 'Slogan', variable: _slogan),
            const SizedBox(height: 14),
            CustomTextField(icon: LucideIcons.mail, name: 'Correo', variable: _correo),
            const SizedBox(height: 14),
            CustomTextField(icon: LucideIcons.phone, name: 'Teléfono', variable: _telefono),
            const SizedBox(height: 14),
            CustomTextField(icon: LucideIcons.user, name: 'Representante', variable: _usuario),
          ])),
          const SizedBox(height: 16),

          CustomCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Datos fiscales (CFDI)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Aparecerán en tus facturas CFDI 4.0',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            CustomTextField(icon: LucideIcons.idCardLanyard, name: 'RFC del emisor',
                variable: _rfc, textCapitalization: TextCapitalization.characters),
            const SizedBox(height: 14),
            CustomTextField(icon: LucideIcons.mapPin, name: 'Dirección fiscal', variable: _direccion),
            const SizedBox(height: 14),
            CustomTextField(icon: LucideIcons.mailbox, name: 'Código Postal (5 dígitos)',
                variable: _cp, keyboardType: TextInputType.number, maxLength: 5),
            const SizedBox(height: 14),
            CustomTextField(icon: LucideIcons.landmark, name: 'Régimen Fiscal (ej. 601, 626)',
                variable: _regimen, keyboardType: TextInputType.number),
            const SizedBox(height: 14),
            CustomTextField(icon: LucideIcons.percent, name: 'IVA por defecto (%)',
                variable: _impuesto,
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          ])),
          const SizedBox(height: 16),

          CustomCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(certsCarg ? LucideIcons.shieldCheck : LucideIcons.shield,
                  size: 16, color: certsCarg ? const Color(0xFF3D8F8F) : Colors.orange),
              const SizedBox(width: 8),
              const Text('Certificados SAT (CSD)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 6),
            const Text(
              'El Certificado de Sello Digital es necesario para generar y timbrar facturas CFDI.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 14),

            _FileRow(
              label: 'Certificado (.cer)',
              icon: LucideIcons.fileBadge,
              nombre: _cerNombre,
              onTap: () => _seleccionarArchivo('cer'),
              onClear: () => setState(() { _cerNombre = _cerPath = null; }),
            ),
            const SizedBox(height: 12),

            _FileRow(
              label: 'Llave privada (.key)',
              icon: LucideIcons.keyRound,
              nombre: _keyNombre,
              onTap: () => _seleccionarArchivo('key'),
              onClear: () => setState(() { _keyNombre = _keyPath = null; }),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _pwdCtrl,
              obscureText: !_showPwd,
              decoration: InputDecoration(
                labelText: 'Contraseña de la llave privada',
                prefixIcon: const Icon(LucideIcons.lock, size: 18),
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _showPwd = !_showPwd),
                  child: Icon(_showPwd ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _guardarCertificados,
                icon: const Icon(LucideIcons.shieldCheck, size: 16),
                label: const Text('Cargar certificados en memoria'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6DB1B1),
                  side: const BorderSide(color: Color(0xFF6DB1B1)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            if (certsCarg) ...[
              const SizedBox(height: 10),
              const Row(children: [
                Icon(LucideIcons.circleCheck, size: 14, color: Color(0xFF3D8F8F)),
                SizedBox(width: 6),
                Text('CSD cargado en memoria para timbrado',
                    style: TextStyle(fontSize: 12, color: Color(0xFF3D8F8F))),
              ]),
            ],
          ])),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  final String label; final IconData icon; final String? nombre;
  final VoidCallback onTap, onClear;
  const _FileRow({required this.label, required this.icon, required this.nombre,
      required this.onTap, required this.onClear});
  @override
  Widget build(BuildContext context) {
    final ok = nombre != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: ok ? const Color(0xFF6DB1B1) : Theme.of(context).shadowColor.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(10),
          color: ok ? const Color(0xFF6DB1B1).withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: ok ? const Color(0xFF6DB1B1) : Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor.withOpacity(0.7))),
            Text(ok ? nombre! : 'Toca para seleccionar',
                style: TextStyle(fontSize: 13, fontWeight: ok ? FontWeight.w600 : FontWeight.normal,
                    color: ok ? const Color(0xFF3D8F8F) : Colors.grey),
                overflow: TextOverflow.ellipsis),
          ])),
          if (ok)
            GestureDetector(onTap: onClear,
                child: const Padding(padding: EdgeInsets.all(4),
                    child: Icon(LucideIcons.x, size: 15, color: Colors.grey))),
        ]),
      ),
    );
  }
}
