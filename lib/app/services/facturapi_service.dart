import 'dart:convert';
import 'package:cotizadeprisa/app/config/app_config.dart';
import 'package:cotizadeprisa/app/models/factura.dart';
import 'package:http/http.dart' as http;


class TimbradoResult {
  final bool exito;
  final String? uuid;
  final String? facturapiId; 
  final String? xmlTimbrado;
  final String? pdfUrl;
  final String? error;

  const TimbradoResult({
    required this.exito,
    this.uuid,
    this.facturapiId,
    this.xmlTimbrado,
    this.pdfUrl,
    this.error,
  });
}


class FacturapiService {
  FacturapiService._();
  static final FacturapiService instance = FacturapiService._();

  String get _apiKey => AppConfig.facturapiApiKey;

  Uri _uri(String path) => Uri.parse('https://www.facturapi.io/v2/$path');

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };


  Future<String?> crearOActualizarCliente({
    required String rfc,
    required String nombre,
    required String codigoPostal,
    required String regimenFiscal,
    String? correo,
  }) async {
    try {
      final body = jsonEncode({
        'legal_name': nombre,
        'tax_id': rfc.toUpperCase(),
        'tax_system': regimenFiscal,
        'address': {'zip': codigoPostal},
        if (correo != null && correo.isNotEmpty) 'email': correo,
      });

      final response = await http
          .post(_uri('customers'), headers: _headers, body: body)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['id'] as String?;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<TimbradoResult> crearFactura(Factura factura) async {
    try {
      final clienteId = await crearOActualizarCliente(
        rfc: factura.rfcReceptor,
        nombre: factura.nombreReceptor,
        codigoPostal: factura.codigoPostalReceptor,
        regimenFiscal: factura.regimenFiscalReceptor,
      );

      if (clienteId == null) {
        return const TimbradoResult(
          exito: false,
          error:
              'No se pudo registrar el receptor en Facturapi. '
              'Verifica el RFC y los datos fiscales.',
        );
      }

      final items = factura.conceptos.map((c) {
        final desc = c.descripcion.isNotEmpty ? c.descripcion : c.nombre;
        final precioSinIva = c.precioUnitario;
        return {
          'quantity': c.cantidad,
          'product': {
            'description': desc,
            'product_key': c.claveProdServ,
            'unit_key': c.claveUnidad,
            'unit_name': 'Pieza',
            'price': precioSinIva,
            'tax_included': false,
            'taxes': [
              {
                'type': 'IVA',
                'rate': 0.16,
                'factor': 'Tasa',
                'withholding': false,
              },
            ],
          },
          if (c.descuentoPct > 0)
            'discount': double.parse(
                (precioSinIva * c.cantidad * (c.descuentoPct / 100))
                    .toStringAsFixed(2)),
        };
      }).toList();

      final body = jsonEncode({
        'customer': clienteId,
        'payment_form': factura.formaPago,
        'payment_method': factura.metodoPago,
        'use': factura.usoCfdi,
        'currency': factura.moneda,
        'series': factura.serie,
        'folio_number': int.tryParse(factura.id.replaceAll(RegExp(r'\D'), '')) ?? 1,
        'type': _tipoComprobante(factura.tipoComprobante),
        'items': items,
        if (factura.condicionesDePago?.isNotEmpty == true)
          'conditions': factura.condicionesDePago,
      });

      final response = await http
          .post(_uri('invoices'), headers: _headers, body: body)
          .timeout(const Duration(seconds: 60));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TimbradoResult(
          exito: true,
          uuid: data['uuid'] as String?,
          facturapiId: data['id'] as String?,
          pdfUrl: (data['pdf_url'] ?? data['download_pdf']) as String?,
        );
      }

      final msg = _extraerMensajeError(data);
      return TimbradoResult(exito: false, error: msg);
    } on http.ClientException catch (e) {
      return TimbradoResult(exito: false, error: 'Error de red: ${e.message}');
    } catch (e) {
      return TimbradoResult(
          exito: false, error: 'Error inesperado al facturar: $e');
    }
  }


  Future<String?> descargarXml(String facturapiId) async {
    try {
      final response = await http
          .get(_uri('invoices/$facturapiId/xml'), headers: _headers)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) return response.body;
      return null;
    } catch (_) {
      return null;
    }
  }


  Future<bool> cancelarFactura(String facturapiId, String motivo) async {
    try {
      final body = jsonEncode({'motive': motivo});
      final response = await http
          .delete(_uri('invoices/$facturapiId'),
              headers: _headers, body: body)
          .timeout(const Duration(seconds: 30));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }


  String _tipoComprobante(String tipo) {
    switch (tipo) {
      case 'E': return 'E'; 
      case 'P': return 'P';
      default:  return 'I';
    }
  }

  String _extraerMensajeError(Map<String, dynamic> data) {
    final message = data['message'] as String?;
    final details = data['details'];

    if (details is List && details.isNotEmpty) {
      final first = details.first;
      if (first is Map) {
        final msg = first['message'] ?? first['msg'] ?? '';
        if (msg.isNotEmpty) return 'Facturapi: $msg';
      }
    }
    if (message != null && message.isNotEmpty) return 'Facturapi: $message';
    return 'Error desconocido de Facturapi (código: ${data['status'] ?? "?"})';
  }
}
