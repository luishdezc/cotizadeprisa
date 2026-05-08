import 'package:cotizadeprisa/app/models/cliente.dart';
import 'package:cotizadeprisa/app/models/cotizacion.dart';
import 'package:cotizadeprisa/app/providers/app_provider.dart';
import 'package:cotizadeprisa/app/screens/selectClient.dart';
import 'package:cotizadeprisa/app/screens/cotizacionDetalle.dart';
import 'package:cotizadeprisa/app/widgets/clientSelectionButton.dart';
import 'package:cotizadeprisa/app/widgets/customButon.dart';
import 'package:cotizadeprisa/app/widgets/customCard.dart';
import 'package:cotizadeprisa/app/widgets/customTextField.dart';
import 'package:cotizadeprisa/app/widgets/dateTextField.dart';
import 'package:cotizadeprisa/app/widgets/productsBottomSheetModal.dart';
import 'package:cotizadeprisa/app/widgets/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';


class NewInvoicePage extends StatefulWidget {
  final Cotizacion? editando;
  const NewInvoicePage({super.key, this.editando});
  @override
  State<NewInvoicePage> createState() => _NewInvoicePageState();
}

class _NewInvoicePageState extends State<NewInvoicePage> {
  final _tituloCtrl = TextEditingController();
  final _asuntoCtrl = TextEditingController();
  final _fechaCtrl  = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  final _focusScope = FocusScopeNode();

  Cliente? _cliente;
  List<Product> _products = [];
  bool _guardando = false;

