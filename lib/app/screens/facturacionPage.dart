import 'package:cotizadeprisa/app/models/cotizacion.dart';
import 'package:cotizadeprisa/app/models/factura.dart';
import 'package:cotizadeprisa/app/providers/app_provider.dart';
import 'package:cotizadeprisa/app/screens/pdfFactura.dart';
import 'package:cotizadeprisa/app/widgets/customCard.dart';
import 'package:cotizadeprisa/app/widgets/customTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


class FacturacionPage extends StatefulWidget {
  final Cotizacion cotizacion;
  final Factura? facturaExistente;
  const FacturacionPage(
      {super.key, required this.cotizacion, this.facturaExistente});
  @override
  State<FacturacionPage> createState() => _FacturacionPageState();
}

class _FacturacionPageState extends State<FacturacionPage> {
  final _rfcCtrl    = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _cpCtrl     = TextEditingController();

  String _regimenReceptor = '601';
  String _usoCfdi         = 'G03';
  String _formaPago       = '99';
  String _metodoPago      = 'PUE';
  String _moneda          = 'MXN';
  String _tipoComp        = 'I';

  Factura? _factura;
  bool _guardando = false;
  List<String> _camposFaltantes = [];

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  bool get _timbrada => _factura?.estaTimbrada == true;

  @override
  void initState() {
    super.initState();
    if (widget.facturaExistente != null) {
      _cargarFactura(widget.facturaExistente!);
    } else {
      _autocompletar();
    }
  }

