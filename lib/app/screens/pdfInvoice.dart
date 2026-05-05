import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cotizadeprisa/app/widgets/product.dart';


void displayPdf(
  BuildContext context, {
  String id = 'BORRADOR',
  String motivo = 'Sin asunto',
  String fecha = '',
  String cliente = 'Sin cliente',
  String rfcCliente = '',
  String total = '\$0.00',
  required List<dynamic> productos,
  String? logoPath,
}) async {
  final doc = pw.Document();

  final fmt = NumberFormat('#,##0.00');

  final List<_PdfProductLine> lines = productos.map((p) {
    final nombre = _getProp(p, 'nombre') ?? 'Producto';
    final precioStr = _getProp(p, 'precioIndividual') ?? '0';
    final cantidadStr = _getProp(p, 'cantidadInicial') ?? '1';
    final descuentoStr = _getProp(p, 'descuento') ?? '0';

    final precio = double.tryParse(precioStr) ?? 0;
    final cantidad = int.tryParse(cantidadStr) ?? 1;
    final descuento = double.tryParse(descuentoStr) ?? 0;
    final subtotal = precio * cantidad * ((100 - descuento) / 100);

    return _PdfProductLine(
      nombre: nombre,
      cantidad: cantidad,
      precio: precio,
      descuento: descuento,
      subtotal: subtotal,
    );
  }).toList();

  final double subtotalNum =
      lines.fold(0, (s, p) => s + p.subtotal);
  final double iva = subtotalNum * 0.16;
  final double totalNum = subtotalNum + iva;

  const brandColor = PdfColor.fromInt(0xFF6DB1B1);
  const lightBrand = PdfColor.fromInt(0xFFA5D9D9);
  const textGrey = PdfColor.fromInt(0xFF919191);

  pw.ImageProvider? logoImage;
  if (logoPath != null && logoPath.isNotEmpty) {
    final logoFile = File(logoPath);
    if (logoFile.existsSync()) {
      final bytes = await logoFile.readAsBytes();
      logoImage = pw.MemoryImage(bytes);
    }
  }

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (logoImage != null) ...[
                      pw.Image(logoImage, width: 60, height: 60, fit: pw.BoxFit.contain),
                      pw.SizedBox(width: 12),
                    ],
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('COTIZACIÓN',
                            style: pw.TextStyle(
                              fontSize: 28,
                              fontWeight: pw.FontWeight.bold,
                              color: brandColor,
                            )),
                        pw.SizedBox(height: 4),
                        pw.Text('Folio: $id',
                            style: pw.TextStyle(
                                fontSize: 12, color: textGrey)),
                        pw.Text('Fecha: $fecha',
                            style: pw.TextStyle(
                                fontSize: 12, color: textGrey)),
                      ],
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: lightBrand,
                    borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(8)),
                  ),
                  child: pw.Text('DOCUMENTO\nCOMERCIAL',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                          color: PdfColors.white)),
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('ASUNTO',
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: textGrey)),
                  pw.SizedBox(height: 4),
                  pw.Text(motivo,
                      style: const pw.TextStyle(fontSize: 13)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PARA:',
                          style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: textGrey)),
                      pw.SizedBox(height: 4),
                      pw.Text(cliente,
                          style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold)),
                      if (rfcCliente.isNotEmpty)
                        pw.Text('RFC: $rfcCliente',
                            style: pw.TextStyle(
                                fontSize: 11, color: textGrey)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration:
                      const pw.BoxDecoration(color: brandColor),
                  children: [
                    _tableHeader('Concepto'),
                    _tableHeader('Cant.', align: pw.TextAlign.center),
                    _tableHeader('P. Unit.',
                        align: pw.TextAlign.right),
                    _tableHeader('Subtotal',
                        align: pw.TextAlign.right),
                  ],
                ),
                ...lines.asMap().entries.map((e) {
                  final i = e.key;
                  final p = e.value;
                  final bg = i.isEven
                      ? PdfColors.white
                      : PdfColors.grey50;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: bg),
                    children: [
                      _tableCell(p.nombre),
                      _tableCell(p.cantidad.toString(),
                          align: pw.TextAlign.center),
                      _tableCell('\$${fmt.format(p.precio)}',
                          align: pw.TextAlign.right),
                      _tableCell('\$${fmt.format(p.subtotal)}',
                          align: pw.TextAlign.right,
                          bold: true),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 16),

            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.SizedBox(
                width: 200,
                child: pw.Column(
                  children: [
                    _totalRow('Subtotal', '\$${fmt.format(subtotalNum)}'),
                    _totalRow('IVA (16%)', '\$${fmt.format(iva)}'),
                    pw.Divider(color: brandColor),
                    _totalRow(
                      'TOTAL',
                      '\$${fmt.format(totalNum)}',
                      bold: true,
                      color: brandColor,
                    ),
                  ],
                ),
              ),
            ),

            pw.Spacer(),

            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 6),
            pw.Text(
              'Este documento es una cotización y no tiene validez fiscal. '
              'Válido por 30 días a partir de la fecha de emisión.',
              style: pw.TextStyle(fontSize: 9, color: textGrey),
              textAlign: pw.TextAlign.center,
            ),
          ],
        );
      },
    ),
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PreviewScreen(doc: doc, title: motivo),
    ),
  );
}


const _brandColor = PdfColor.fromInt(0xFF6DB1B1);
const _textGrey = PdfColor.fromInt(0xFF919191);

pw.Widget _tableHeader(String text,
    {pw.TextAlign align = pw.TextAlign.left}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: pw.Text(text,
        textAlign: align,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        )),
  );
}

pw.Widget _tableCell(String text,
    {pw.TextAlign align = pw.TextAlign.left, bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    child: pw.Text(text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        )),
  );
}

pw.Widget _totalRow(String label, String value,
    {bool bold = false, PdfColor color = PdfColors.black}) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(label,
          style: pw.TextStyle(
            fontSize: bold ? 13 : 11,
            fontWeight:
                bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: bold ? color : _textGrey,
          )),
      pw.Text(value,
          style: pw.TextStyle(
            fontSize: bold ? 13 : 11,
            fontWeight:
                bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          )),
    ],
  );
}


String? _getProp(dynamic obj, String prop) {
  try {
    switch (prop) {
      case 'nombre':
        return obj.nombre as String?;
      case 'precioIndividual':
        return obj.precioIndividual as String?;
      case 'cantidadInicial':
        return obj.cantidadInicial as String?;
      case 'descuento':
        return obj.descuento as String?;
    }
  } catch (_) {}
  return null;
}

class _PdfProductLine {
  final String nombre;
  final int cantidad;
  final double precio;
  final double descuento;
  final double subtotal;

  const _PdfProductLine({
    required this.nombre,
    required this.cantidad,
    required this.precio,
    required this.descuento,
    required this.subtotal,
  });
}


class PreviewScreen extends StatelessWidget {
  final pw.Document doc;
  final String title;

  const PreviewScreen({
    super.key,
    required this.doc,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: const Text(
          'Cotización',
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.w700),
        ),
      ),
      body: PdfPreview(
        build: (format) => doc.save(),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: 'Cotizacion_$title.pdf',
      ),
    );
  }
}
