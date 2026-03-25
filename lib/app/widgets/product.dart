import 'package:cotizadeprisa/app/widgets/productsBottomSheetModal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:cotizadeprisa/app/models/borderDesign.dart';

// ignore: must_be_immutable
class Product extends StatefulWidget {
  Product({
    super.key,
    required this.nombre,
    required this.precioIndividual,
    required this.cantidadInicial,
    required this.imagesPath,
    required this.descuento,
    required this.descripcion,
  });


  String nombre;
  String precioIndividual;
  String cantidadInicial;
  String descripcion;
  String descuento;
  List<String> imagesPath;


  double get totalwithDiscount =>
      ((int.tryParse(cantidadInicial) ?? 0) * double.parse(precioIndividual)) * ((100 - (double.tryParse(descuento) ?? 0)) / 100);
  
  double get total =>
      (int.tryParse(cantidadInicial) ?? 0) * double.parse(precioIndividual);

  @override
  State<Product> createState() => _ProductState();
}


class _ProductState extends State<Product> {
  late TextEditingController cantidadController;

  @override
  void initState() {
    super.initState();
    cantidadController = TextEditingController(text: widget.cantidadInicial);
  }



  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
        child: Row(
          children: [
            _buildImage(),
            _buildProductDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return const Expanded(
      flex: 3,
      child: Padding(
        padding:  EdgeInsets.only(right: 12),
        child: Center(child: Icon(LucideIcons.image)),
      ),
    );
  }



  Widget _buildProductDetails(BuildContext context) {
    return Expanded(
      flex: 8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.nombre,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                    height: 1,
                  ),
                ),
              ),
      
              buildPullDownButton(),

            ],
          ),
          const SizedBox(height: 10),
          _buildPriceAndQuantity(context),
        ],
      ),
    );
  }

  PullDownButton buildPullDownButton() {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem.selectable(
          onTap: () async {
            showProductBottomSheet(context, isEditing: true,);
          },
          title: 'Editar',
          icon: LucideIcons.pen,
        ),
        PullDownMenuItem.selectable(
          onTap: () {},
          title: 'Eliminar',
          icon: LucideIcons.trash2,
        ),
      ],
      buttonBuilder: (context, showMenu) => GestureDetector(
        onTap: (){

          showMenu();
        },
        child: Container(
          color: Colors.white,
         
          child: SizedBox(
            height: 28,
            child: Icon(
              LucideIcons.ellipsisVertical,
              color: Theme.of(context).hintColor,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }


Widget _buildPriceAndQuantity(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ( widget.descuento != "0" )
          ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 70,
                  child: Text(
                      NumberFormat('#,##0.00').format(double.parse(widget.precioIndividual)),
                      style: TextStyle(fontSize: 11, color: Theme.of(context).shadowColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                ),
              SizedBox(
                width: 145,
                //margin: EdgeInsets.only(left: 10),
                child: Text(
                  NumberFormat('#,##0.00').format(widget.total),
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 11, color: Theme.of(context).shadowColor, decoration: TextDecoration.lineThrough),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
                ],
              )
      
          : Text(
              NumberFormat('#,##0.00').format(double.parse(widget.precioIndividual)),
              style: TextStyle(fontSize: 11, color: Theme.of(context).shadowColor),
              overflow: TextOverflow.ellipsis,
            ),



          const SizedBox(height: 3),



          Row(

            children: [

              //cantidad
              
              Container(
                height: 35,
                width: 71,
                margin: const  EdgeInsets.only(right: 10),
                    
                child: TextField(
                  controller: cantidadController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  onChanged: (value) {
                    //actualizar total del widget
                  },
                  style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor, height: 1,),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 9,vertical: 0),
                    enabledBorder: borderDesginQty(context),
                    focusedBorder: borderDesginQty(context),
                  ),
                ),    
              ),

              //Total del producto
              Expanded(
                child: Text(
                  textAlign: TextAlign.end,
                  "\$${NumberFormat('#,##0.00').format(widget.totalwithDiscount)}",
                  
                  overflow: TextOverflow.ellipsis, 
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
