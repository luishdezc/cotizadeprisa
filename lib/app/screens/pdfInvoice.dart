import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cotizadeprisa/app/widgets/product.dart';

/// display a pdf document.
void displayPdf(
  BuildContext context, {
  String id = "id",
  String motivo = "motivo",
  String fecha = "fecha",
  String cliente = "cliente",
  required List<Product> products,
}) async {
  final doc = pw.Document();

  // Agregamos una sola página en blanco
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Center();
      },
    ),
  );

  /// open Preview Screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PreviewScreen(
        doc: doc,
        title: motivo,
      ),
    ),
  );
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
        title: const Text(
                'Cotización',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,//fontWeight: FontWeight.w700,
                ),
              ),
        
      ), 


      body: 
      
      PdfPreview(
        build: (format) => doc.save(),
        //pageFormats: ,
        //actionBarTheme: PdfActionBarTheme(backgroundColor: Colors.amber),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        //initialPageFormat: PdfPageFormat.a4,
        pdfFileName: "Cotiacion $title.pdf",

        
      ),

      
    );
  }
}
