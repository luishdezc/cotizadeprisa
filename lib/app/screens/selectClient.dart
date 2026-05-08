import 'package:cotizadeprisa/app/models/cliente.dart';
import 'package:cotizadeprisa/app/providers/app_provider.dart';
import 'package:cotizadeprisa/app/widgets/Texts.dart';
import 'package:cotizadeprisa/app/widgets/customButon.dart';
import 'package:cotizadeprisa/app/widgets/customTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';


class SelectClientePage extends StatefulWidget {
  final String title;
  final List<Widget> filters;

  const SelectClientePage({
    super.key,
    required this.title,
    required this.filters,
  });

  @override
  State<SelectClientePage> createState() => _SelectClientePageState();
}

class _SelectClientePageState extends State<SelectClientePage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
        () => setState(() => _query = _searchCtrl.text.toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Cliente> _filtrar(List<Cliente> clientes) {
    if (_query.isEmpty) return clientes;
    return clientes
        .where((c) =>
            c.nombre.toLowerCase().contains(_query) ||
            c.correo.toLowerCase().contains(_query))
        .toList();
  }


  void _showNuevoClienteModal() {
    final nombreCtrl   = TextEditingController();
    final correoCtrl   = TextEditingController();
    final telefonoCtrl = TextEditingController();
    final rfcCtrl      = TextEditingController();
    final cpCtrl       = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 24,
        ),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const Text('Nuevo cliente',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Datos requeridos para facturación (CFDI 4.0).',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 20),
          CustomTextField(name: 'Nombre / Razón Social *',
              variable: nombreCtrl, icon: LucideIcons.user),
          const SizedBox(height: 14),
          CustomTextField(name: 'RFC',
              variable: rfcCtrl, icon: LucideIcons.idCardLanyard, textCapitalization: TextCapitalization.characters),
          const SizedBox(height: 14),
          CustomTextField(name: 'Código Postal',
              variable: cpCtrl, icon: LucideIcons.mailbox, keyboardType: TextInputType.number, maxLength: 5),
          const SizedBox(height: 14),
          CustomTextField(name: 'Correo electrónico',
              variable: correoCtrl, icon: LucideIcons.mail),
          const SizedBox(height: 14),
          CustomTextField(name: 'Teléfono (opcional)',
              variable: telefonoCtrl, icon: LucideIcons.phone),
          const SizedBox(height: 24),
          CustomButton(
            texto: 'Crear cliente',
            funcion: () async {
              if (nombreCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El nombre es requerido')));
                return;
              }
              Navigator.pop(ctx);
              await _crearCliente(Cliente(
                id: '', nombre: nombreCtrl.text.trim(),
                rfc: rfcCtrl.text.trim().toUpperCase(),
                codigoPostal: cpCtrl.text.trim(),
                correo: correoCtrl.text.trim(),
                telefono: telefonoCtrl.text.trim(),
              ));
            },
          ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }


  void _showEditClienteModal(Cliente cliente) {
    final nombreCtrl   = TextEditingController(text: cliente.nombre);
    final correoCtrl   = TextEditingController(text: cliente.correo);
    final telefonoCtrl = TextEditingController(text: cliente.telefono ?? '');
    final rfcCtrl      = TextEditingController(text: cliente.rfc);
    final cpCtrl       = TextEditingController(text: cliente.codigoPostal);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 24,
        ),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const Text('Editar cliente',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Datos requeridos para facturación (CFDI 4.0).',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 20),
          CustomTextField(name: 'Nombre / Razón Social *',
              variable: nombreCtrl, icon: LucideIcons.user),
          const SizedBox(height: 14),
          CustomTextField(name: 'RFC',
              variable: rfcCtrl, icon: LucideIcons.idCardLanyard, textCapitalization: TextCapitalization.characters),
          const SizedBox(height: 14),
          CustomTextField(name: 'Código Postal',
              variable: cpCtrl, icon: LucideIcons.mailbox, keyboardType: TextInputType.number, maxLength: 5),
          const SizedBox(height: 14),
          CustomTextField(name: 'Correo electrónico',
              variable: correoCtrl, icon: LucideIcons.mail),
          const SizedBox(height: 14),
          CustomTextField(name: 'Teléfono (opcional)',
              variable: telefonoCtrl, icon: LucideIcons.phone),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: CupertinoButton(
                color: Colors.red.withOpacity(0.8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _eliminarCliente(cliente.id);
                },
                child: const Text('Eliminar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: CustomButton(
              texto: 'Guardar',
              funcion: () async {
                if (nombreCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('El nombre es requerido')));
                  return;
                }
                Navigator.pop(ctx);
                final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                await context.read<AppProvider>().actualizarCliente(uid,
                  cliente.copyWith(
                    nombre: nombreCtrl.text.trim(),
                    rfc: rfcCtrl.text.trim().toUpperCase(),
                    codigoPostal: cpCtrl.text.trim(),
                    correo: correoCtrl.text.trim(),
                    telefono: telefonoCtrl.text.trim(),
                  ),
                );
              },
            )),
          ]),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Future<void> _crearCliente(Cliente cliente) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    await context.read<AppProvider>().crearCliente(uid, cliente);
  }

  Future<void> _eliminarCliente(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    await context.read<AppProvider>().eliminarCliente(uid, id);
  }


  Future<void> _onRefresh(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final clientes = _filtrar(provider.clientes);
    final isDark   = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TitleText(text: widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 8),

            Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
                decoration: const InputDecoration(
                  prefixIcon:
                      Icon(Icons.search, color: Color(0xFF919191), size: 20),
                  hintText: 'Buscar por nombre o correo...',
                  hintStyle: TextStyle(color: Color(0xFF919191), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: _showNuevoClienteModal,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color(0xFF6DB1B1).withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF6DB1B1).withOpacity(0.06),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.userPlus,
                        size: 18, color: Color(0xFF3D8F8F)),
                    SizedBox(width: 8),
                    Text('Nuevo cliente',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3D8F8F))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: clientes.isEmpty
                  ? RefreshIndicator(
                      onRefresh: () => _onRefresh(context),
                      child: ListView(children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                        Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(LucideIcons.users, size: 48,
                                color: const Color(0xFF919191).withOpacity(0.4)),
                            const SizedBox(height: 12),
                            Text(
                              _query.isEmpty
                                  ? 'No hay clientes aún.\nToca "Nuevo cliente" para agregar uno.'
                                  : 'Sin resultados para "$_query"',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF919191)),
                            ),
                          ]),
                        ),
                      ]),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _onRefresh(context),
                      child: ListView.separated(
                        itemCount: clientes.length,
                        separatorBuilder: (_, __) => Container(
                            height: 1,
                            color: Theme.of(context)
                                .shadowColor
                                .withOpacity(0.15)),
                        itemBuilder: (_, i) {
                          final item = clientes[i];
                          return _ClientItem(
                            cliente: item,
                            onTap: () => Navigator.of(context).pop(item),
                            onEdit: () => _showEditClienteModal(item),
                          );
                        },
                      ),
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ClientItem extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback onTap, onEdit;
  const _ClientItem(
      {required this.cliente, required this.onTap, required this.onEdit});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 65,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  width: 46,
                  height: double.infinity,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFA5D9D9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Center(
                    child: Text(cliente.iniciales,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cliente.nombre,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 3),
                    Text(
                      cliente.correo.isNotEmpty ? cliente.correo : 'Sin correo',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF919191)),
                    ),
                  ],
                ),
              ]),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  color: Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: const Icon(LucideIcons.ellipsisVertical,
                      size: 18, color: Color(0xFF919191)),
                ),
              ),
            ],
          ),
        ),
      );
}