  void _autocompletar() {
    final cot = widget.cotizacion;
    _nombreCtrl.text = cot.clienteNombre;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<AppProvider>();
      final cliente = provider.clientes
          .where((c) => c.id == cot.clienteId)
          .firstOrNull;
      if (cliente != null) {
        setState(() {
          if (_rfcCtrl.text.isEmpty && cliente.rfc.isNotEmpty)
            _rfcCtrl.text = cliente.rfc;
          if (_nombreCtrl.text.isEmpty && cliente.nombre.isNotEmpty)
            _nombreCtrl.text = cliente.nombre;
          if (_cpCtrl.text.isEmpty && cliente.codigoPostal.isNotEmpty)
            _cpCtrl.text = cliente.codigoPostal;
          if (cliente.regimenFiscal?.isNotEmpty == true)
            _regimenReceptor = cliente.regimenFiscal!;
          if (cliente.usoCfdi?.isNotEmpty == true)
            _usoCfdi = cliente.usoCfdi!;
        });
      }
    });
  }

  void _cargarFactura(Factura f) {
    _rfcCtrl.text    = f.rfcReceptor;
    _nombreCtrl.text = f.nombreReceptor;
    _cpCtrl.text     = f.codigoPostalReceptor;
    _regimenReceptor = f.regimenFiscalReceptor;
    _usoCfdi         = f.usoCfdi;
    _formaPago       = f.formaPago;
    _metodoPago      = f.metodoPago;
    _moneda          = f.moneda;
    _tipoComp        = f.tipoComprobante;
    _factura         = f;
  }

  @override
  void dispose() {
    _rfcCtrl.dispose(); _nombreCtrl.dispose(); _cpCtrl.dispose(); super.dispose();
  }

  bool _validar() {
    final faltantes = <String>[];

    final rfc = _rfcCtrl.text.trim();
    if (rfc.isEmpty) {
      faltantes.add('RFC del receptor');
    } else if (rfc.length < 12 || rfc.length > 13) {
      faltantes.add('RFC inválido (12–13 caracteres)');
    }
    if (_nombreCtrl.text.trim().isEmpty) faltantes.add('Nombre o razón social');
    if (_cpCtrl.text.trim().length != 5 ||
        int.tryParse(_cpCtrl.text.trim()) == null) {
      faltantes.add('Código postal (5 dígitos numéricos)');
    }

    final perfil = context.read<AppProvider>().perfil;
    if (perfil == null || perfil.rfc.isEmpty) {
      faltantes.add('RFC del emisor (configura tu perfil)');
    }
    if (perfil != null && perfil.codigoPostal.length != 5) {
      faltantes.add('Código postal del emisor (configura tu perfil)');
    }

    setState(() => _camposFaltantes = faltantes);
    return faltantes.isEmpty;
  }


  Future<Factura?> _obtenerOCrear() async {
    if (_factura != null) {
      final updated = _factura!.copyWith(
        rfcReceptor: _rfcCtrl.text.trim().toUpperCase(),
        nombreReceptor: _nombreCtrl.text.trim(),
        regimenFiscalReceptor: _regimenReceptor,
        codigoPostalReceptor: _cpCtrl.text.trim(),
        usoCfdi: _usoCfdi, formaPago: _formaPago,
        metodoPago: _metodoPago, moneda: _moneda, tipoComprobante: _tipoComp,
      );
      final ok = await context.read<AppProvider>().actualizarFactura(uid, updated);
      if (ok) { setState(() => _factura = updated); return updated; }
      return _factura;
    }

    final provider = context.read<AppProvider>();
    final perfil   = provider.perfil;
    if (perfil == null) { _snack('Configura el perfil primero'); return null; }

    final conceptos = widget.cotizacion.conceptos.map((c) => ConceptoFactura(
      nombre: c.nombre, descripcion: c.descripcion,
      precioUnitario: c.precioUnitario, cantidad: c.cantidad,
      descuentoPct: c.descuentoPct,
      claveProdServ: c.satKey.isNotEmpty ? c.satKey : '01010101',
      claveUnidad: ConceptoCotizacion.claveUnidadDefault,
    )).toList();

    final nueva = Factura(
      id: '', uid: uid, cotizacionId: widget.cotizacion.id,
      rfcEmisor: perfil.rfc, nombreEmisor: perfil.nombre,
      regimenFiscalEmisor: perfil.regimenFiscal,
      codigoPostalEmisor: perfil.codigoPostal,
      rfcReceptor: _rfcCtrl.text.trim().toUpperCase(),
      nombreReceptor: _nombreCtrl.text.trim(),
      regimenFiscalReceptor: _regimenReceptor,
      codigoPostalReceptor: _cpCtrl.text.trim(),
      usoCfdi: _usoCfdi, formaPago: _formaPago,
      metodoPago: _metodoPago, moneda: _moneda, tipoComprobante: _tipoComp,
      conceptos: conceptos, fecha: widget.cotizacion.fecha,
    );

    final creada = await provider.crearFactura(uid, nueva);
    if (creada != null) setState(() => _factura = creada);
    return creada;
  }


  Future<void> _timbrar() async {
    if (_timbrada) { _snack('Esta factura ya fue timbrada'); return; }
    if (!_validar()) return;

    final conf = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('¿Timbrar ante el SAT?'),
        content: const Text(
            'Se generará y timbrerá el CFDI ante el SAT.\n'
            'Una vez timbrada, la factura será inmutable.'),
        actions: [
          CupertinoDialogAction(isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Timbrar')),
        ],
      ),
    );
    if (conf != true) return;

    setState(() => _guardando = true);
    _showLoading('Timbrando…');

    final f = await _obtenerOCrear();
    if (f == null) {
      if (mounted) Navigator.of(context).pop();
      setState(() => _guardando = false);
      return;
    }

    final provider = context.read<AppProvider>();
    final result   = await provider.timbrarFactura(uid, f);

    if (mounted) Navigator.of(context).pop();
    setState(() => _guardando = false);
    if (!mounted) return;

    if (result.exito) {
      final updated = provider.facturas.where((fx) => fx.id == f.id).firstOrNull;
      if (updated != null) setState(() { _factura = updated; _camposFaltantes = []; });
      _ok('¡Factura timbrada!',
          'UUID: ${result.uuid ?? "N/A"}\n\nLa factura es válida ante el SAT.');
    } else {
      _err('Error al timbrar', result.error ?? 'Error desconocido');
    }
  }


  Future<void> _abrirPdf() async {
    final f = _factura;
    if (f == null) { _snack('Timbra la factura primero'); return; }

    if (f.pdfUrl != null && f.pdfUrl!.isNotEmpty) {
      final uri = Uri.tryParse(f.pdfUrl!);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    if (!mounted) return;
    Navigator.of(context).push(
        CupertinoPageRoute(builder: (_) => PdfFacturaPage(factura: f)));
  }


  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    final cot = widget.cotizacion;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Facturación CFDI 4.0',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          if (_timbrada) ...[
            _BannerTimbrado(factura: _factura!),
            const SizedBox(height: 16),
          ],

          if (_camposFaltantes.isNotEmpty && !_timbrada) ...[
            _BannerValidacion(campos: _camposFaltantes),
            const SizedBox(height: 16),
          ],

          CustomCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Cotización origen',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(cot.asunto,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            Text('${cot.conceptos.length} concepto(s)  ·  ${cot.totalFormateado}',
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ])),
          const SizedBox(height: 16),

          CustomCard(child: AbsorbPointer(
            absorbing: _timbrada,
            child: Opacity(opacity: _timbrada ? 0.6 : 1.0,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(LucideIcons.user, size: 15, color: Colors.grey),
                  const SizedBox(width: 6),
                  const Text('Receptor (CFDI)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (widget.facturaExistente == null && !_timbrada)
                    _ChipAutocompletado(),
                ]),
                const SizedBox(height: 4),
                if (!_timbrada)
                  const Text('Puedes editar los datos antes de timbrar.',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 14),
                _Campo(
                  faltante: _camposFaltantes.any((e) => e.toLowerCase().contains('rfc')),
                  child: CustomTextField(icon: LucideIcons.idCardLanyard,
                      name: 'RFC del receptor *', variable: _rfcCtrl,
                      textCapitalization: TextCapitalization.characters),
                ),
                const SizedBox(height: 12),
                _Campo(
                  faltante: _camposFaltantes.any((e) => e.toLowerCase().contains('nombre')),
                  child: CustomTextField(icon: LucideIcons.building,
                      name: 'Nombre / Razón social *', variable: _nombreCtrl),
                ),
                const SizedBox(height: 12),
                _Campo(
                  faltante: _camposFaltantes.any((e) => e.toLowerCase().contains('postal')),
                  child: CustomTextField(icon: LucideIcons.mailbox,
                      name: 'Código postal *', variable: _cpCtrl,
                      keyboardType: TextInputType.number, maxLength: 5),
                ),
                const SizedBox(height: 12),
                _Drop('Régimen fiscal receptor *', _regimenReceptor,
                  const [('601','General de Ley PM'),('612','Act. Emp. y Prof.'),
                         ('626','RESICO'),('616','Sin obligaciones'),
                         ('605','Sueldos'),('606','Arrendamiento'),('608','Demás ingresos')],
                  _timbrada ? null : (v) => setState(() => _regimenReceptor = v),
                  faltante: _camposFaltantes.any((e) => e.toLowerCase().contains('régimen'))),
              ]),
            ),
          )),
          const SizedBox(height: 16),

          CustomCard(child: AbsorbPointer(
            absorbing: _timbrada,
            child: Opacity(opacity: _timbrada ? 0.6 : 1.0,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(LucideIcons.receiptText, size: 15, color: Colors.grey),
                  const SizedBox(width: 6),
                  const Text('Datos del CFDI',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 12),
                _Drop('Uso CFDI *', _usoCfdi,
                  const [('G01','Adquisición de mercancias'),('G03','Gastos en general'),
                         ('P01','Por definir'),('I01','Construcciones'),
                         ('D01','Honorarios médicos'),('S01','Sin efectos fiscales')],
                  _timbrada ? null : (v) => setState(() => _usoCfdi = v),
                  faltante: _camposFaltantes.any((e) => e.toLowerCase().contains('uso'))),
                const SizedBox(height: 10),
                _Drop('Forma de pago', _formaPago,
                  const [('01','Efectivo'),('02','Cheque'),('03','Transferencia'),
                         ('04','T. Crédito'),('28','T. Débito'),('99','Por definir')],
                  _timbrada ? null : (v) => setState(() => _formaPago = v)),
                const SizedBox(height: 10),
                _Drop('Método de pago', _metodoPago,
                  const [('PUE','PUE – Una sola exhibición'),('PPD','PPD – Parcialidades')],
                  _timbrada ? null : (v) => setState(() => _metodoPago = v)),
                const SizedBox(height: 10),
                _Drop('Moneda', _moneda,
                  const [('MXN','MXN – Peso mexicano'),('USD','USD – Dólar'),('EUR','EUR – Euro')],
                  _timbrada ? null : (v) => setState(() => _moneda = v)),
                const SizedBox(height: 10),
                _Drop('Tipo comprobante', _tipoComp,
                  const [('I','I – Ingreso'),('E','E – Egreso'),('P','P – Pago')],
                  _timbrada ? null : (v) => setState(() => _tipoComp = v)),
              ]),
            ),
          )),
          const SizedBox(height: 16),

          CustomCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Conceptos',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey)),
            const SizedBox(height: 8),
            ...cot.conceptos.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.nombre, style: const TextStyle(fontSize: 13)),
                  Text(
                    'Clave SAT: ${c.satKey}  ·  ${c.subcategory.isNotEmpty ? c.subcategory : "Sin categoría"}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ])),
                Text('\$${fmt.format(c.subtotal)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            )),
            const Divider(),
            _TL('Subtotal', '\$${fmt.format(cot.subtotal)}'),
            _TL('IVA 16%', '\$${fmt.format(cot.totalIva)}'),
            _TL('Total', '\$${fmt.format(cot.total)}', bold: true),
          ])),
          const SizedBox(height: 24),

          _Btn(
            icon: _timbrada ? LucideIcons.badgeCheck : LucideIcons.stamp,
            label: _timbrada ? 'Factura Timbrada ✓' : '1. Timbrar Factura',
            sub: _timbrada
                ? 'UUID: ${_factura?.uuid?.substring(0, 8) ?? ""}...'
                : 'Genera y timbra el CFDI ante el SAT',
            color: _timbrada ? const Color(0xFF3D8F8F) : const Color(0xFF6DB1B1),
            disabled: _timbrada || _guardando,
            onTap: _timbrar,
          ),
          const SizedBox(height: 12),

          _Btn(
            icon: LucideIcons.fileDown,
            label: '2. Ver / Descargar PDF',
            sub: _timbrada
                ? 'PDF fiscal con UUID y datos SAT'
                : 'PDF borrador de la factura',
            color: Colors.redAccent,
            disabled: false,
            onTap: _abrirPdf,
          ),
          const SizedBox(height: 50),
        ]),
      ),
    );
  }


  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), duration: const Duration(seconds: 2)));

  void _showLoading(String m) => showDialog(
    context: context, barrierDismissible: false,
    builder: (_) => Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(color: Color(0xFF6DB1B1)),
          const SizedBox(height: 16), Text(m, textAlign: TextAlign.center),
        ]))),
  );

  void _ok(String t, String m) => showCupertinoDialog(context: context,
    builder: (_) => CupertinoAlertDialog(title: Text(t), content: Text(m),
      actions: [CupertinoDialogAction(
          onPressed: () => Navigator.pop(context), child: const Text('OK'))]),
  );

  void _err(String t, String m) => showCupertinoDialog(context: context,
    builder: (_) => CupertinoAlertDialog(title: Text(t), content: Text(m),
      actions: [CupertinoDialogAction(
          onPressed: () => Navigator.pop(context), child: const Text('Entendido'))]),
  );
}


