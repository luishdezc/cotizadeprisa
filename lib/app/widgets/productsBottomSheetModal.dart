
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cotizadeprisa/app/widgets/customButon.dart';
import 'package:cotizadeprisa/app/widgets/customTextField.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void showProductBottomSheet(BuildContext context, {bool isEditing = false}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => AddProductBottomSheet(isEditing: isEditing),
  );
}

class AddProductBottomSheet extends StatefulWidget {
  final bool isEditing;
  const AddProductBottomSheet({super.key, this.isEditing = false});

  @override
  State<AddProductBottomSheet> createState() => _AddProductBottomSheetState();
}

class _AddProductBottomSheetState extends State<AddProductBottomSheet> {
  final ImagePicker picker = ImagePicker();
  

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController descuentoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!widget.isEditing) {
      precioController.text = "1";
      cantidadController.text = "1";
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    await picker.pickImage(source: source);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Imagen seleccionada (lógica pendiente)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Container(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            Text(
              widget.isEditing ? "Editar producto" : "Nuevo producto",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            
            CustomTextField(name: "Nombre del producto", variable: nombreController, multiline: true),

            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(name: "Precio individual", variable: precioController, onlyDouble: true, isRequired: true),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: CustomTextField(name: "Cantidad", variable: cantidadController, onlyNumbers: true, isRequired: true),
                ),
              ],
            ),


            CustomTextField(name: "Descuento", variable: descuentoController, onlyNumbers: true, icon: LucideIcons.percent),


            CustomTextField(name: "Descripción", variable: descripcionController, multiline: true),


            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1.7, color: Theme.of(context).shadowColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(7),
                      onPressed: () => _pickImage(ImageSource.camera),
                      child: Icon(LucideIcons.camera, color: Theme.of(context).hintColor, size: 24),
                    ),
                  ),
                  Container(height: 30, width: 1.5, color: Colors.grey),
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      child: Icon(LucideIcons.imagePlus, color: Theme.of(context).hintColor, size: 24),
                    ),
                  ),
                ],
              ),
            ),


            CustomButton(
              texto: widget.isEditing ? "Guardar cambios" : "Agregar producto",
              funcion: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}