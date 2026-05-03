import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cotizadeprisa/app/models/cliente.dart';

class ClienteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('usuarios').doc(uid).collection('clientes');


  Stream<List<Cliente>> watchClientes(String uid) {
    return _col(uid)
        .orderBy('nombre')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Cliente.fromFirestore(d)).toList());
  }


  Future<Cliente> crearCliente(String uid, Cliente cliente) async {
    final ref = await _col(uid).add(cliente.toMap());
    return cliente.copyWith(id: ref.id);
  }

  Future<void> actualizarCliente(String uid, Cliente cliente) async {
    await _col(uid).doc(cliente.id).update(cliente.toMap());
  }

  Future<void> eliminarCliente(String uid, String clienteId) async {
    await _col(uid).doc(clienteId).delete();
  }

  Future<Cliente?> obtenerCliente(String uid, String clienteId) async {
    final doc = await _col(uid).doc(clienteId).get();
    if (!doc.exists) return null;
    return Cliente.fromFirestore(doc);
  }
}
