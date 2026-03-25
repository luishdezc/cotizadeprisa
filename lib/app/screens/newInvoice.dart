import 'package:cotizadeprisa/app/widgets/clientSelectionButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cotizadeprisa/app/widgets/customButon.dart';
import 'package:cotizadeprisa/app/widgets/customCard.dart';
import 'package:cotizadeprisa/app/widgets/customTextField.dart';
import 'package:cotizadeprisa/app/screens/pdfInvoice.dart';
import 'package:cotizadeprisa/app/widgets/dateTextField.dart';
import 'package:cotizadeprisa/app/widgets/product.dart';
import 'package:cotizadeprisa/app/widgets/productsBottomSheetModal.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final TextEditingController id = TextEditingController();
final TextEditingController motivo = TextEditingController();
final TextEditingController fecha = TextEditingController( text: DateFormat('dd/MM/yyyy').format(DateTime.now()).toString());
final TextEditingController cliente = TextEditingController();
late double total;

class NewInvoicePage extends StatefulWidget {
  const NewInvoicePage({super.key});

  @override
  State<NewInvoicePage> createState() => _NewInvoicePageState();
}

class _NewInvoicePageState extends State<NewInvoicePage> {

  List<Product> products = [
    Product(
    nombre: "Producto demo",
    precioIndividual: "150.0",
    cantidadInicial: "2",
    descuento: '0',
    descripcion: "Producto de prueba",
    imagesPath: [],
  ),
  ];
  final FocusScopeNode _focusScopeNode = FocusScopeNode();



  @override
  Widget build(BuildContext context) {
    final List<Widget> fistForm = [
      const Text(
        "Detalles",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1),
      ),
      DateTextField(fecha: fecha),
      CustomTextField(
        icon: LucideIcons.idCardLanyard,
        name: "Número de serie",
        variable: id,
      ),
      CustomTextField(
        icon: LucideIcons.layers,
        name: "Asunto",
        variable: motivo,
        multiline: true,
      ),
    ];

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: FocusScope(
          node: _focusScopeNode,
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              child: Stack(
                children: [
                  Positioned(
                    child: Image.asset(
                      'assets/images/decorations/TopRight.png',
                      width: 300,
                      height: 230,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Image.asset(
                      'assets/images/decorations/BotLeft.png',
                      height: 170,
                    ),
                  ),
                  

                  SafeArea(
                    child: Stack(
                      children: [
                        AppBar(
                          scrolledUnderElevation: 0,
                          backgroundColor: Colors.transparent,
                          
                          actions: [
                            GestureDetector(
                              child: const Icon(LucideIcons.refreshCcw, size: 28,),
                              onTap: () => _clearTextFields(context),
                            ),
                            const SizedBox(width: 25)
                          ],
                          centerTitle: false,
                          title: const Text(
                            'Nueva cotización',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.only(top: 100, right: 18, left: 18, bottom: 50),
                            width: 950,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                DetailSection(fistForm: fistForm),
                                const SizedBox(height: 19),
                                ProductSection(
                                  products: products,
                                  focusScopeNode: _focusScopeNode,
                                ),
                                const SizedBox(height: 19),
                                CustomButton(
                                  funcion: () {
                                    displayPdf(
                                      context,
                                      id: id.text,
                                      motivo: motivo.text,
                                      fecha: fecha.text,
                                      cliente: cliente.text,
                                      products: products,
                                    );
                                  },
                                  child: const Icon(LucideIcons.printer, color: Colors.white, size: 30,),
                                ),
                                
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  void _clearTextFields(BuildContext context) async {
    final value = await showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("Seguro que desea limpiar los campos?"),
          content: const Text("Se reiniciará el formulario", style: TextStyle(fontWeight: FontWeight.w300)),
          actions: [
            CupertinoButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("no", style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            CupertinoButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("si", style: TextStyle(fontWeight: FontWeight.w500)),
            ),
          ],
        );
      },
    );

    if (value == true) {
      _clearValues();
    }
  }

  void _clearValues() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Se implementará luego'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class DetailSection extends StatelessWidget {
  const DetailSection({
    super.key,
    required this.fistForm,
  });

  final List<Widget> fistForm;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: fistForm.length,
            itemBuilder: (context, index) {
              return fistForm[index];
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 15);
            },
          ),


          //Boton de seleccionar cliente
          const SizedBox(height: 15,),
          
          ClientSelectionButton(
            name: 'Seleccionar cliente', 
          )
        ],
      ),
    );
  }
}

















class ProductSection extends StatefulWidget {
  const ProductSection({
    super.key,
    required this.products,
    required this.focusScopeNode,
  });

  final List<Product> products;
  final FocusScopeNode focusScopeNode;

  @override
  State<ProductSection> createState() => _ProductSectionState();
}

class _ProductSectionState extends State<ProductSection> {

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Productos",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () async {
                  showProductBottomSheet(context);
                },
                child: const Icon(LucideIcons.plus),
              ),
            ],
          ),
          const SizedBox(height: 6),
          widget.products.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.products.length,
                      itemBuilder: (context, index) {
                        return widget.products[index];
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 16);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Total ',
                                  style: TextStyle(color: Colors.black, fontSize: 17),
                                ),
                                TextSpan(
                                  text: '(sin impuesto) ',
                                  style: TextStyle(color: Colors.grey, fontSize: 17),
                                ),
                                TextSpan(
                                  text: ':',
                                  style: TextStyle(color: Colors.black, fontSize: 17),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 12, left: 10),
                            child: Text(
                              "\$ 600.00",
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const SizedBox(
                  height: 108,
                  child: Center(
                    child: Text(
                      "No se han agregado productos",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}