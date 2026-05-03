import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoCotizacion { borrador, enviada, aceptada, rechazada, facturada }

extension EstadoCotizacionX on EstadoCotizacion {
  String get key {
    switch (this) {
      case EstadoCotizacion.borrador:  return 'borrador';
      case EstadoCotizacion.enviada:   return 'enviada';
      case EstadoCotizacion.aceptada:  return 'aceptada';
      case EstadoCotizacion.rechazada: return 'rechazada';
      case EstadoCotizacion.facturada: return 'facturada';
    }
  }

  String get displayName {
    switch (this) {
      case EstadoCotizacion.borrador:  return 'Borrador';
      case EstadoCotizacion.enviada:   return 'Enviada';
      case EstadoCotizacion.aceptada:  return 'Aceptada';
      case EstadoCotizacion.rechazada: return 'Rechazada';
      case EstadoCotizacion.facturada: return 'Facturada';
    }
  }

  static EstadoCotizacion fromKey(String k) {
    switch (k) {
      case 'enviada':   return EstadoCotizacion.enviada;
      case 'aceptada':  return EstadoCotizacion.aceptada;
      case 'rechazada': return EstadoCotizacion.rechazada;
      case 'facturada': return EstadoCotizacion.facturada;
      default:          return EstadoCotizacion.borrador;
    }
  }

  bool get editable => this != EstadoCotizacion.facturada;
}

class ConceptoCotizacion {
  final String nombre;
  final String descripcion;
  final double precioUnitario;
  final int cantidad;
  final double descuentoPct;

  static const String claveProdServDefault = '01010101';
  static const String claveUnidadDefault   = 'H87';

  const ConceptoCotizacion({
    required this.nombre,
    required this.descripcion,
    required this.precioUnitario,
    required this.cantidad,
    this.descuentoPct = 0,
  });

  double get subtotal =>
      precioUnitario * cantidad * ((100 - descuentoPct) / 100);

  double ivaConTasa(double tasaPct) =>
      double.parse((subtotal * (tasaPct / 100)).toStringAsFixed(2));

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'precioUnitario': precioUnitario,
        'cantidad': cantidad,
        'descuentoPct': descuentoPct,
        'claveProdServ': claveProdServDefault,
        'claveUnidad': claveUnidadDefault,
      };

  factory ConceptoCotizacion.fromMap(Map<String, dynamic> m) =>
      ConceptoCotizacion(
        nombre: m['nombre'] ?? '',
        descripcion: m['descripcion'] ?? '',
        precioUnitario: (m['precioUnitario'] as num?)?.toDouble() ?? 0,
        cantidad: (m['cantidad'] as num?)?.toInt() ?? 1,
        descuentoPct: (m['descuentoPct'] as num?)?.toDouble() ?? 0,
      );

  String get precioIndividual => precioUnitario.toString();
  String get cantidadInicial  => cantidad.toString();
  String get descuento        => descuentoPct.toString();
  double get totalwithDiscount => subtotal;
}

class Cotizacion {
  final String id;
  final String uid;
  final String titulo;
  final String asunto;
  final String fecha;
  final EstadoCotizacion estatus;
  final String clienteId;
  final String clienteNombre;
  final String clienteCorreo;
  final List<ConceptoCotizacion> conceptos;
  final double tasaIva;
  final DateTime? creadoEn;
  final DateTime? actualizadoEn;
  final String? facturaId;

  const Cotizacion({
    required this.id,
    required this.uid,
    required this.titulo,
    required this.asunto,
    required this.fecha,
    this.estatus = EstadoCotizacion.borrador,
    this.clienteId = '',
    this.clienteNombre = '',
    this.clienteCorreo = '',
    required this.conceptos,
    this.tasaIva = 16.0,
    this.creadoEn,
    this.actualizadoEn,
    this.facturaId,
  });

  double get subtotal => conceptos.fold(0, (s, c) => s + c.subtotal);
  double get totalIva => conceptos.fold(0, (s, c) => s + c.ivaConTasa(tasaIva));
  double get total    => subtotal + totalIva;
  String get totalFormateado => '\$${total.toStringAsFixed(2)}';

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'titulo': titulo,
        'asunto': asunto,
        'fecha': fecha,
        'estatus': estatus.key,
        'clienteId': clienteId,
        'clienteNombre': clienteNombre,
        'clienteCorreo': clienteCorreo,
        'conceptos': conceptos.map((c) => c.toMap()).toList(),
        'tasaIva': tasaIva,
        'facturaId': facturaId,
        'actualizadoEn': FieldValue.serverTimestamp(),
        'creadoEn': creadoEn != null
            ? Timestamp.fromDate(creadoEn!)
            : FieldValue.serverTimestamp(),
      };

  factory Cotizacion.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Cotizacion(
      id: doc.id,
      uid: d['uid'] ?? '',
      titulo: d['titulo'] ?? '',
      asunto: d['asunto'] ?? '',
      fecha: d['fecha'] ?? '',
      estatus: EstadoCotizacionX.fromKey(d['estatus'] ?? ''),
      clienteId: d['clienteId'] ?? '',
      clienteNombre: d['clienteNombre'] ?? '',
      clienteCorreo: d['clienteCorreo'] ?? '',
      conceptos: ((d['conceptos'] as List?)?.cast<Map<String, dynamic>>() ?? [])
          .map(ConceptoCotizacion.fromMap)
          .toList(),
      tasaIva: (d['tasaIva'] as num?)?.toDouble() ?? 16.0,
      facturaId: d['facturaId'],
      creadoEn: (d['creadoEn'] as Timestamp?)?.toDate(),
      actualizadoEn: (d['actualizadoEn'] as Timestamp?)?.toDate(),
    );
  }

  Cotizacion copyWith({
    String? id, String? uid, String? titulo, String? asunto,
    String? fecha, EstadoCotizacion? estatus,
    String? clienteId, String? clienteNombre, String? clienteCorreo,
    List<ConceptoCotizacion>? conceptos, double? tasaIva,
    DateTime? creadoEn, DateTime? actualizadoEn, String? facturaId,
  }) => Cotizacion(
    id: id ?? this.id, uid: uid ?? this.uid,
    titulo: titulo ?? this.titulo, asunto: asunto ?? this.asunto,
    fecha: fecha ?? this.fecha, estatus: estatus ?? this.estatus,
    clienteId: clienteId ?? this.clienteId,
    clienteNombre: clienteNombre ?? this.clienteNombre,
    clienteCorreo: clienteCorreo ?? this.clienteCorreo,
    conceptos: conceptos ?? this.conceptos,
    tasaIva: tasaIva ?? this.tasaIva,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    facturaId: facturaId ?? this.facturaId,
  );
}
