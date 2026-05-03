import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cotizadeprisa/app/models/empresa_perfil.dart';

class EmpresaPerfilService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('usuarios').doc(uid);

  Stream<EmpresaPerfil?> watchPerfil(String uid) {
    return _doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return EmpresaPerfil.fromFirestore(snap);
    });
  }

  Future<EmpresaPerfil?> obtenerPerfil(String uid) async {
    final doc = await _doc(uid).get();
    if (!doc.exists) return null;
    return EmpresaPerfil.fromFirestore(doc);
  }

  Future<void> guardarPerfil(EmpresaPerfil perfil) async {
    await _doc(perfil.uid).set(perfil.toMap(), SetOptions(merge: true));
  }

  Future<void> actualizarCampo(String uid, String campo, dynamic valor) async {
    await _doc(uid).update({campo: valor});
  }
}
