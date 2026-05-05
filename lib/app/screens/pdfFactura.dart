import 'dart:io';
import 'dart:typed_data';
import 'package:cotizadeprisa/app/models/factura.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class PdfFacturaPage extends StatelessWidget {
  final Factura factura;
  const PdfFacturaPage({super.key, required this.factura});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Factura CFDI',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
      ),
      body: PdfPreview(
        maxPageWidth: 700,
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
        build: (_) => _generarPdf(),
      ),
    );
  }

  Future<Uint8List> _generarPdf() async {
    final doc      = pw.Document();
    final fmt      = NumberFormat('#,##0.00');
    final timbrada = factura.estaTimbrada;
    const primary  = PdfColors.teal700;
    const whiteSubtle = PdfColor(1, 1, 1, 0.7); // blanco al 70 %

    pw.ImageProvider? logoImage;
    try {
      final prefs = await SharedPreferences.getInstance();
      final logoPath = prefs.getString('empresa_logo_path');
      if (logoPath != null && logoPath.isNotEmpty) {
        final logoFile = File(logoPath);
        if (logoFile.existsSync()) {
          final bytes = await logoFile.readAsBytes();
          logoImage = pw.MemoryImage(bytes);
        }
      }
    } catch (_) { /* no logo, continuar */ }

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(32),
      build: (ctx) => [
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: primary, borderRadius: pw.BorderRadius.circular(8)),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (logoImage != null) ...[
                    pw.Container(
                      width: 52, height: 52,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                    ),
                    pw.SizedBox(width: 12),
                  ],
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text('FACTURA CFDI 4.0',
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 20,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('Folio: ${factura.id}  ·  Serie: ${factura.serie}',
                        style: pw.TextStyle(color: whiteSubtle, fontSize: 11)),
                    pw.Text('Fecha: ${factura.fecha}',
                        style: pw.TextStyle(color: whiteSubtle, fontSize: 11)),
                  ]),
                ],
              ),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                pw.Text(timbrada ? 'TIMBRADA' : 'BORRADOR',
                    style: pw.TextStyle(
                        color: timbrada ? PdfColors.greenAccent200 : PdfColors.orange,
                        fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.Text('Total: \$${fmt.format(factura.total)}',
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 16,
                        fontWeight: pw.FontWeight.bold)),
              ]),
            ],
          ),
        ),
        pw.SizedBox(height: 16),

        if (timbrada && factura.uuid != null)
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            margin: const pw.EdgeInsets.only(bottom: 14),
            decoration: pw.BoxDecoration(
              color: PdfColors.teal50,
              border: pw.Border.all(color: PdfColors.teal300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('TIMBRE FISCAL DIGITAL',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold,
                      fontSize: 10, color: PdfColors.teal800)),
              pw.SizedBox(height: 4),
              pw.Text('UUID: ${factura.uuid}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.teal700)),
              if (factura.facturapiId != null)
                pw.Text('ID Facturapi: ${factura.facturapiId}',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.teal700)),
              if (factura.fechaTimbrado != null)
                pw.Text(
                    'Fecha timbrado: ${factura.fechaTimbrado!.toLocal().toString().substring(0, 16)}',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.teal700)),
            ]),
          ),

        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: _seccion('EMISOR', [
            'RFC: ${factura.rfcEmisor}',
            'Nombre: ${factura.nombreEmisor}',
            'Régimen: ${factura.regimenFiscalEmisor}',
            'C.P.: ${factura.codigoPostalEmisor}',
          ], primary)),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _seccion('RECEPTOR', [
            'RFC: ${factura.rfcReceptor}',
            'Nombre: ${factura.nombreReceptor}',
            'Régimen: ${factura.regimenFiscalReceptor}',
            'C.P.: ${factura.codigoPostalReceptor}',
            'Uso CFDI: ${factura.usoCfdi}',
          ], primary)),
        ]),
        pw.SizedBox(height: 14),

        _seccion('DATOS DEL COMPROBANTE', [
          'Tipo: ${factura.tipoComprobante}  ·  Moneda: ${factura.moneda}',
          'Forma pago: ${factura.formaPago}  ·  Método: ${factura.metodoPago}',
          'Condiciones: ${factura.condicionesDePago ?? "CONTADO"}',
        ], primary),
        pw.SizedBox(height: 14),

        pw.Text('CONCEPTOS',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold,
                fontSize: 11, color: primary)),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(1.5),
            4: const pw.FlexColumnWidth(1.5),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: primary),
              children: ['ClaveSAT', 'Descripción', 'Cant.', 'Precio', 'Importe']
                  .map((h) => pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(h,
                            style: pw.TextStyle(color: PdfColors.white,
                                fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ))
                  .toList(),
            ),
            ...factura.conceptos.asMap().entries.map((e) {
              final c  = e.value;
              final bg = e.key.isEven ? PdfColors.white : PdfColors.grey50;
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: bg),
                children: [
                  _cell(c.claveProdServ, 9),
                  _cell(c.descripcion.isNotEmpty ? c.descripcion : c.nombre, 9),
                  _cell(c.cantidad.toString(), 9, align: pw.TextAlign.center),
                  _cell('\$${fmt.format(c.precioUnitario)}', 9,
                      align: pw.TextAlign.right),
                  _cell('\$${fmt.format(c.importe)}', 9,
                      align: pw.TextAlign.right),
                ],
              );
            }),
          ],
        ),
        pw.SizedBox(height: 12),

        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.SizedBox(
            width: 220,
            child: pw.Column(children: [
              _totRow('Subtotal', '\$${fmt.format(factura.subtotal)}', primary),
              _totRow('IVA 16%', '\$${fmt.format(factura.totalIva)}', primary),
              pw.Divider(color: primary),
              _totRow('TOTAL', '\$${fmt.format(factura.total)}', primary, bold: true),
            ]),
          ),
        ),
        pw.SizedBox(height: 20),

        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 6),
        pw.Text('Generado por CotizaDePrisa  ·  CFDI 4.0',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
      ],
    ));

    return doc.save();
  }

  pw.Widget _seccion(String titulo, List<String> lineas, PdfColor color) =>
      pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(6)),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(titulo,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: color)),
          pw.SizedBox(height: 6),
          ...lineas.map((l) => pw.Text(l, style: const pw.TextStyle(fontSize: 9))),
        ]),
      );

  pw.Widget _cell(String t, double fs, {pw.TextAlign align = pw.TextAlign.left}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.all(5),
        child: pw.Text(t, textAlign: align, style: pw.TextStyle(fontSize: fs)),
      );

  pw.Widget _totRow(String l, String v, PdfColor color, {bool bold = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(l,
                style: pw.TextStyle(
                    fontSize: bold ? 12 : 10,
                    fontWeight: bold ? pw.FontWeight.bold : null,
                    color: bold ? color : PdfColors.black)),
            pw.Text(v,
                style: pw.TextStyle(
                    fontSize: bold ? 12 : 10,
                    fontWeight: bold ? pw.FontWeight.bold : null,
                    color: bold ? color : PdfColors.black)),
          ],
        ),
      );
}
