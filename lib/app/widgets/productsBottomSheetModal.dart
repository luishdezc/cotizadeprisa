import 'package:cotizadeprisa/app/config/sat_catalog.dart';
import 'package:cotizadeprisa/app/widgets/customButon.dart';
import 'package:cotizadeprisa/app/widgets/customTextField.dart';
import 'package:cotizadeprisa/app/widgets/product.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Future<Product?> showProductBottomSheet(
  BuildContext context, {
  bool isEditing = false,
  Product? existing,
}) async {
  return showModalBottomSheet<Product>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _ProductModalContent(
      isEditing: isEditing,
      existing: existing,
    ),
  );
}


class _ProductModalContent extends StatefulWidget {
  final bool isEditing;
  final Product? existing;

  const _ProductModalContent({required this.isEditing, this.existing});

  @override
  State<_ProductModalContent> createState() => _ProductModalContentState();
}

class _ProductModalContentState extends State<_ProductModalContent> {
  late final TextEditingController nombreCtrl;
  late final TextEditingController precioCtrl;
  late final TextEditingController cantidadCtrl;
  late final TextEditingController descuentoCtrl;
  late final TextEditingController descripcionCtrl;

  String? _selectedCategory;
  String? _selectedSubcategory;
  String  _resolvedSatKey = '01010101';

  List<Map<String, String>> get _subcategories =>
      _selectedCategory != null
          ? (satCatalog[_selectedCategory!] ?? [])
          : [];

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    nombreCtrl     = TextEditingController(text: ex?.nombre ?? '');
    precioCtrl     = TextEditingController(text: ex?.precioIndividual ?? '');
    cantidadCtrl   = TextEditingController(text: ex?.cantidadInicial ?? '1');
    descuentoCtrl  = TextEditingController(text: ex?.descuento ?? '0');
    descripcionCtrl = TextEditingController(text: ex?.descripcion ?? '');

    if (ex != null && ex.category.isNotEmpty) {
      _selectedCategory    = ex.category;
      _selectedSubcategory = ex.subcategory;
      _resolvedSatKey      = ex.satKey;
    }
  }

  @override
  void dispose() {
    nombreCtrl.dispose(); precioCtrl.dispose(); cantidadCtrl.dispose();
    descuentoCtrl.dispose(); descripcionCtrl.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String? value) {
    setState(() {
      _selectedCategory    = value;
      _selectedSubcategory = null;
      _resolvedSatKey      = '01010101';
    });
  }

  void _onSubcategoryChanged(String? value) {
    if (value == null) return;
    final clave = getClaveSat(_selectedCategory!, value);
    setState(() {
      _selectedSubcategory = value;
      _resolvedSatKey      = clave;
    });
  }

  void _confirm() {
    if (nombreCtrl.text.trim().isEmpty) {
      _snack('El nombre del producto es requerido');
      return;
    }
    if (precioCtrl.text.trim().isEmpty) {
      _snack('El precio unitario es requerido');
      return;
    }
    final precio = double.tryParse(precioCtrl.text.trim());
    if (precio == null || precio <= 0) {
      _snack('El precio debe ser un número mayor a 0');
      return;
    }
    if (_selectedCategory == null) {
      _snack('Selecciona una categoría');
      return;
    }
    if (_selectedSubcategory == null) {
      _snack('Selecciona una subcategoría');
      return;
    }

    final producto = Product(
      nombre: nombreCtrl.text.trim(),
      precioIndividual: precio.toString(),
      cantidadInicial: cantidadCtrl.text.trim().isEmpty
          ? '1'
          : cantidadCtrl.text.trim(),
      descuento: descuentoCtrl.text.trim().isEmpty
          ? '0'
          : descuentoCtrl.text.trim(),
      descripcion: descripcionCtrl.text.trim(),
      category: _selectedCategory!,
      subcategory: _selectedSubcategory!,
      satKey: _resolvedSatKey,
    );

    Navigator.of(context).pop(producto);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = satCatalog.keys.toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditing ? 'Editar producto' : 'Nuevo producto',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            CustomTextField(
              name: 'Nombre del producto *',
              variable: nombreCtrl,
              icon: LucideIcons.tag,
            ),
            const SizedBox(height: 15),

            CustomTextField(
              name: 'Descripción',
              variable: descripcionCtrl,
              icon: LucideIcons.fileText,
              multiline: true,
            ),
            const SizedBox(height: 15),


            _DropdownField(
              label: 'Categoría *',
              hint: 'Selecciona una categoría',
              value: _selectedCategory,
              items: categories,
              onChanged: _onCategoryChanged,
              isDark: isDark,
              hasError: false,
            ),
            const SizedBox(height: 12),

            _DropdownField(
              label: 'Subcategoría *',
              hint: _selectedCategory == null
                  ? 'Primero selecciona una categoría'
                  : 'Selecciona una subcategoría',
              value: _selectedSubcategory,
              items: _subcategories.map((m) => m['nombre']!).toList(),
              onChanged: _selectedCategory != null ? _onSubcategoryChanged : null,
              isDark: isDark,
              hasError: false,
            ),
            const SizedBox(height: 10),

            if (_selectedSubcategory != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6DB1B1).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF6DB1B1).withOpacity(0.35)),
                ),
                child: Row(children: [
                  const Icon(LucideIcons.badgeCheck,
                      size: 16, color: Color(0xFF3D8F8F)),
                  const SizedBox(width: 8),
                  Text(
                    'Clave SAT: ',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3D8F8F)),
                  ),
                  Text(
                    _resolvedSatKey,
                    style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                        color: Color(0xFF3D8F8F),
                        letterSpacing: 1.2),
                  ),
                ]),
              ),

            const SizedBox(height: 24),

            Row(children: [
              Expanded(
                child: CustomTextField(
                  name: 'Precio unitario *',
                  variable: precioCtrl,
                  icon: LucideIcons.dollarSign,
                  isNumeric: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  name: 'Cantidad *',
                  variable: cantidadCtrl,
                  icon: LucideIcons.hash,
                  isNumeric: true,
                ),
              ),
            ]),
            const SizedBox(height: 15),

            CustomTextField(
              name: 'Descuento (%)',
              variable: descuentoCtrl,
              icon: LucideIcons.percent,
              isNumeric: true,
            ),
            const SizedBox(height: 20),

            

            CustomButton(
              texto: widget.isEditing ? 'Guardar cambios' : 'Agregar producto',
              funcion: _confirm,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}


class _DropdownField extends StatelessWidget {
  final String label, hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final bool isDark, hasError;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onChanged == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: hasError
                ? Colors.red
                : const Color(0xFF919191),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isDisabled
                ? (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5))
                : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasError
                  ? Colors.red
                  : (isDark
                      ? const Color(0xFF444444)
                      : const Color(0xFFDDDDDD)),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              isDense: true,
              hint: Text(
                hint,
                style: TextStyle(
                  fontSize: 14,
                  color: isDisabled
                      ? const Color(0xFF666666)
                      : const Color(0xFF919191),
                ),
              ),
              items: items
                  .map((item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
              icon: Icon(
                LucideIcons.chevronDown,
                size: 16,
                color: isDisabled
                    ? const Color(0xFF666666)
                    : const Color(0xFF919191),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