class _BannerTimbrado extends StatelessWidget {
  final Factura factura;
  const _BannerTimbrado({required this.factura});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFF3D8F8F).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3D8F8F).withOpacity(0.35))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(LucideIcons.badgeCheck, color: Color(0xFF3D8F8F), size: 16),
        SizedBox(width: 8),
        Text('Factura timbrada — inmutable',
            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3D8F8F))),
      ]),
      if (factura.uuid != null) ...[
        const SizedBox(height: 4),
        Text('UUID: ${factura.uuid}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF3D8F8F))),
      ],
      if (factura.fechaTimbrado != null) ...[
        const SizedBox(height: 2),
        Text('Timbrada: ${factura.fechaTimbrado!.toLocal().toString().substring(0, 16)}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF3D8F8F))),
      ],
    ]),
  );
}

class _BannerValidacion extends StatelessWidget {
  final List<String> campos;
  const _BannerValidacion({required this.campos});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.4))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(LucideIcons.triangleAlert, color: Colors.orange, size: 16),
        SizedBox(width: 8),
        Text('Completa estos campos para timbrar:',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.orange, fontSize: 13)),
      ]),
      const SizedBox(height: 8),
      ...campos.map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('• ', style: TextStyle(color: Colors.orange, fontSize: 12)),
          Expanded(child: Text(c, style: const TextStyle(color: Colors.orange, fontSize: 12))),
        ]),
      )),
    ]),
  );
}

