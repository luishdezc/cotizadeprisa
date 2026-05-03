import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cotizadeprisa/app/models/cotizacion.dart';

class CotizacionService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('usuarios').doc(uid).collection('cotizaciones');

  Stream<List<Cotizacion>> watch(String uid) =>
      _col(uid).orderBy('creadoEn', descending: true).snapshots()
          .map((s) => s.docs.map(Cotizacion.fromFirestore).toList());

  Future<Cotizacion> crear(String uid, Cotizacion c) async {
    final map = c.toMap()..['uid'] = uid;
    final ref = await _col(uid).add(map);
    return c.copyWith(id: ref.id, uid: uid);
  }

  Future<void> actualizar(String uid, Cotizacion c) async {
    if (!c.estatus.editable) throw Exception('No se puede editar una cotización ya facturada.');
    await _col(uid).doc(c.id).update(c.toMap());
  }

  Future<void> eliminar(String uid, String id) async =>
      _col(uid).doc(id).delete();

  Future<Cotizacion?> obtener(String uid, String id) async {
    final doc = await _col(uid).doc(id).get();
    return doc.exists ? Cotizacion.fromFirestore(doc) : null;
  }

  Future<void> marcarFacturada(String uid, String id, String facturaId) async =>
      _col(uid).doc(id).update({
        'estatus': EstadoCotizacion.facturada.key,
        'facturaId': facturaId,
        'actualizadoEn': FieldValue.serverTimestamp(),
      });
}
