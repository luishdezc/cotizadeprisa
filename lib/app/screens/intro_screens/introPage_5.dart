import 'package:cotizadeprisa/app/providers/app_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class IntroPage5 extends StatefulWidget {
  final VoidCallback next;

  const IntroPage5({super.key, required this.next});

  @override
  State<IntroPage5> createState() => _IntroPage5State();
}

class _IntroPage5State extends State<IntroPage5> {
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

  void _continuar() {
    if (_nombreCer != null && _nombreKey != null && _pwdCtrl.text.isNotEmpty) {
      context.read<AppProvider>().setCertificados(
        cerPath: _nombreCer!,
        keyPath: _nombreKey!,
        password: _pwdCtrl.text,
      );
    }
    widget.next();
  }

  @override
  Widget build(BuildContext context) {
    final bool certificadosCompletos =
        _nombreCer != null && _nombreKey != null && _pwdCtrl.text.isNotEmpty;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Image.asset(
              'assets/images/decorations/BotLeft.png',
              width: 80,
            ),
          ),
          Center(
            child: SizedBox(
              width: 950,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),

                    const Center(
                      child: Text(
                        'Certificados SAT',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 29),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Para poder timbrar facturas ante el SAT necesitas tu certificado de sello digital. '
                          'También puedes omitir esto y configurarlo más adelante.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    _FileSelector(
                      label: 'Certificado (.cer)',
                      ext: 'cer',
                      icon: LucideIcons.fileBadge,
                      nombre: _nombreCer,
                      onTap: () => _simularSeleccion('cer'),
                      onClear: () => setState(() => _nombreCer = null),
                    ),
                    const SizedBox(height: 14),

                    _FileSelector(
                      label: 'Llave privada (.key)',
                      ext: 'key',
                      icon: LucideIcons.keyRound,
                      nombre: _nombreKey,
                      onTap: () => _simularSeleccion('key'),
                      onClear: () => setState(() => _nombreKey = null),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: _pwdCtrl,
                      obscureText: !_showPwd,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Contraseña de la llave privada',
                        prefixIcon: const Icon(LucideIcons.lock, size: 18),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _showPwd = !_showPwd),
                          child: Icon(
                            _showPwd ? LucideIcons.eyeOff : LucideIcons.eye,
                            size: 18,
                          ),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),

                    if (certificadosCompletos) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(LucideIcons.circleCheck, size: 16, color: Color(0xFF3D8F8F)),
                          const SizedBox(width: 6),
                          Text(
                            'Certificados listos para timbrar',
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF3D8F8F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: Theme.of(context).canvasColor,
                        onPressed: _continuar,
                        child: Text(
                          certificadosCompletos ? 'Guardar y Continuar' : 'Omitir por ahora',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
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
            color: cargado
                ? const Color(0xFF6DB1B1)
                : Theme.of(context).shadowColor.withValues(alpha: 0.4),
            width: cargado ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: cargado
              ? const Color(0xFF6DB1B1).withValues(alpha: 0.06)
              : Colors.transparent,
        ),
        child: Row(children: [
          Icon(icon, size: 20,
              color: cargado ? const Color(0xFF6DB1B1) : Theme.of(context).hintColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: TextStyle(fontSize: 12,
                      color: Theme.of(context).hintColor.withValues(alpha: 0.7))),
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
              child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(LucideIcons.x, size: 16, color: Colors.grey)),
            )
          else
            Icon(LucideIcons.upload, size: 16, color: Theme.of(context).hintColor),
        ]),
      ),
    );
  }
}
