import 'package:cotizadeprisa/app/models/cotizacion.dart';
import 'package:cotizadeprisa/app/providers/app_provider.dart';
import 'package:cotizadeprisa/app/screens/facturacionPage.dart';
import 'package:cotizadeprisa/app/screens/newInvoice.dart';
import 'package:cotizadeprisa/app/screens/pdfInvoice.dart';
import 'package:cotizadeprisa/app/widgets/customCard.dart';
import 'package:cotizadeprisa/app/widgets/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';


class CotizacionDetallePage extends StatefulWidget {
  final Cotizacion cot;
  const CotizacionDetallePage({super.key, required this.cot});

  @override
  State<CotizacionDetallePage> createState() => _CotizacionDetallePageState();
}

class _CotizacionDetallePageState extends State<CotizacionDetallePage> {
  late Cotizacion _cot;

  @override
  void initState() {
    super.initState();
    _cot = widget.cot;
  }


  void _sincronizar(BuildContext context) {
    final provider = context.read<AppProvider>();
    final actualizada = provider.cotizaciones
        .where((c) => c.id == _cot.id)
        .firstOrNull;
    if (actualizada == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    if (actualizada != _cot) {
      setState(() => _cot = actualizada);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt      = NumberFormat('#,##0.00');
    final uid      = FirebaseAuth.instance.currentUser?.uid ?? '';
    final provider = context.watch<AppProvider>();

    final fromStream = provider.cotizaciones
        .where((c) => c.id == _cot.id)
        .firstOrNull;
    final cot = fromStream ?? _cot;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          cot.titulo.isNotEmpty ? cot.titulo : 'Cotización',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            tooltip: 'Actualizar',
            onPressed: () => _sincronizar(context),
          ),
          if (cot.estatus.editable)
            IconButton(
              icon: const Icon(LucideIcons.pencil),
              tooltip: 'Editar',
              onPressed: () => Navigator.of(context).push(
                CupertinoPageRoute(builder: (_) => NewInvoicePage(editando: cot)),
              ),
            ),
          if (cot.estatus.editable)
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: Colors.red),
              tooltip: 'Eliminar',
              onPressed: () => _confirmarEliminar(context, uid, provider),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _StatusBadge(estatus: cot.estatus),
          ),
          const SizedBox(height: 16),

          CustomCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Cotización',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _R('Fecha', cot.fecha),
            _R('Asunto', cot.asunto),
            if (cot.clienteNombre.isNotEmpty) _R('Cliente', cot.clienteNombre),
            if (cot.clienteCorreo.isNotEmpty) _R('Correo', cot.clienteCorreo),
          ])),
          const SizedBox(height: 14),

          CustomCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Conceptos',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Row(children: [
              Expanded(flex: 4, child: Text('Descripción',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600))),
              Expanded(flex: 1, child: Text('Cant.',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('Precio',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right)),
              Expanded(flex: 2, child: Text('Subtotal',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right)),
            ]),
            const Divider(height: 12),
            ...cot.conceptos.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.nombre, style: const TextStyle(fontSize: 13)),
                  if (c.descripcion.isNotEmpty)
                    Text(c.descripcion, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  if (c.descuentoPct > 0)
                    Text('Descuento: ${c.descuentoPct.toInt()}%',
                        style: const TextStyle(fontSize: 10, color: Colors.orange)),
                ])),
                Expanded(flex: 1, child: Text(c.cantidad.toString(),
                    style: const TextStyle(fontSize: 13), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('\$${fmt.format(c.precioUnitario)}',
                    style: const TextStyle(fontSize: 13), textAlign: TextAlign.right)),
                Expanded(flex: 2, child: Text('\$${fmt.format(c.subtotal)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.right)),
              ]),
            )),
            const Divider(),
            _TL('Subtotal', '\$${fmt.format(cot.subtotal)}'),
            _TL('IVA (${cot.tasaIva.toInt()}%)', '\$${fmt.format(cot.totalIva)}'),
            const SizedBox(height: 4),
            _TL('Total', '\$${fmt.format(cot.total)}', bold: true),
          ])),
          const SizedBox(height: 24),

          if (cot.estatus != EstadoCotizacion.facturada)
            _ActionBtn(
              icon: LucideIcons.receiptText,
              label: 'Facturar',
              description: 'Generar CFDI fiscal a partir de esta cotización',
              color: const Color(0xFF6DB1B1),
              onTap: () => Navigator.of(context).push(
                CupertinoPageRoute(
                    builder: (_) => FacturacionPage(cotizacion: cot))),
            )
          else
            _ActionBtn(
              icon: LucideIcons.badgeCheck,
              label: 'Ver factura asociada',
              description: 'Esta cotización ya fue facturada',
              color: const Color(0xFF3D8F8F),
              onTap: () {
                final factura = provider.facturas
                    .where((f) => f.cotizacionId == cot.id)
                    .firstOrNull;
                if (factura != null && context.mounted) {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (_) => FacturacionPage(
                          cotizacion: cot, facturaExistente: factura)));
                }
              },
            ),
          const SizedBox(height: 12),

          _ActionBtn(
            icon: LucideIcons.printer,
            label: 'Imprimir cotización',
            description: 'Exportar PDF del documento comercial',
            color: Colors.blueGrey,
            onTap: () => _imprimirPdf(context, cot),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  void _imprimirPdf(BuildContext context, Cotizacion cot) {
    final products = cot.conceptos.map((c) => Product(
      nombre: c.nombre, precioIndividual: c.precioUnitario.toString(),
      cantidadInicial: c.cantidad.toString(), descuento: c.descuentoPct.toString(),
      descripcion: c.descripcion,
    )).toList();
    final logoPath = context.read<AppProvider>().logoPath;
    displayPdf(context,
      id: cot.id, motivo: cot.asunto, fecha: cot.fecha,
      cliente: cot.clienteNombre, rfcCliente: '',
      total: cot.totalFormateado, productos: products,
      logoPath: logoPath);
  }

  Future<void> _confirmarEliminar(
      BuildContext context, String uid, AppProvider provider) async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('¿Eliminar cotización?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          CupertinoDialogAction(isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await provider.eliminarCotizacion(uid, _cot.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}


class _R extends StatelessWidget {
  final String l, v;
  const _R(this.l, this.v);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 80,
          child: Text(l, style: const TextStyle(fontSize: 13, color: Colors.grey))),
      Expanded(child: Text(v,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
    ]),
  );
}

class _TL extends StatelessWidget {
  final String l, v; final bool bold;
  const _TL(this.l, this.v, {this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: TextStyle(fontSize: bold ? 15 : 13,
          fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          color: bold ? null : Colors.grey)),
      Text(v, style: TextStyle(fontSize: bold ? 15 : 13,
          fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          color: bold ? const Color(0xFF6DB1B1) : null)),
    ]),
  );
}

class _StatusBadge extends StatelessWidget {
  final EstadoCotizacion estatus;
  const _StatusBadge({required this.estatus});
  Color get _c {
    switch (estatus) {
      case EstadoCotizacion.facturada: return const Color(0xFF3D8F8F);
      case EstadoCotizacion.aceptada:  return Colors.green;
      case EstadoCotizacion.rechazada: return Colors.red;
      case EstadoCotizacion.enviada:   return Colors.blue;
      default: return Colors.orange;
    }
  }
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: _c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _c.withOpacity(0.4))),
    child: Text(estatus.displayName.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _c)),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon; final String label, description;
  final Color color; final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label,
      required this.description, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Container(width: 42, height: 42,
          decoration: BoxDecoration(color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: color)),
          Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ])),
        Icon(LucideIcons.chevronRight, size: 14, color: color.withOpacity(0.6)),
      ]),
    ),
  );
}
