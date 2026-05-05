
const Map<String, List<Map<String, String>>> satCatalog = {
  'Alimentos y bebidas': [
    {'nombre': 'Bebidas no alcohólicas', 'clave': '50202306'},
    {'nombre': 'Agua embotellada',        'clave': '50202301'},
    {'nombre': 'Refrescos',               'clave': '50202304'},
    {'nombre': 'Jugos',                   'clave': '50202303'},
    {'nombre': 'Café',                    'clave': '50201700'},
    {'nombre': 'Té',                      'clave': '50201706'},
    {'nombre': 'Pan y pasteles',          'clave': '50181900'},
    {'nombre': 'Dulces y confitería',     'clave': '50161800'},
  ],
  'Tecnología': [
    {'nombre': 'Laptop',                  'clave': '43211503'},
    {'nombre': 'Computadora de escritorio','clave': '43211507'},
    {'nombre': 'Tablet',                  'clave': '43211509'},
    {'nombre': 'Celular',                 'clave': '43191501'},
    {'nombre': 'Impresora',               'clave': '43212105'},
    {'nombre': 'Monitores',               'clave': '43211902'},
    {'nombre': 'Teclado',                 'clave': '43211706'},
    {'nombre': 'Mouse',                   'clave': '43211708'},
    {'nombre': 'Accesorios de cómputo',   'clave': '43212000'},
  ],
  'Ropa y accesorios': [
    {'nombre': 'Camisas',                 'clave': '53101500'},
    {'nombre': 'Pantalones',              'clave': '53101502'},
    {'nombre': 'Vestidos',                'clave': '53101503'},
    {'nombre': 'Calzado',                 'clave': '53111600'},
    {'nombre': 'Accesorios personales',   'clave': '53102500'},
    {'nombre': 'Ropa deportiva',          'clave': '53102900'},
  ],
  'Servicios profesionales': [
    {'nombre': 'Consultoría empresarial', 'clave': '80101500'},
    {'nombre': 'Servicios legales',       'clave': '80121600'},
    {'nombre': 'Servicios contables',     'clave': '84111500'},
    {'nombre': 'Servicios de marketing',  'clave': '80141600'},
    {'nombre': 'Desarrollo de software',  'clave': '81112100'},
    {'nombre': 'Soporte técnico',         'clave': '81111800'},
  ],
  'Salud': [
    {'nombre': 'Consulta médica',         'clave': '85101501'},
    {'nombre': 'Servicios hospitalarios', 'clave': '85101502'},
    {'nombre': 'Medicamentos',            'clave': '51101500'},
    {'nombre': 'Análisis clínicos',       'clave': '85121800'},
    {'nombre': 'Servicios dentales',      'clave': '85121500'},
  ],
  'Educación': [
    {'nombre': 'Cursos en línea',         'clave': '86101700'},
    {'nombre': 'Capacitación empresarial','clave': '86101800'},
    {'nombre': 'Servicios educativos',    'clave': '86111500'},
    {'nombre': 'Material educativo',      'clave': '60101300'},
  ],
  'Transporte': [
    {'nombre': 'Transporte de pasajeros', 'clave': '78111800'},
    {'nombre': 'Servicios de taxi',       'clave': '78111804'},
    {'nombre': 'Envío de paquetería',     'clave': '78102200'},
    {'nombre': 'Mensajería',              'clave': '78102201'},
  ],
  'Construcción': [
    {'nombre': 'Servicios de construcción','clave': '72101500'},
    {'nombre': 'Materiales de construcción','clave': '30100000'},
    {'nombre': 'Servicios de mantenimiento','clave': '72102900'},
    {'nombre': 'Electricidad',            'clave': '72151500'},
    {'nombre': 'Plomería',                'clave': '72154000'},
  ],
  'Hogar': [
    {'nombre': 'Electrodomésticos',       'clave': '52150000'},
    {'nombre': 'Muebles',                 'clave': '56101500'},
    {'nombre': 'Artículos de limpieza',   'clave': '47131800'},
    {'nombre': 'Decoración',              'clave': '49101600'},
  ],
  'Entretenimiento': [
    {'nombre': 'Servicios de streaming',  'clave': '81112105'},
    {'nombre': 'Videojuegos',             'clave': '60141000'},
    {'nombre': 'Eventos',                 'clave': '80141607'},
    {'nombre': 'Producción audiovisual',  'clave': '82131600'},
  ],
  'Automotriz': [
    {'nombre': 'Reparación de vehículos', 'clave': '78181500'},
    {'nombre': 'Refacciones',             'clave': '25170000'},
    {'nombre': 'Servicios de mantenimiento','clave': '78181504'},
    {'nombre': 'Venta de autos',          'clave': '25101500'},
  ],
  'Finanzas': [
    {'nombre': 'Servicios bancarios',     'clave': '84121500'},
    {'nombre': 'Seguros',                 'clave': '84131500'},
    {'nombre': 'Inversiones',             'clave': '84121800'},
    {'nombre': 'Créditos',                'clave': '84121600'},
  ],
  'Otros': [
    {'nombre': 'Producto genérico',       'clave': '01010101'},
  ],
};

/// Devuelve la clave SAT para una subcategoría dada dentro de una categoría.
/// Retorna '01010101' si no se encuentra.
String getClaveSat(String category, String subcategory) {
  final subs = satCatalog[category] ?? [];
  final found = subs.firstWhere(
    (m) => m['nombre'] == subcategory,
    orElse: () => {'clave': '01010101'},
  );
  return found['clave'] ?? '01010101';
}
