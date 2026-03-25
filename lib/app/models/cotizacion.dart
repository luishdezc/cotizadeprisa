enum EstadoCotizacion {
  pendienteDeAceptar,
  aceptada,
  rechazada,
  facturada,
  timbrada,
  pagada,
}

extension EstadoCotizacionExtension on EstadoCotizacion {
  String get displayName {
    switch (this) {
      case EstadoCotizacion.pendienteDeAceptar:
        return 'Pendiente de aceptar';
      case EstadoCotizacion.aceptada:
        return 'Aceptada';
      case EstadoCotizacion.rechazada:
        return 'Rechazada';
      case EstadoCotizacion.facturada:
        return 'Facturada';
      case EstadoCotizacion.timbrada:
        return 'Timbrada';
      case EstadoCotizacion.pagada:
        return 'Pagada';
    }
  }
}

class Cotizacion {
  final String id;
  final String titulo;
  final String fecha;
  final String cliente;
  final String rfcCliente;
  final String asunto;
  final String total;
  final EstadoCotizacion estatus;
  final List<Map<String, String>> productos;

  const Cotizacion({
    required this.id,
    required this.titulo,
    required this.fecha,
    required this.cliente,
    required this.rfcCliente,
    required this.asunto,
    required this.total,
    required this.estatus,
    required this.productos,
  });
}