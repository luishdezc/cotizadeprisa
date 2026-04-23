import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SatPage extends StatefulWidget {
  const SatPage({super.key});

  @override
  State<SatPage> createState() => _SatPageState();
}

class _SatPageState extends State<SatPage> {
  final List<Map<String, dynamic>> _declaraciones = [
    {'periodo': 'Febrero 2025',  'tipo': 'ISR Mensual', 'estatus': 'Presentada', 'fecha': '17 Feb 2025', 'importe': '\$3,200.00'},
    {'periodo': 'Enero 2025',    'tipo': 'ISR Mensual', 'estatus': 'Presentada', 'fecha': '16 Ene 2025', 'importe': '\$4,750.00'},
    {'periodo': 'Diciembre 2024','tipo': 'IVA Mensual', 'estatus': 'Pendiente',  'fecha': '—', 'importe': '—'},
    {'periodo': 'Noviembre 2024','tipo': 'ISR Mensual', 'estatus': 'Presentada', 'fecha': '18 Nov 2024', 'importe': '\$2,900.00'},
  ];

  void _pendingAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Funcionalidad pendiente'),
        content: Text(message),
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
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'SAT',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner RFC
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6DB1B1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.landmark, color: Colors.white, size: 28),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RFC registrado',
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Inter')),
                        SizedBox(height: 2),
                        Text('XAXX010101000',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                                letterSpacing: 1.1)),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _pendingAlert(
                        'Al presionar este botón, se actualizará el RFC vinculado con el SAT. Funcionalidad pendiente.',
                      ),
                      child: const Icon(LucideIcons.pencil, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  _QuickAction(
                    icon: LucideIcons.cloudUpload,
                    label: 'Presentar\nDeclaración',
                    onTap: () => _pendingAlert(
                      'Al presionar este botón, se presentará una declaración ante el SAT. Funcionalidad pendiente.',
                    ),
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    icon: LucideIcons.fileScan,
                    label: 'Descargar\nAcuse',
                    onTap: () => _pendingAlert(
                      'Al presionar este botón, se descargará el acuse de la declaración seleccionada. Funcionalidad pendiente.',
                    ),
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    icon: LucideIcons.refreshCcw,
                    label: 'Sincronizar\nSAT',
                    onTap: () => _pendingAlert(
                      'Al presionar este botón, se sincronizarán las facturas emitidas con el SAT. Funcionalidad pendiente.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                'Declaraciones',
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).hintColor),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: ListView.separated(
                  itemCount: _declaraciones.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: const Color(0xFF919191).withValues(alpha: 0.15),
                  ),
                  itemBuilder: (context, index) {
                    final d = _declaraciones[index];
                    return _DeclaracionListItem(
                      periodo: d['periodo'],
                      tipo: d['tipo'],
                      estatus: d['estatus'],
                      fecha: d['fecha'],
                      importe: d['importe'],
                      onTap: () => _showDeclaracionDetail(d),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeclaracionDetail(Map<String, dynamic> d) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(d['periodo'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                _EstatusChip(estatus: d['estatus']),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(label: 'Tipo',    value: d['tipo']),
            _DetailRow(label: 'Fecha',   value: d['fecha']),
            _DetailRow(label: 'Importe', value: d['importe']),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _pendingAlert(
                    'Al presionar este botón, se descargará el acuse de recibo de la declaración. Funcionalidad pendiente.',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6DB1B1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                icon: const Icon(LucideIcons.download),
                label: const Text('Descargar Acuse',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Theme.of(context).shadowColor.withAlpha(25), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF6DB1B1), size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeclaracionListItem extends StatelessWidget {
  final String periodo;
  final String tipo;
  final String estatus;
  final String fecha;
  final String importe;
  final VoidCallback onTap;

  const _DeclaracionListItem({
    required this.periodo,
    required this.tipo,
    required this.estatus,
    required this.fecha,
    required this.importe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFA5D9D9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(LucideIcons.fileText, color: Colors.white, size: 20),
        ),
      ),
      title: Text(
        '$periodo · $tipo',
        style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(fecha,
          style: const TextStyle(fontSize: 12, color: Color(0xFF919191))),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(importe,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 4),
          _EstatusChip(estatus: estatus),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _EstatusChip extends StatelessWidget {
  final String estatus;
  const _EstatusChip({required this.estatus});

  @override
  Widget build(BuildContext context) {
    final isPending = estatus == 'Pendiente';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPending
            ? Colors.orange.withValues(alpha: 0.12)
            : const Color(0xFF6DB1B1).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estatus,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isPending ? Colors.orange.shade800 : const Color(0xFF3D8F8F),
        ),
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
            width: 70,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF919191), fontFamily: 'Inter')),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