class _ChipAutocompletado extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: const Color(0xFF6DB1B1).withOpacity(0.12),
        borderRadius: BorderRadius.circular(10)),
    child: const Row(children: [
      Icon(LucideIcons.zap, size: 11, color: Color(0xFF3D8F8F)),
      SizedBox(width: 4),
      Text('Autocompletado', style: TextStyle(fontSize: 10, color: Color(0xFF3D8F8F),
          fontWeight: FontWeight.w600)),
    ]),
  );
}


class _Campo extends StatelessWidget {
  final bool faltante; final Widget child;
  const _Campo({required this.faltante, required this.child});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      child,
      if (faltante)
        Padding(padding: const EdgeInsets.only(top: 4, left: 4),
          child: Row(children: [
            const Icon(LucideIcons.circleAlert, size: 12, color: Colors.orange),
            const SizedBox(width: 4),
            const Text('Campo requerido',
                style: TextStyle(fontSize: 11, color: Colors.orange)),
          ])),
    ],
  );
}

class _TL extends StatelessWidget {
  final String l, v; final bool bold;
  const _TL(this.l, this.v, {this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: TextStyle(fontSize: bold ? 14 : 12,
          fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          color: bold ? null : Colors.grey)),
      Text(v, style: TextStyle(fontSize: bold ? 14 : 12,
          fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          color: bold ? const Color(0xFF6DB1B1) : null)),
    ]),
  );
}

