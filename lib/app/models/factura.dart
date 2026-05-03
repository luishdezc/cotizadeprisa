import 'package:cloud_firestore/cloud_firestore.dart';


enum EstadoFactura { borrador, timbrado }

extension EstadoFacturaX on EstadoFactura {
  String get key {
    switch (this) {
      case EstadoFactura.borrador: return 'borrador';
      case EstadoFactura.timbrado: return 'timbrado';
    }
  }

  String get displayName {
    switch (this) {
      case EstadoFactura.borrador: return 'Borrador';
      case EstadoFactura.timbrado: return 'Timbrada';
    }
  }

  static EstadoFactura fromKey(String k) =>
      k == 'timbrado' ? EstadoFactura.timbrado : EstadoFactura.borrador;

  bool get editable   => this != EstadoFactura.timbrado;
  bool get eliminable => this != EstadoFactura.timbrado;
}


class ConceptoFactura {
  final String nombre;
  final String descripcion;
  final double precioUnitario;
  final int cantidad;
  final double descuentoPct;
  final String claveProdServ;
  final String claveUnidad;
  final String objetoImp;

  const ConceptoFactura({
    required this.nombre,
    required this.descripcion,
    required this.precioUnitario,
    required this.cantidad,
    this.descuentoPct = 0,
    this.claveProdServ = '01010101',
    this.claveUnidad = 'H87',
    this.objetoImp = '02',
  });

  double get montoDescuento =>
      precioUnitario * cantidad * (descuentoPct / 100);
  double get importe =>
      precioUnitario * cantidad * ((100 - descuentoPct) / 100);
  double get iva16 =>
      double.parse((importe * 0.16).toStringAsFixed(2));
  double get totalConIva => importe + iva16;

  factory ConceptoFactura.fromMap(Map<String, dynamic> m) => ConceptoFactura(
    nombre: m['nombre'] ?? '',
    descripcion: m['descripcion'] ?? '',
    precioUnitario: (m['precioUnitario'] as num?)?.toDouble() ?? 0,
    cantidad: (m['cantidad'] as num?)?.toInt() ?? 1,
    descuentoPct: (m['descuentoPct'] as num?)?.toDouble() ?? 0,
    claveProdServ: m['claveProdServ'] ?? '01010101',
    claveUnidad: m['claveUnidad'] ?? 'H87',
    objetoImp: m['objetoImp'] ?? '02',
  );

  Map<String, dynamic> toMap() => {
    'nombre': nombre, 'descripcion': descripcion,
    'precioUnitario': precioUnitario, 'cantidad': cantidad,
    'descuentoPct': descuentoPct, 'claveProdServ': claveProdServ,
    'claveUnidad': claveUnidad, 'objetoImp': objetoImp,
  };
}


class Factura {
  final String id;
  final String uid;
  final String cotizacionId;
  final EstadoFactura estatus;

  final String rfcEmisor;
  final String nombreEmisor;
  final String regimenFiscalEmisor;
  final String codigoPostalEmisor;

  final String rfcReceptor;
  final String nombreReceptor;
  final String regimenFiscalReceptor;
  final String codigoPostalReceptor;
  final String usoCfdi;

  final String formaPago;
  final String metodoPago;
  final String moneda;
  final String tipoComprobante;
  final String serie;
  final String? condicionesDePago;

  final List<ConceptoFactura> conceptos;

  final String? facturapiId;  
  final String? uuid;    
  final String? pdfUrl;      
  final DateTime? fechaTimbrado;

  final DateTime? creadoEn;
  final String fecha;

  const Factura({
    required this.id,
    required this.uid,
    required this.cotizacionId,
    this.estatus = EstadoFactura.borrador,
    required this.rfcEmisor,
    required this.nombreEmisor,
    required this.regimenFiscalEmisor,
    required this.codigoPostalEmisor,
    required this.rfcReceptor,
    required this.nombreReceptor,
    this.regimenFiscalReceptor = '601',
    required this.codigoPostalReceptor,
    this.usoCfdi = 'G03',
    this.formaPago = '99',
    this.metodoPago = 'PUE',
    this.moneda = 'MXN',
    this.tipoComprobante = 'I',
    this.serie = 'A',
    this.condicionesDePago,
    required this.conceptos,
    this.facturapiId,
    this.uuid,
    this.pdfUrl,
    this.fechaTimbrado,
    this.creadoEn,
    required this.fecha,
  });

  double get subtotal => conceptos.fold(0, (s, c) => s + c.importe);
  double get totalIva => conceptos.fold(0, (s, c) => s + c.iva16);
  double get total    => subtotal + totalIva;
  String get totalFormateado => '\$${total.toStringAsFixed(2)}';

  bool get estaTimbrada => estatus == EstadoFactura.timbrado && uuid != null;
  bool get puedeTimbrarse =>
      estatus == EstadoFactura.borrador &&
      validarParaCfdi().isEmpty;

  List<String> validarParaCfdi() {
    final e = <String>[];
    if (rfcEmisor.isEmpty)  e.add('RFC del emisor obligatorio');
    if (nombreEmisor.isEmpty) e.add('Nombre del emisor obligatorio');
    if (codigoPostalEmisor.length != 5) e.add('Código postal del emisor inválido (5 dígitos)');
    if (rfcReceptor.isEmpty) e.add('RFC del receptor obligatorio');
    if (nombreReceptor.isEmpty) e.add('Nombre del receptor obligatorio');
    if (codigoPostalReceptor.length != 5) e.add('Código postal del receptor inválido (5 dígitos)');
    if (conceptos.isEmpty) e.add('Debe haber al menos un concepto');
    return e;
  }

