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
    required this.descuento,
    required this.descripcion,
    this.category = '',
    this.subcategory = '',
    this.satKey = '01010101',
    this.onDelete,
    this.onUpdated,
  });

  String nombre;
  String precioIndividual;
  String cantidadInicial;
  String descripcion;
  String descuento;

  String category;

  String subcategory;

  String satKey;

  VoidCallback? onDelete;
  ValueChanged<Product>? onUpdated;

  double get totalwithDiscount =>
      ((int.tryParse(cantidadInicial) ?? 0) *
          (double.tryParse(precioIndividual) ?? 0)) *
      ((100 - (double.tryParse(descuento) ?? 0)) / 100);

  double get total =>
      (int.tryParse(cantidadInicial) ?? 0) *
      (double.tryParse(precioIndividual) ?? 0);

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
  void dispose() {
    cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
        child: _buildProductDetails(context),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nombre,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                      height: 1),
                ),
                if (widget.subcategory.isNotEmpty)
                  Text(
                    '${widget.category} › ${widget.subcategory}',
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF919191)),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          _buildMenu(),
        ]),
        const SizedBox(height: 8),
        _buildPriceRow(context),
      ],
    );
  }

  Widget _buildMenu() {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem.selectable(
          onTap: () async {
            final updated = await showProductBottomSheet(
              context,
              isEditing: true,
              existing: widget,
            );
            if (updated != null) {
              setState(() {
                widget.nombre           = updated.nombre;
                widget.precioIndividual = updated.precioIndividual;
                widget.cantidadInicial  = updated.cantidadInicial;
                widget.descuento        = updated.descuento;
                widget.descripcion      = updated.descripcion;
                widget.category         = updated.category;
                widget.subcategory      = updated.subcategory;
                widget.satKey           = updated.satKey;
                cantidadController.text = updated.cantidadInicial;
              });
              widget.onUpdated?.call(widget);
            }
          },
          title: 'Editar',
          icon: LucideIcons.pen,
        ),
        PullDownMenuItem.selectable(
          onTap: () => widget.onDelete?.call(),
          title: 'Eliminar',
          icon: LucideIcons.trash2,
          isDestructive: true,
        ),
      ],
      buttonBuilder: (context, showMenu) => GestureDetector(
        onTap: showMenu,
        child: Container(
          color: Colors.transparent,
          child: SizedBox(
            height: 28,
            child: Icon(LucideIcons.ellipsisVertical,
                color: Theme.of(context).hintColor, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.descuento != '0')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    NumberFormat('#,##0.00')
                        .format(double.tryParse(widget.precioIndividual) ?? 0),
                    style: TextStyle(
                        fontSize: 11, color: Theme.of(context).shadowColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 145,
                  child: Text(
                    NumberFormat('#,##0.00').format(widget.total),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).shadowColor,
                        decoration: TextDecoration.lineThrough),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else
            Text(
              NumberFormat('#,##0.00')
                  .format(double.tryParse(widget.precioIndividual) ?? 0),
              style: TextStyle(
                  fontSize: 11, color: Theme.of(context).shadowColor),
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 3),
          Row(children: [
            Container(
              height: 35,
              width: 71,
              margin: const EdgeInsets.only(right: 10),
              child: TextField(
                controller: cantidadController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    widget.cantidadInicial = value.isEmpty ? '0' : value;
                  });
                  widget.onUpdated?.call(widget);
                },
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                    height: 1),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 0),
                  enabledBorder: borderDesginQty(context),
                  focusedBorder: borderDesginQty(context),
                ),
              ),
            ),
            Expanded(
              child: Text(
                '\$${NumberFormat('#,##0.00').format(widget.totalwithDiscount)}',
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).hintColor),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
