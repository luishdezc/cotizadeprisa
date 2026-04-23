import 'package:cotizadeprisa/app/models/cotizacion.dart';
import 'package:cotizadeprisa/app/widgets/customCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CotizacionDetallePage extends StatelessWidget {
  final Cotizacion cot;

  const CotizacionDetallePage({super.key, required this.cot});

  void _pendingAlert(BuildContext context, String titulo, String mensaje) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cot.id, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            CustomCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Datos del receptor', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  
                  StatusBadge(cot: cot)
                  
                ],
              ),
            ),
            const SizedBox(height: 16),

            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Datos de la cotización', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Folio',  value: cot.id),
                  _DetailRow(label: 'Fecha',  value: cot.fecha),
                  _DetailRow(label: 'Asunto', value: cot.asunto),
                  _DetailRow(label: 'Total',  value: cot.total),
                ],
              ),
            ),
            const SizedBox(height: 16),

            CustomCard(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Datos del receptor', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Cliente', value: cot.cliente),
                  _DetailRow(label: 'RFC',     value: cot.rfcCliente),
                ],
              ),
            ),
            const SizedBox(height: 16),

            CustomCard(
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Productos", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(flex: 4, child: Text('Concepto',   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF919191)))),
                        Expanded(flex: 1, child: Text('Cant.',      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF919191)), textAlign: TextAlign.center)),
                        Expanded(flex: 2, child: Text('Precio',     style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF919191)), textAlign: TextAlign.right)),
                        Expanded(flex: 2, child: Text('Subtotal',   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF919191)), textAlign: TextAlign.right)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  ...cot.productos.map((p) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(flex: 4, child: Text(p['nombre']!, style: const TextStyle(fontSize: 13))),
                        Expanded(flex: 1, child: Text(p['cantidad']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
                        Expanded(flex: 2, child: Text(p['precio']!, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13))),
                        Expanded(flex: 2, child: Text(p['subtotal']!, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                      ],
                    ),
                  )),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Total: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      Text(cot.total, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF3D8F8F))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            _ActionButton(
              icon: LucideIcons.receipt,
              label: 'Facturar',
              description: 'Generar factura CFDI a partir de esta cotización',
              color: const Color(0xFF6DB1B1),
              onTap: () => _pendingAlert(
                context,
                'Facturar cotización',
                'Al presionar este botón se generará una factura CFDI a partir de los datos de esta cotización y del receptor. Funcionalidad pendiente.',
              ),
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: LucideIcons.badgeCheck,
              label: 'Timbrar',
              description: 'Enviar la factura al SAT para su certificación fiscal',
              color: const Color(0xFFFDAA29),
              onTap: () => _pendingAlert(
                context,
                'Timbrar factura',
                'Al presionar este botón se enviará la factura CFDI al SAT para su timbrado y se obtendrá el UUID fiscal. Funcionalidad pendiente.',
              ),
            ),
            const SizedBox(height: 12),

            _ActionButton(
              icon: LucideIcons.fileDown,
              label: 'Descargar PDF',
              description: 'Exportar esta cotización como documento PDF',
              color: Colors.redAccent,
              onTap: () => _pendingAlert(
                context,
                'Descargar PDF',
                'Al presionar este botón se generará y descargará el PDF de la cotización. Funcionalidad pendiente.',
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.cot,
  });

  final Cotizacion cot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFA5D9D9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          width: 1,
          color: Colors.green,
        )
      ),
      child: Text(
        cot.estatus.displayName.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }
}











class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF919191))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}










class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha((0.3 * 255).toInt()),),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha((0.15 * 255).toInt()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: color)),
                  const SizedBox(height: 2),
                  Text(description, style: const TextStyle(fontSize: 12, color: Color(0xFF919191))),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 14, color: color.withAlpha((0.6 * 255).toInt()),),
          ],
        ),
      ),
    );
  }
}