  Map<String, dynamic> toMap() => {
    'uid': uid, 'cotizacionId': cotizacionId, 'estatus': estatus.key,
    'rfcEmisor': rfcEmisor, 'nombreEmisor': nombreEmisor,
    'regimenFiscalEmisor': regimenFiscalEmisor, 'codigoPostalEmisor': codigoPostalEmisor,
    'rfcReceptor': rfcReceptor, 'nombreReceptor': nombreReceptor,
    'regimenFiscalReceptor': regimenFiscalReceptor, 'codigoPostalReceptor': codigoPostalReceptor,
    'usoCfdi': usoCfdi, 'formaPago': formaPago, 'metodoPago': metodoPago,
    'moneda': moneda, 'tipoComprobante': tipoComprobante, 'serie': serie,
    'condicionesDePago': condicionesDePago ?? 'CONTADO',
    'conceptos': conceptos.map((c) => c.toMap()).toList(),
    'facturapiId': facturapiId,
    'uuid': uuid,
    'pdfUrl': pdfUrl,
    'fechaTimbrado': fechaTimbrado != null ? Timestamp.fromDate(fechaTimbrado!) : null,
    'fecha': fecha,
    'creadoEn': FieldValue.serverTimestamp(),
  };

  factory Factura.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Factura(
      id: doc.id, uid: d['uid'] ?? '', cotizacionId: d['cotizacionId'] ?? '',
      estatus: EstadoFacturaX.fromKey(d['estatus'] ?? ''),
      rfcEmisor: d['rfcEmisor'] ?? '', nombreEmisor: d['nombreEmisor'] ?? '',
      regimenFiscalEmisor: d['regimenFiscalEmisor'] ?? '601',
      codigoPostalEmisor: d['codigoPostalEmisor'] ?? '',
      rfcReceptor: d['rfcReceptor'] ?? '', nombreReceptor: d['nombreReceptor'] ?? '',
      regimenFiscalReceptor: d['regimenFiscalReceptor'] ?? '601',
      codigoPostalReceptor: d['codigoPostalReceptor'] ?? '',
      usoCfdi: d['usoCfdi'] ?? 'G03', formaPago: d['formaPago'] ?? '99',
      metodoPago: d['metodoPago'] ?? 'PUE', moneda: d['moneda'] ?? 'MXN',
      tipoComprobante: d['tipoComprobante'] ?? 'I', serie: d['serie'] ?? 'A',
      condicionesDePago: d['condicionesDePago'],
      conceptos: ((d['conceptos'] as List?)?.cast<Map<String, dynamic>>() ?? [])
          .map(ConceptoFactura.fromMap).toList(),
      facturapiId: d['facturapiId'],
      uuid: d['uuid'],
      pdfUrl: d['pdfUrl'],
      fechaTimbrado: (d['fechaTimbrado'] as Timestamp?)?.toDate(),
      creadoEn: (d['creadoEn'] as Timestamp?)?.toDate(),
      fecha: d['fecha'] ?? '',
    );
  }

  Factura copyWith({
    String? id, String? uid, String? cotizacionId, EstadoFactura? estatus,
    String? rfcEmisor, String? nombreEmisor, String? regimenFiscalEmisor,
    String? codigoPostalEmisor, String? rfcReceptor, String? nombreReceptor,
    String? regimenFiscalReceptor, String? codigoPostalReceptor,
    String? usoCfdi, String? formaPago, String? metodoPago, String? moneda,
    String? tipoComprobante, String? serie, String? condicionesDePago,
    List<ConceptoFactura>? conceptos,
    String? facturapiId, String? uuid, String? pdfUrl,
    DateTime? fechaTimbrado, DateTime? creadoEn, String? fecha,
  }) => Factura(
    id: id ?? this.id, uid: uid ?? this.uid,
    cotizacionId: cotizacionId ?? this.cotizacionId,
    estatus: estatus ?? this.estatus,
    rfcEmisor: rfcEmisor ?? this.rfcEmisor,
    nombreEmisor: nombreEmisor ?? this.nombreEmisor,
    regimenFiscalEmisor: regimenFiscalEmisor ?? this.regimenFiscalEmisor,
    codigoPostalEmisor: codigoPostalEmisor ?? this.codigoPostalEmisor,
    rfcReceptor: rfcReceptor ?? this.rfcReceptor,
    nombreReceptor: nombreReceptor ?? this.nombreReceptor,
    regimenFiscalReceptor: regimenFiscalReceptor ?? this.regimenFiscalReceptor,
    codigoPostalReceptor: codigoPostalReceptor ?? this.codigoPostalReceptor,
    usoCfdi: usoCfdi ?? this.usoCfdi, formaPago: formaPago ?? this.formaPago,
    metodoPago: metodoPago ?? this.metodoPago, moneda: moneda ?? this.moneda,
    tipoComprobante: tipoComprobante ?? this.tipoComprobante,
    serie: serie ?? this.serie, condicionesDePago: condicionesDePago ?? this.condicionesDePago,
    conceptos: conceptos ?? this.conceptos,
    facturapiId: facturapiId ?? this.facturapiId,
    uuid: uuid ?? this.uuid, pdfUrl: pdfUrl ?? this.pdfUrl,
    fechaTimbrado: fechaTimbrado ?? this.fechaTimbrado,
    creadoEn: creadoEn ?? this.creadoEn, fecha: fecha ?? this.fecha,
  );
}
