import 'package:cotizadeprisa/app/models/cotizacion.dart';
import 'package:cotizadeprisa/app/screens/invoiceDetails.dart';
import 'package:cotizadeprisa/app/widgets/historialListItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';



//Poder ver estatus de la cotizacion (facturacion o timbrado, aceptado por cliente, rechazado, pendiente)




const _mockActivas = [
  Cotizacion(
    id: 'COT-001',
    titulo: 'Cotización #001 - Diseño UI',
    fecha: '15 Oct 2023',
    cliente: 'Empresa ABC S.A.',
    rfcCliente: 'ABC010101XYZ',
    asunto: 'Diseño de interfaces para aplicación móvil',
    total: '\$3,000.00',
    estatus: EstadoCotizacion.pendienteDeAceptar,
    productos: [
      {'nombre': 'Servicio de Diseño UI', 'cantidad': '2', 'precio': '\$1,500.00', 'subtotal': '\$3,000.00'},
    ],
  ),
  Cotizacion(
    id: 'COT-002',
    titulo: 'Cotización #002 - Desarrollo App',
    fecha: '18 Oct 2023',
    cliente: 'Grupo XYZ',
    rfcCliente: 'GXY020202ABC',
    asunto: 'Desarrollo de aplicación móvil iOS/Android',
    total: '\$25,000.00',
    estatus: EstadoCotizacion.aceptada,
    productos: [
      {'nombre': 'Desarrollo Frontend', 'cantidad': '1', 'precio': '\$15,000.00', 'subtotal': '\$15,000.00'},
      {'nombre': 'Desarrollo Backend', 'cantidad': '1', 'precio': '\$10,000.00', 'subtotal': '\$10,000.00'},
    ],
  ),
  Cotizacion(
    id: 'COT-003',
    titulo: 'Cotización #003 - Mantenimiento',
    fecha: '22 Oct 2023',
    cliente: 'Comercial Norte',
    rfcCliente: 'CNO030303DEF',
    asunto: 'Mantenimiento mensual de sistemas',
    total: '\$4,500.00',
    estatus: EstadoCotizacion.facturada,
    productos: [
      {'nombre': 'Soporte técnico', 'cantidad': '3', 'precio': '\$1,500.00', 'subtotal': '\$4,500.00'},
    ],
  ),
];

const _mockArchivadas = [
  Cotizacion(
    id: 'COT-000',
    titulo: 'Cotización #000 - Proyecto Alfa',
    fecha: '01 Sep 2023',
    cliente: 'Proyecto Alfa S.C.',
    rfcCliente: 'PAL010203GHI',
    asunto: 'Consultoría de infraestructura cloud',
    total: '\$12,000.00',
    estatus: EstadoCotizacion.rechazada,
    productos: [
      {'nombre': 'Consultoría', 'cantidad': '4', 'precio': '\$3,000.00', 'subtotal': '\$12,000.00'},
    ],
  ),
  Cotizacion(
    id: 'COT-007',
    titulo: 'Cotización #007 - Propuesta Beta',
    fecha: '10 Sep 2023',
    cliente: 'Beta Innovaciones',
    rfcCliente: 'BIN070910JKL',
    asunto: 'Propuesta de integración de sistemas',
    total: '\$8,200.00',
    estatus: EstadoCotizacion.pagada,
    productos: [
      {'nombre': 'Integración API', 'cantidad': '1', 'precio': '\$8,200.00', 'subtotal': '\$8,200.00'},
    ],
  ),
];

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  bool _isActivos = true;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Cotizacion> get _filtered {
    final source = _isActivos ? _mockActivas : _mockArchivadas;
    if (_query.isEmpty) return source;
    return source.where((c) => c.titulo.toLowerCase().contains(_query)).toList();
  }

  void _openDetalle(Cotizacion cot) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => CotizacionDetallePage(cot: cot)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Historial',
          style: TextStyle(fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFEFEFEF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(LucideIcons.search, color: Color(0xFF919191), size: 18),
                          hintText: 'Buscar',
                          hintStyle: TextStyle(color: Color(0xFF919191), fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => showCupertinoDialog(
                      context: context,
                      builder: (_) => CupertinoAlertDialog(
                        title: const Text('Filtros'),
                        content: const Text(
                          'Al presionar este botón se abrirán opciones de filtrado por fecha, monto o cliente. Funcionalidad pendiente.',
                        ),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Entendido'),
                          ),
                        ],
                      ),
                    ),
                    child: const Icon(LucideIcons.slidersHorizontal, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  _buildTab('Activos', _isActivos),
                  const SizedBox(width: 10),
                  _buildTab('Archivados', !_isActivos),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: _filtered.isEmpty
                    ? const Center(
                        child: Text('No se encontraron cotizaciones.',
                            style: TextStyle(color: Color(0xFF919191))),
                      )
                    : ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: const Color(0xFF919191).withAlpha((0.15 * 255).toInt()),
                        ),
                        itemBuilder: (_, i) {
                          final cot = _filtered[i];
                          return HistorialListItem(
                            cot: cot,
                            onTap: () => _openDetalle(cot),
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

  Widget _buildTab(String text, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isActivos = text == 'Activos'),
        child: Container(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 2,
                  color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
                ),
              ),
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: isActive ? Theme.of(context).primaryColor : const Color(0xFF919191),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
