import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cotizadeprisa/app/models/factura.dart';


class FacturaService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('usuarios').doc(uid).collection('facturas');

  Stream<List<Factura>> watch(String uid) =>
      _col(uid)
          .orderBy('creadoEn', descending: true)
          .snapshots()
          .map((s) => s.docs.map(Factura.fromFirestore).toList());

  Future<Factura> crear(String uid, Factura f) async {
    final ref = await _col(uid).add(f.toMap()..['uid'] = uid);
    return f.copyWith(id: ref.id, uid: uid);
  }

  Future<void> actualizar(String uid, Factura f) async {
    if (!f.estatus.editable) {
      throw Exception('La factura timbrada es inmutable — no se puede editar.');
    }
    await _col(uid).doc(f.id).update(f.toMap());
  }

  Future<void> eliminar(String uid, String id) async {
    final doc = await _col(uid).doc(id).get();
    if (!doc.exists) return;
    final f = Factura.fromFirestore(doc);
    if (!f.estatus.eliminable) {
      throw Exception('No se puede eliminar una factura timbrada.');
    }
    await _col(uid).doc(id).delete();
  }

  Future<Factura?> obtener(String uid, String id) async {
    final doc = await _col(uid).doc(id).get();
    return doc.exists ? Factura.fromFirestore(doc) : null;
  }

  Future<void> guardarTimbrado(
    String uid,
    String id, {
    required String uuid,
    required String facturapiId,
    String? pdfUrl,
  }) async {
    await _col(uid).doc(id).update({
      'uuid': uuid,
      'facturapiId': facturapiId,
      if (pdfUrl != null) 'pdfUrl': pdfUrl,
      'estatus': EstadoFactura.timbrado.key,
      'fechaTimbrado': FieldValue.serverTimestamp(),
    });
  }
}