class _Drop extends StatelessWidget {
  final String label, value;
  final List<(String, String)> items;
  final ValueChanged<String>? onChanged;
  final bool faltante;
  const _Drop(this.label, this.value, this.items, this.onChanged, {this.faltante = false});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        SizedBox(width: 128, child: Text(label,
            style: TextStyle(fontSize: 12,
                color: faltante ? Colors.orange : Colors.grey))),
        Expanded(child: DropdownButton<String>(
          value: items.any((e) => e.$1 == value) ? value : items.first.$1,
          isExpanded: true, underline: const SizedBox(),
          items: items.map((e) => DropdownMenuItem(value: e.$1,
              child: Text(e.$2, style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged == null ? null : (v) { if (v != null) onChanged!(v); },
        )),
      ]),
      if (faltante)
        Padding(padding: const EdgeInsets.only(top: 2, left: 4),
          child: Row(children: [
            const Icon(LucideIcons.circleAlert, size: 12, color: Colors.orange),
            const SizedBox(width: 4),
            const Text('Campo requerido',
                style: TextStyle(fontSize: 11, color: Colors.orange)),
          ])),
    ],
  );
}

class _Btn extends StatelessWidget {
  final IconData icon; final String label, sub; final Color color;
  final bool disabled; final VoidCallback onTap;
  const _Btn({required this.icon, required this.label, required this.sub,
      required this.color, this.disabled = false, required this.onTap});
  @override
  Widget build(BuildContext context) => Opacity(
    opacity: disabled ? 0.5 : 1.0,
    child: GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3))),
        child: Row(children: [
          Container(width: 44, height: 44,
              decoration: BoxDecoration(color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: color)),
            Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ])),
          Icon(LucideIcons.chevronRight, size: 14, color: color.withOpacity(0.6)),
        ]),
      ),
    ),
  );
}
