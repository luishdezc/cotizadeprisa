import 'package:cotizadeprisa/app/widgets/Texts.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cotizadeprisa/app/widgets/customCard.dart';
import 'package:cotizadeprisa/app/widgets/customTextField.dart';
import 'package:cotizadeprisa/app/widgets/logoButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cotizadeprisa/app/providers/app_provider.dart';


class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController nombre = TextEditingController();
  final TextEditingController slogan = TextEditingController();
  final TextEditingController correo = TextEditingController();
  final TextEditingController telefono = TextEditingController();
  final TextEditingController usuario = TextEditingController();
  final TextEditingController direccion = TextEditingController();
  final TextEditingController rfc = TextEditingController();
  final TextEditingController impuesto = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const TitleText(text: 'Actualizar Datos'),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color.fromARGB(255, 253, 170, 41),
        child: const Icon(LucideIcons.save, color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                DatosDeEmpresaSection(
                  nombre: nombre,
                  slogan: slogan,
                  correo: correo,
                  telefono: telefono,
                  usuario: usuario,
                  direccion: direccion,
                  rfc: rfc,
                ),
                const SizedBox(height: 20),
                DatosDePagoSection(impuesto: impuesto),
                const SizedBox(height: 20),
                const CertificadosSATSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DatosDeEmpresaSection extends StatelessWidget {
  final TextEditingController nombre, slogan, correo, telefono, usuario, direccion, rfc;
  const DatosDeEmpresaSection({
    super.key, required this.nombre, required this.slogan, required this.correo,
    required this.telefono, required this.usuario, required this.direccion, required this.rfc,
  });
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Datos de la empresa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 25),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _formFields(nombre, slogan, correo, telefono, usuario, direccion, rfc).length,
            separatorBuilder: (_, __) => const SizedBox(height: 25),
            itemBuilder: (context, i) => _formFields(nombre, slogan, correo, telefono, usuario, direccion, rfc)[i],
          ),
          const LogoButton(),
        ],
      ),
    );
  }
}

class DatosDePagoSection extends StatelessWidget {
  final TextEditingController impuesto;
  const DatosDePagoSection({super.key, required this.impuesto});
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Datos del pago',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 25),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _priceFields(impuesto).length,
            separatorBuilder: (_, __) => const SizedBox(height: 25),
            itemBuilder: (context, i) => _priceFields(impuesto)[i],
          ),
        ],
      ),
    );
  }
}

class CertificadosSATSection extends StatefulWidget {
  const CertificadosSATSection({super.key});
  @override
  State<CertificadosSATSection> createState() => _CertificadosSATSectionState();
}

class _CertificadosSATSectionState extends State<CertificadosSATSection> {
  String? _nombreCer;
  String? _nombreKey;
  final TextEditingController _pwdCtrl = TextEditingController();
  bool _showPwd = false;

