import 'package:cotizadeprisa/app/models/cotizacion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cotizadeprisa/app/models/factura.dart';
import 'package:cotizadeprisa/app/providers/app_provider.dart';
import 'package:cotizadeprisa/app/screens/cotizacionDetalle.dart';
import 'package:cotizadeprisa/app/screens/facturacionPage.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';


class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});
  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.toLowerCase()));
  }

  @override
  void dispose() {
    _tabController.dispose(); _searchCtrl.dispose(); super.dispose();
  }

  Future<void> _recargarDesdeFirebase(BuildContext context) async {
    final provider = context.read<AppProvider>();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await provider.init(user);
    }
    await Future.delayed(const Duration(milliseconds: 400));
  }

  List<Cotizacion> _filtrarCots(List<Cotizacion> list) {
    if (_query.isEmpty) return list;
    return list.where((c) =>
        c.titulo.toLowerCase().contains(_query) ||
        c.clienteNombre.toLowerCase().contains(_query) ||
        c.asunto.toLowerCase().contains(_query) ||
        c.id.toLowerCase().contains(_query)).toList();
  }

  List<Factura> _filtrarFacts(List<Factura> list) {
    if (_query.isEmpty) return list;
    return list.where((f) =>
        f.nombreReceptor.toLowerCase().contains(_query) ||
        f.rfcReceptor.toLowerCase().contains(_query) ||
        (f.uuid?.toLowerCase().contains(_query) ?? false) ||
        f.id.toLowerCase().contains(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final cotizaciones = _filtrarCots(provider.cotizaciones);
    final facturas     = _filtrarFacts(provider.facturas);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Historial',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            tooltip: 'Actualizar',
            onPressed: () {
              setState(() {}); // fuerza repintado visual
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lista actualizada'),
                    duration: Duration(seconds: 1),
                    backgroundColor: Color(0xFF6DB1B1)),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          indicatorColor: const Color(0xFF6DB1B1),
          labelColor: const Color(0xFF6DB1B1),
          unselectedLabelColor: const Color(0xFF919191),
          tabs: [
            Tab(text: 'Cotizaciones (${provider.cotizaciones.length})'),
            Tab(text: 'Facturas (${provider.facturas.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
                decoration: const InputDecoration(
                  prefixIcon: Icon(LucideIcons.search, color: Color(0xFF919191), size: 18),
                  hintText: 'Buscar...',
                  hintStyle: TextStyle(color: Color(0xFF919191), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCotizacionesList(cotizaciones, provider.isLoading),

                _buildFacturasList(facturas, provider.isLoading),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCotizacionesList(List<Cotizacion> list, bool loading) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (list.isEmpty) return _empty('No hay cotizaciones', LucideIcons.fileText);
    return RefreshIndicator(
      onRefresh: () => _recargarDesdeFirebase(context),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: list.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: const Color(0xFF919191).withOpacity(0.15)),
        itemBuilder: (_, i) => _CotizacionItem(
          cot: list[i],
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CotizacionDetallePage(cot: list[i]))),
        ),
      ),
    );
  }

  Widget _buildFacturasList(List<Factura> list, bool loading) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (list.isEmpty) {
      return _empty(
        'No hay facturas\nPresiona "Facturar" en una cotización para generar una',
        LucideIcons.receiptText);
    }
    return RefreshIndicator(
      onRefresh: () => _recargarDesdeFirebase(context),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: list.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: const Color(0xFF919191).withOpacity(0.15)),
        itemBuilder: (_, i) {
          final factura = list[i];
          final cotizacion = context.read<AppProvider>().cotizaciones
              .where((c) => c.id == factura.cotizacionId)
              .firstOrNull;
          return _FacturaItem(
            factura: factura,
            onTap: () {
              if (cotizacion != null) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => FacturacionPage(
                        cotizacion: cotizacion, facturaExistente: factura)));
              }
            },
          );
        },
      ),
    );
  }

  Widget _empty(String msg, IconData icon) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 48, color: const Color(0xFF919191).withOpacity(0.4)),
      const SizedBox(height: 12),
      Text(msg, textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF919191), fontFamily: 'Inter')),
    ]),
  );
}


class _CotizacionItem extends StatelessWidget {
  final Cotizacion cot;
  final VoidCallback onTap;
  const _CotizacionItem({required this.cot, required this.onTap});

  Color get _statusColor {
    switch (cot.estatus) {
      case EstadoCotizacion.facturada: return const Color(0xFF3D8F8F);
      case EstadoCotizacion.aceptada:  return Colors.green;
      case EstadoCotizacion.rechazada: return Colors.red;
      case EstadoCotizacion.enviada:   return Colors.blue;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 78, color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(LucideIcons.fileText, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cot.titulo.isNotEmpty ? cot.titulo : cot.asunto,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
              const SizedBox(height: 2),
              Text(
                cot.clienteNombre.isNotEmpty
                    ? '${cot.clienteNombre}  ·  ${cot.fecha}'
                    : cot.fecha,
                style: const TextStyle(fontSize: 11, color: Color(0xFF919191), fontFamily: 'Inter'),
              ),
            ],
          )),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(cot.totalFormateado,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(cot.estatus.displayName,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
              ),
            ],
          ),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Color(0xFF919191)),
        ]),
      ),
    );
  }
}


class _FacturaItem extends StatelessWidget {
  final Factura factura;
  final VoidCallback onTap;
  const _FacturaItem({required this.factura, required this.onTap});

  Color get _color {
    switch (factura.estatus) {
      case EstadoFactura.timbrado: return const Color(0xFF3D8F8F);
      case EstadoFactura.borrador: return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 86, color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              factura.estatus == EstadoFactura.timbrado
                  ? LucideIcons.badgeCheck
                  : LucideIcons.receiptText,
              size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(factura.nombreReceptor.isNotEmpty ? factura.nombreReceptor : 'Sin receptor',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
              const SizedBox(height: 1),
              Text('RFC: ${factura.rfcReceptor}  ·  ${factura.fecha}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF919191), fontFamily: 'Inter')),
              if (factura.uuid != null)
                Text('UUID: ${factura.uuid!.substring(0, 8)}...',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF6DB1B1), fontFamily: 'Inter')),
            ],
          )),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(factura.totalFormateado,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(factura.estatus.displayName,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
              ),
            ],
          ),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Color(0xFF919191)),
        ]),
      ),
    );
  }
}
