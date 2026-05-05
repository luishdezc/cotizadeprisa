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
  final nombreCtrl =
      TextEditingController(text: existing?.nombre ?? '');
  final precioCtrl =
      TextEditingController(text: existing?.precioIndividual ?? '');
  final cantidadCtrl =
      TextEditingController(text: existing?.cantidadInicial ?? '1');
  final descuentoCtrl =
      TextEditingController(text: existing?.descuento ?? '0');
  final descripcionCtrl =
      TextEditingController(text: existing?.descripcion ?? '');

  return showModalBottomSheet<Product>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Editar producto' : 'Nuevo producto',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
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
              Row(
                children: [
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
                ],
              ),
              const SizedBox(height: 15),
              CustomTextField(
                name: 'Descuento (%)',
                variable: descuentoCtrl,
                icon: LucideIcons.percent,
                isNumeric: true,
              ),
              const SizedBox(height: 25),
              CustomButton(
                texto: isEditing ? 'Guardar cambios' : 'Agregar producto',
                funcion: () {
                  if (nombreCtrl.text.trim().isEmpty ||
                      precioCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Nombre y precio son requeridos')),
                    );
                    return;
                  }

                  final precio =
                      double.tryParse(precioCtrl.text.trim());
                  if (precio == null || precio <= 0) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                          content: Text('Precio inválido')),
                    );
                    return;
                  }

                  final producto = Product(
                    nombre: nombreCtrl.text.trim(),
                    precioIndividual: precio.toString(),
                    cantidadInicial:
                        cantidadCtrl.text.trim().isEmpty
                            ? '1'
                            : cantidadCtrl.text.trim(),
                    descuento:
                        descuentoCtrl.text.trim().isEmpty
                            ? '0'
                            : descuentoCtrl.text.trim(),
                    descripcion: descripcionCtrl.text.trim(),
                  );

                  Navigator.of(ctx).pop(producto);
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    },
  );
}
