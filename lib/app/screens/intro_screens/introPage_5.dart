import 'package:cotizadeprisa/app/providers/app_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';


class IntroPage5 extends StatefulWidget {
  final VoidCallback next;
  final bool guardando;

  const IntroPage5({super.key, required this.next, this.guardando = false});

  @override
  State<IntroPage5> createState() => _IntroPage5State();
}

class _IntroPage5State extends State<IntroPage5> {
  String? _pathCer;
  String? _nombreCer;
  String? _pathKey;
  String? _nombreKey;
  final TextEditingController _pwdCtrl = TextEditingController();
  bool _showPwd = false;

  Future<void> _seleccionarArchivo(String ext) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [ext],
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          if (ext == 'cer') {
            _pathCer = file.path;
            _nombreCer = file.name;
          } else {
            _pathKey = file.path;
            _nombreKey = file.name;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _continuar() {
    if (_pathCer != null && _pathKey != null && _pwdCtrl.text.isNotEmpty) {
      context.read<AppProvider>().setCertificados(
            cerPath: _pathCer!,
            keyPath: _pathKey!,
            password: _pwdCtrl.text,
          );
    }
    widget.next();
  }

  @override
  Widget build(BuildContext context) {
    final certificadosCompletos =
        _pathCer != null && _pathKey != null && _pwdCtrl.text.isNotEmpty;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    const Center(
                      child: Text(
                        'Certificados SAT',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 29),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Para timbrar facturas necesitas tu Certificado de Sello Digital (CSD).\n'
                          'Puedes omitirlo y configurarlo más adelante en Perfil.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Info box
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6DB1B1).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF6DB1B1).withOpacity(0.3)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Para timbrar necesitas:',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          SizedBox(height: 6),
                          Text('• Certificado .cer (Sello Digital)',
                              style: TextStyle(fontSize: 12)),
                          Text('• Llave privada .key', style: TextStyle(fontSize: 12)),
                          Text('• Contraseña de la llave privada',
                              style: TextStyle(fontSize: 12)),
                          Text('• RFC del emisor válido y activo en el SAT',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),

                    _FileSelector(
                      label: 'Certificado (.cer)',
                      ext: 'cer',
                      icon: LucideIcons.fileBadge,
                      nombre: _nombreCer,
                      onTap: () => _seleccionarArchivo('cer'),
                      onClear: () =>
                          setState(() => _nombreCer = _pathCer = null),
                    ),
                    const SizedBox(height: 14),

                    _FileSelector(
                      label: 'Llave privada (.key)',
                      ext: 'key',
                      icon: LucideIcons.keyRound,
                      nombre: _nombreKey,
                      onTap: () => _seleccionarArchivo('key'),
                      onClear: () =>
                          setState(() => _nombreKey = _pathKey = null),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: _pwdCtrl,
                      obscureText: !_showPwd,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Contraseña de la llave privada',
                        prefixIcon:
                            const Icon(LucideIcons.lock, size: 18),
                        suffixIcon: GestureDetector(
                          onTap: () =>
                              setState(() => _showPwd = !_showPwd),
                          child: Icon(
                            _showPwd ? LucideIcons.eyeOff : LucideIcons.eye,
                            size: 18,
                          ),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),

                    if (certificadosCompletos) ...[
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(LucideIcons.circleCheck,
                              size: 16, color: Color(0xFF3D8F8F)),
                          SizedBox(width: 6),
                          Text(
                            'Certificados listos para timbrar',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF3D8F8F),
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
                        onPressed: widget.guardando ? null : _continuar,
                        child: widget.guardando
                            ? const CupertinoActivityIndicator()
                            : Text(
                                certificadosCompletos
                                    ? 'Guardar y Continuar'
                                    : 'Omitir por ahora',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
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
    required this.label,
    required this.ext,
    required this.icon,
    required this.nombre,
    required this.onTap,
    required this.onClear,
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
                : Theme.of(context).shadowColor.withOpacity(0.4),
            width: cargado ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: cargado
              ? const Color(0xFF6DB1B1).withOpacity(0.06)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: cargado
                    ? const Color(0xFF6DB1B1)
                    : Theme.of(context).hintColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              Theme.of(context).hintColor.withOpacity(0.7))),
                  Text(
                    cargado
                        ? nombre!
                        : 'Toca para seleccionar archivo .$ext',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          cargado ? FontWeight.w600 : FontWeight.normal,
                      color: cargado
                          ? const Color(0xFF3D8F8F)
                          : Theme.of(context).hintColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (cargado)
              GestureDetector(
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child:
                      Icon(LucideIcons.x, size: 16, color: Colors.grey),
                ),
              )
            else
              Icon(LucideIcons.upload,
                  size: 16, color: Theme.of(context).hintColor),
          ],
        ),
      ),
    );
  }
}
