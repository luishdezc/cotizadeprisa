
import 'package:cotizadeprisa/app/config/app_config.dart';
import 'package:cotizadeprisa/app/models/factura.dart';
import 'package:cotizadeprisa/app/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';


class SatPage extends StatelessWidget {
  const SatPage({super.key});

  static bool get _facturapiConfigurado =>
      AppConfig.facturapiApiKey.isNotEmpty &&
      !AppConfig.facturapiApiKey.contains('TU_USUARIO');

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<AppProvider>();
    final perfil    = provider.perfil;
    final rfc       = perfil?.rfc.isNotEmpty == true ? perfil!.rfc : 'RFC no configurado';
    final timbradas = provider.facturas.where((f) => f.estaTimbrada).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('SAT', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
      ),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF6DB1B1), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(LucideIcons.landmark, color: Colors.white, size: 28),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('RFC del emisor', style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Inter')),
                const SizedBox(height: 2),
                Text(rfc.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w700, fontFamily: 'Inter', letterSpacing: 1.1)),
              ])),
              if (_facturapiConfigurado)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(AppConfig.facturapiModoProduccion ? 'Facturapi' : 'Facturapi',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
            ]),
          ),
          const SizedBox(height: 16),

          Row(children: [
            _Stat('Timbradas', timbradas.length.toString(), LucideIcons.badgeCheck, const Color(0xFF6DB1B1)),
            const SizedBox(width: 12),
            _Stat('Facturas', provider.facturas.length.toString(), LucideIcons.receiptText, Colors.orange),
            const SizedBox(width: 12),
            _Stat('Cotizaciones', provider.cotizaciones.length.toString(), LucideIcons.fileText, Colors.blueGrey),
          ]),
          const SizedBox(height: 20),

          Text('Facturas Timbradas', style: TextStyle(fontSize: 16, fontFamily: 'Inter',
              fontWeight: FontWeight.w600, color: Theme.of(context).hintColor)),
          const SizedBox(height: 10),

          Expanded(child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : timbradas.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(LucideIcons.fileSearch, size: 48,
                      color: const Color(0xFF919191).withOpacity(0.4)),
                  const SizedBox(height: 12),
                  const Text('No hay facturas timbradas aún.\nTimbre desde Historial > Facturas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF919191), fontFamily: 'Inter')),
                ]))
              : ListView.separated(
                  itemCount: timbradas.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: const Color(0xFF919191).withOpacity(0.15)),
                  itemBuilder: (context, i) {
                    final f = timbradas[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                      leading: Container(width: 40, height: 40,
                        decoration: BoxDecoration(color: const Color(0xFF6DB1B1).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(LucideIcons.badgeCheck, color: Color(0xFF6DB1B1), size: 20)),
                      title: Text(f.nombreReceptor.isNotEmpty ? f.nombreReceptor : f.rfcReceptor,
                          style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14),
                          overflow: TextOverflow.ellipsis),
                      subtitle: Text(f.uuid != null ? 'UUID: ${f.uuid!.substring(0, 8)}...' : f.fecha,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF919191))),
                      trailing: Column(mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(f.totalFormateado, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 4),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFF6DB1B1).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Text('Timbrada', style: TextStyle(fontSize: 9,
                                fontWeight: FontWeight.w600, color: Color(0xFF3D8F8F)))),
                        ]),
                      onTap: () => _showDetail(context, f),
                    );
                  },
                ),
          ),
        ]),
      )),
    );
  }

  void _showDetail(BuildContext context, Factura f) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(f.nombreReceptor, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _DR('RFC Receptor', f.rfcReceptor),
          _DR('RFC Emisor', f.rfcEmisor),
          _DR('Total', f.totalFormateado),
          _DR('Fecha', f.fecha),
          if (f.uuid != null) _DR('UUID', f.uuid!),
          if (f.facturapiId != null) _DR('ID Facturapi', f.facturapiId!),
          const SizedBox(height: 16),
          if (f.uuid != null)
            SizedBox(width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: f.uuid!));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('UUID copiado'), backgroundColor: const Color(0xFF6DB1B1)));
                },
                icon: const Icon(LucideIcons.copy),
                label: const Text('Copiar UUID', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6DB1B1),
                    foregroundColor: Colors.white, elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String l, v; final IconData icon; final Color color;
  const _Stat(this.l, this.v, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 6, offset: const Offset(0, 2))]),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(v, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        Text(l, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, fontFamily: 'Inter', color: Theme.of(context).hintColor)),
      ]),
    ),
  );
}

class _DR extends StatelessWidget {
  final String l, v;
  const _DR(this.l, this.v);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 90, child: Text(l, style: const TextStyle(fontSize: 13, color: Color(0xFF919191)))),
      Expanded(child: Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
    ]),
  );
}