  bool get _esEdicion => widget.editando != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) _cargarEdicion();
  }

  void _cargarEdicion() {
    final c = widget.editando!;
    _tituloCtrl.text = c.titulo;
    _asuntoCtrl.text = c.asunto;
    _fechaCtrl.text  = c.fecha;
    _products = c.conceptos.map((con) => Product(
      nombre: con.nombre, precioIndividual: con.precioUnitario.toString(),
      cantidadInicial: con.cantidad.toString(), descuento: con.descuentoPct.toString(),
      descripcion: con.descripcion,
      category: con.category,
      subcategory: con.subcategory,
      satKey: con.satKey,
    )).toList();
  }

  @override
  void dispose() {
    _tituloCtrl.dispose(); _asuntoCtrl.dispose();
    _fechaCtrl.dispose(); _focusScope.dispose(); super.dispose();
  }

  double get _subtotal => _products.fold(0, (s, p) => s + p.totalwithDiscount);

  Future<void> _seleccionarCliente() async {
    final r = await Navigator.of(context).push<Cliente>(
      CupertinoPageRoute(
          builder: (_) => const SelectClientePage(
              title: 'Seleccionar cliente', filters: [])),
    );
    if (r != null) setState(() => _cliente = r);
  }

  Future<void> _guardar() async {
    if (_asuntoCtrl.text.trim().isEmpty) { _snack('El asunto es requerido'); return; }
    if (_products.isEmpty) { _snack('Agrega al menos un producto'); return; }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _guardando = true);
    final provider = context.read<AppProvider>();
    final tasa = provider.perfil?.impuesto ?? 16.0;

    final conceptos = _products.map((p) => ConceptoCotizacion(
      nombre: p.nombre, descripcion: p.descripcion,
      precioUnitario: double.tryParse(p.precioIndividual) ?? 0,
      cantidad: int.tryParse(p.cantidadInicial) ?? 1,
      descuentoPct: double.tryParse(p.descuento) ?? 0,
      category: p.category,
      subcategory: p.subcategory,
      satKey: p.satKey,
    )).toList();

    if (_esEdicion) {
      final updated = widget.editando!.copyWith(
        titulo: _tituloCtrl.text.trim(),
        asunto: _asuntoCtrl.text.trim(),
        fecha: _fechaCtrl.text,
        clienteId: _cliente?.id ?? widget.editando!.clienteId,
        clienteNombre: _cliente?.nombre ?? widget.editando!.clienteNombre,
        clienteCorreo: _cliente?.correo ?? widget.editando!.clienteCorreo,
        conceptos: conceptos,
        tasaIva: tasa,
      );
      final ok = await provider.actualizarCotizacion(uid, updated);
      setState(() => _guardando = false);
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop();
      } else {
        _snack(provider.errorMessage ?? 'Error al actualizar');
      }
    } else {
      final nueva = Cotizacion(
        id: '', uid: uid,
        titulo: _tituloCtrl.text.trim(),
        asunto: _asuntoCtrl.text.trim(),
        fecha: _fechaCtrl.text,
        clienteId: _cliente?.id ?? '',
        clienteNombre: _cliente?.nombre ?? '',
        clienteCorreo: _cliente?.correo ?? '',
        conceptos: conceptos,
        tasaIva: tasa,
      );
      final creada = await provider.crearCotizacion(uid, nueva);
      setState(() => _guardando = false);
      if (!mounted) return;
      if (creada != null) {
        Navigator.of(context).push(
          CupertinoPageRoute(
              builder: (_) => CotizacionDetallePage(cot: creada)),
        );
      } else {
        _snack(provider.errorMessage ?? 'Error al guardar');
      }
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final tasa     = provider.perfil?.impuesto ?? 16.0;
    final iva      = _subtotal * (tasa / 100);
    final total    = _subtotal + iva;
    final fmt      = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: FocusScope(
          node: _focusScope,
          child: SingleChildScrollView(
            child: Stack(children: [
              Positioned(child: Image.asset('assets/images/decorations/TopRight.png',
                  width: 300, height: 230, fit: BoxFit.fill)),
              Positioned(right: 0, bottom: 0,
                  child: Image.asset('assets/images/decorations/BotLeft.png', height: 170)),
              SafeArea(child: Column(children: [
                AppBar(
                  scrolledUnderElevation: 0,
                  backgroundColor: Colors.transparent,
                  centerTitle: false,
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: Text(
                    _esEdicion ? 'Editar cotización' : 'Nueva cotización',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(LucideIcons.eraser, color: Color.fromARGB(255, 124, 124, 140)),
                      tooltip: 'Limpiar formulario',
                      onPressed: () async {
                        final ok = await showCupertinoDialog<bool>(
                          context: context,
                          builder: (_) => CupertinoAlertDialog(
                            title: const Text('¿Limpiar formulario?'),
                            content: const Text('Se borrarán todos los campos y productos.'),
                            actions: [
                              CupertinoDialogAction(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar')),
                              CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Limpiar')),
                            ],
                          ),
                        );
                        if (ok == true && mounted) {
                          setState(() {
                            _tituloCtrl.clear(); _asuntoCtrl.clear();
                            _fechaCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
                            _cliente = null; _products = [];
                          });
                        }
                      },
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 12, left: 18, right: 18, bottom: 50),
                  child: Column(children: [
                    // Detalles
                    CustomCard(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Detalles',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      DateTextField(fecha: _fechaCtrl),
                      const SizedBox(height: 14),
                      CustomTextField(icon: LucideIcons.fileText,
                          name: 'Título (opcional)', variable: _tituloCtrl),
                      const SizedBox(height: 14),
                      CustomTextField(icon: LucideIcons.layers,
                          name: 'Asunto', variable: _asuntoCtrl),
                      const SizedBox(height: 14),
                      ClientSelectionButton(
                        name: _cliente?.nombre ?? 'Seleccionar cliente (opcional)',
                        onTap: _seleccionarCliente,
                        isSelected: _cliente != null,
                        rfc: null,
                      ),
                    ])),
                    const SizedBox(height: 14),

                    CustomCard(child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Productos',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            final p = await showProductBottomSheet(context);
                            if (p != null) setState(() => _products.add(p));
                          },
                          child: const Icon(LucideIcons.plus),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      if (_products.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text('No hay productos — toca + para agregar',
                              style: TextStyle(color: Colors.grey)),
                        )
                      else ...[
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _products.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            _products[i].onDelete  = () => setState(() => _products.removeAt(i));
                            _products[i].onUpdated = (_) => setState(() {});
                            return _products[i];
                          },
                        ),
                        const Divider(height: 24),
                        _TRow('Subtotal', fmt.format(_subtotal)),
                        _TRow('IVA (${tasa.toInt()}%)', fmt.format(iva)),
                        const Divider(height: 8),
                        _TRow('Total', fmt.format(total), bold: true),
                      ],
                    ])),
                    const SizedBox(height: 16),

                    _guardando
                        ? const Center(child: CircularProgressIndicator(
                            color: Color(0xFF6DB1B1)))
                        : CustomButton(
                            texto: _esEdicion ? 'Guardar cambios' : 'Crear cotización',
                            funcion: _guardar),
                    const SizedBox(height: 30),
                  ]),
                ),
              ])),
            ]),
          ),
        ),
      ),
    );
  }
}

class _TRow extends StatelessWidget {
  final String l, v; final bool bold;
  const _TRow(this.l, this.v, {this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: TextStyle(fontSize: bold ? 18 : 13,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: bold ? null : Colors.grey)),
      Text(v, style: TextStyle(fontSize: bold ? 18 : 13,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: bold ? const Color(0xFF6DB1B1) : null)),
    ]),
  );
}