  void _simularSeleccion(String ext) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('Seleccionar archivo .$ext'),
        content: Text(
          'Aquí se abrirá el selector de archivos para el certificado .$ext '
          '(pendiente de integrar con file_picker).',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                if (ext == 'cer') _nombreCer = 'certificado_prueba.cer';
                else _nombreKey = 'llave_privada.key';
              });
            },
            child: const Text('Simular selección'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _guardar() {
    if (_nombreCer == null || _nombreKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona ambos archivos (.cer y .key)')));
      return;
    }
    if (_pwdCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingresa la contraseña de la llave privada')));
      return;
    }
    context.read<AppProvider>().setCertificados(
      cerPath: _nombreCer!, keyPath: _nombreKey!, password: _pwdCtrl.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Certificados guardados'), backgroundColor: Color(0xFF6DB1B1)));
  }

  void _limpiar() {
    context.read<AppProvider>().limpiarCertificados();
    setState(() { _nombreCer = null; _nombreKey = null; _pwdCtrl.clear(); });
  }

  @override
  Widget build(BuildContext context) {
    final activos = context.watch<AppProvider>().certificadosCargados;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(children: [
            const Icon(LucideIcons.shieldCheck, size: 20, color: Color(0xFF6DB1B1)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Certificados para Timbrado (SAT)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
            if (activos)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF6DB1B1).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Activos',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3D8F8F))),
              ),
          ]),
          const SizedBox(height: 6),
          Text(
            'Sube tu certificado .cer y llave privada .key para timbrar facturas ante el SAT. ',
            style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 20),

          // Archivo .cer
          _FileSelector(
            label: 'Certificado (.cer)', ext: 'cer', icon: LucideIcons.fileBadge,
            nombre: _nombreCer,
            onTap: () => _simularSeleccion('cer'),
            onClear: () => setState(() => _nombreCer = null),
          ),
          const SizedBox(height: 14),

          _FileSelector(
            label: 'Llave privada (.key)', ext: 'key', icon: LucideIcons.keyRound,
            nombre: _nombreKey,
            onTap: () => _simularSeleccion('key'),
            onClear: () => setState(() => _nombreKey = null),
          ),
          const SizedBox(height: 14),

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
          const SizedBox(height: 20),

          Row(children: [
            if (activos) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _limpiar,
                  icon: const Icon(LucideIcons.trash2, size: 16),
                  label: const Text('Limpiar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(LucideIcons.save, size: 16),
                label: const Text('Guardar certificados'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6DB1B1), foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _FileSelector extends StatelessWidget {
  final String label, ext;
  final IconData icon;
  final String? nombre;
  final VoidCallback onTap, onClear;
  const _FileSelector({
    required this.label, required this.ext, required this.icon,
    required this.nombre, required this.onTap, required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cargado = nombre != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: cargado ? const Color(0xFF6DB1B1) : Theme.of(context).shadowColor.withValues(alpha: 0.4),
            width: cargado ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: cargado ? const Color(0xFF6DB1B1).withValues(alpha: 0.06) : Colors.transparent,
        ),
        child: Row(children: [
          Icon(icon, size: 20, color: cargado ? const Color(0xFF6DB1B1) : Theme.of(context).hintColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor.withValues(alpha: 0.7))),
              Text(
                cargado ? nombre! : 'Toca para seleccionar archivo .$ext',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: cargado ? FontWeight.w600 : FontWeight.normal,
                  color: cargado ? const Color(0xFF3D8F8F) : Theme.of(context).hintColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),
          if (cargado)
            GestureDetector(
              onTap: onClear,
              child: const Padding(padding: EdgeInsets.all(4), child: Icon(LucideIcons.x, size: 16, color: Colors.grey)),
            )
          else
            Icon(LucideIcons.upload, size: 16, color: Theme.of(context).hintColor),
        ]),
      ),
    );
  }
}

List<CustomTextField> _formFields(
  TextEditingController nombre, TextEditingController slogan, TextEditingController correo,
  TextEditingController telefono, TextEditingController usuario,
  TextEditingController direccion, TextEditingController rfc,
) => [
  CustomTextField(icon: LucideIcons.building, name: "Nombre de la empresa", variable: nombre),
  CustomTextField(icon: LucideIcons.signature, name: "Slogan", variable: slogan),
  CustomTextField(icon: LucideIcons.mail, name: "Correo", variable: correo),
  CustomTextField(icon: LucideIcons.phone, name: "Teléfono", variable: telefono),
  CustomTextField(icon: LucideIcons.user, name: "Nombre Completo", variable: usuario),
  CustomTextField(icon: LucideIcons.mapPin, name: "Dirección", variable: direccion),
  CustomTextField(icon: LucideIcons.idCardLanyard, name: "RFC", variable: rfc),
];

List<CustomTextField> _priceFields(TextEditingController impuesto) => [
  CustomTextField(icon: LucideIcons.percent, name: "Porcentaje de impuesto", variable: impuesto),
];
