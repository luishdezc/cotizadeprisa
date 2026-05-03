import 'package:cloud_firestore/cloud_firestore.dart';


class Cliente {
  final String id;
  final String nombre;
  final String rfc;
  final String correo;
  final String? telefono;
  final String? direccion;
  final String? usoCfdi;
  final String? regimenFiscal;
  final String codigoPostal; 

  const Cliente({
    required this.id,
    required this.nombre,
    required this.rfc,
    required this.correo,
    this.telefono,
    this.direccion,
    this.usoCfdi,
    this.regimenFiscal,
    this.codigoPostal = '',
  });

  factory Cliente.fromMap(Map<String, dynamic> map, String id) {
    return Cliente(
      id: id,
      nombre: map['nombre'] ?? '',
      rfc: map['rfc'] ?? '',
      correo: map['correo'] ?? '',
      telefono: map['telefono'],
      direccion: map['direccion'],
      usoCfdi: map['usoCfdi'],
      regimenFiscal: map['regimenFiscal'],
      codigoPostal: map['codigoPostal'] ?? '',
    );
  }

  factory Cliente.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Cliente.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'rfc': rfc,
      'correo': correo,
      'telefono': telefono,
      'direccion': direccion,
      'usoCfdi': usoCfdi ?? 'G03',
      'regimenFiscal': regimenFiscal ?? '601',
      'codigoPostal': codigoPostal,
    };
  }

  Cliente copyWith({
    String? id, String? nombre, String? rfc, String? correo,
    String? telefono, String? direccion, String? usoCfdi,
    String? regimenFiscal, String? codigoPostal,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      rfc: rfc ?? this.rfc,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      usoCfdi: usoCfdi ?? this.usoCfdi,
      regimenFiscal: regimenFiscal ?? this.regimenFiscal,
      codigoPostal: codigoPostal ?? this.codigoPostal,
    );
  }

  String get iniciales {
    final parts = nombre.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }
}
