import 'package:cloud_firestore/cloud_firestore.dart';


class EmpresaPerfil {
  final String uid;
  final String nombre;
  final String slogan;
  final String correo;
  final String telefono;
  final String usuario;
  final String direccion;
  final String codigoPostal;
  final String rfc;
  final String regimenFiscal;
  final double impuesto;
  final String? logoPath; 

  const EmpresaPerfil({
    required this.uid,
    this.nombre = '',
    this.slogan = '',
    this.correo = '',
    this.telefono = '',
    this.usuario = '',
    this.direccion = '',
    this.codigoPostal = '',
    this.rfc = '',
    this.regimenFiscal = '601',
    this.impuesto = 16.0,
    this.logoPath,
  });

  factory EmpresaPerfil.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmpresaPerfil(
      uid: doc.id,
      nombre: data['nombre'] ?? '',
      slogan: data['slogan'] ?? '',
      correo: data['correo'] ?? '',
      telefono: data['telefono'] ?? '',
      usuario: data['usuario'] ?? '',
      direccion: data['direccion'] ?? '',
      codigoPostal: data['codigoPostal'] ?? _extraerCp(data['direccion'] ?? ''),
      rfc: data['rfc'] ?? '',
      regimenFiscal: data['regimenFiscal'] ?? '601',
      impuesto: (data['impuesto'] as num?)?.toDouble() ?? 16.0,
      logoPath: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'slogan': slogan,
      'correo': correo,
      'telefono': telefono,
      'usuario': usuario,
      'direccion': direccion,
      'codigoPostal': codigoPostal,
      'rfc': rfc,
      'regimenFiscal': regimenFiscal,
      'impuesto': impuesto,
      // logoPath NO se guarda en Firestore (solo local)
      'actualizadoEn': FieldValue.serverTimestamp(),
    };
  }

  EmpresaPerfil copyWith({
    String? nombre,
    String? slogan,
    String? correo,
    String? telefono,
    String? usuario,
    String? direccion,
    String? codigoPostal,
    String? rfc,
    String? regimenFiscal,
    double? impuesto,
    String? logoPath,
  }) {
    return EmpresaPerfil(
      uid: uid,
      nombre: nombre ?? this.nombre,
      slogan: slogan ?? this.slogan,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      usuario: usuario ?? this.usuario,
      direccion: direccion ?? this.direccion,
      codigoPostal: codigoPostal ?? this.codigoPostal,
      rfc: rfc ?? this.rfc,
      regimenFiscal: regimenFiscal ?? this.regimenFiscal,
      impuesto: impuesto ?? this.impuesto,
      logoPath: logoPath ?? this.logoPath,
    );
  }

  bool get perfilCompleto =>
      nombre.isNotEmpty && rfc.isNotEmpty && codigoPostal.length == 5;

  static String _extraerCp(String direccion) {
    final match = RegExp(r'\b\d{5}\b').firstMatch(direccion);
    return match?.group(0) ?? '';
  }

  String get regimenFiscalDescripcion {
    const catalogoCat = {
      '601': 'General de Ley Personas Morales',
      '603': 'Personas Morales con Fines no Lucrativos',
      '605': 'Sueldos y Salarios e Ingresos Asimilados a Salarios',
      '606': 'Arrendamiento',
      '608': 'Demás ingresos',
      '609': 'Consolidación',
      '610': 'Residentes en el Extranjero sin EP en México',
      '611': 'Ingresos por Dividendos',
      '612': 'Personas Físicas con Actividades Empresariales y Profesionales',
      '614': 'Ingresos por intereses',
      '616': 'Sin obligaciones fiscales',
      '620': 'Sociedades Cooperativas de Producción',
      '621': 'Incorporación Fiscal',
      '622': 'Actividades Agrícolas, Ganaderas, Silvícolas y Pesqueras',
      '623': 'Opcional para Grupos de Sociedades',
      '624': 'Coordinados',
      '628': 'Hidrocarburos',
      '607': 'Régimen de Enajenación o Adquisición de Bienes',
      '629': 'De los Regímenes Fiscales Preferentes y de las Empresas Multinacionales',
      '630': 'Enajenación de acciones en bolsa de valores',
      '615': 'Régimen de los ingresos por obtención de premios',
      '626': 'Régimen Simplificado de Confianza',
    };
    return catalogoCat[regimenFiscal] ?? regimenFiscal;
  }
}
