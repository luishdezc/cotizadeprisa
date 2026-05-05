import 'package:cotizadeprisa/app/widgets/customTextField.dart';
import 'package:cotizadeprisa/app/widgets/logoButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


class IntroPage3 extends StatelessWidget {
  final VoidCallback next;
  final TextEditingController usuarioController;
  final TextEditingController direccionController;
  final TextEditingController rfcController;
  final TextEditingController codigoPostalController; 
  final TextEditingController regimenFiscalController; 

  const IntroPage3({
    super.key,
    required this.next,
    required this.usuarioController,
    required this.direccionController,
    required this.rfcController,
    required this.codigoPostalController,
    required this.regimenFiscalController,
  });

  static const _regimenes = [
    ('601', 'General de Ley Personas Morales'),
    ('612', 'Personas Físicas con Actividades Empresariales y Profesionales'),
    ('626', 'Régimen Simplificado de Confianza'),
    ('606', 'Arrendamiento'),
    ('608', 'Demás ingresos'),
    ('605', 'Sueldos y Salarios'),
    ('621', 'Incorporación Fiscal'),
    ('616', 'Sin obligaciones fiscales'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset('assets/images/decorations/Third.png', width: 40),
          ),
          Center(
            child: SizedBox(
              width: 950,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const Center(
                      child: Text(
                        'Lo Legal',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 29),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Datos del emisor para tus facturas CFDI',
                        style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),

                    CustomTextField(
                      icon: LucideIcons.user,
                      name: 'Nombre Completo del representante',
                      variable: usuarioController,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      icon: LucideIcons.mapPin,
                      name: 'Dirección fiscal',
                      variable: direccionController,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      icon: LucideIcons.idCardLanyard,
                      name: 'RFC (emisor)',
                      variable: rfcController,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      icon: LucideIcons.mailbox,
                      name: 'Código Postal fiscal (5 dígitos)',
                      variable: codigoPostalController,
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                    ),
                    const SizedBox(height: 20),

                    _RegimenFiscalDropdown(
                      controller: regimenFiscalController,
                      regimenes: _regimenes,
                    ),
                    const SizedBox(height: 20),

                    const LogoButton(),
                    const SizedBox(height: 8),
                    const Text(
                      'Se podrá editar más adelante',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: Theme.of(context).canvasColor,
                        onPressed: next,
                        child: const Text(
                          'Continuar',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
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

class _RegimenFiscalDropdown extends StatefulWidget {
  final TextEditingController controller;
  final List<(String, String)> regimenes;

  const _RegimenFiscalDropdown({
    required this.controller,
    required this.regimenes,
  });

  @override
  State<_RegimenFiscalDropdown> createState() => _RegimenFiscalDropdownState();
}

class _RegimenFiscalDropdownState extends State<_RegimenFiscalDropdown> {
  late String _seleccionado;

  @override
  void initState() {
    super.initState();
    _seleccionado = widget.controller.text.isNotEmpty
        ? widget.controller.text
        : widget.regimenes.first.$1;
    widget.controller.text = _seleccionado;
  }

  @override
  Widget build(BuildContext context) {
    final desc = widget.regimenes
        .firstWhere(
          (r) => r.$1 == _seleccionado,
          orElse: () => widget.regimenes.first,
        )
        .$2;

    return GestureDetector(
      onTap: () => _mostrarPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).shadowColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.landmark, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Régimen Fiscal',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    '$_seleccionado - $desc',
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronDown, size: 16),
          ],
        ),
      ),
    );
  }

  void _mostrarPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Selecciona tu régimen fiscal'),
        actions: widget.regimenes
            .map((r) => CupertinoActionSheetAction(
                  onPressed: () {
                    setState(() {
                      _seleccionado = r.$1;
                      widget.controller.text = r.$1;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('${r.$1} – ${r.$2}'),
                ))
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: const Text('Cancelar'),
        ),
      ),
    );
  }
}
