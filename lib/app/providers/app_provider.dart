import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {

  String? _cerPath;
  String? _keyPath;
  String? _cerPassword;
  bool _certificadosCargados = false;

  String? get cerPath => _cerPath;
  String? get keyPath => _keyPath;
  bool get certificadosCargados => _certificadosCargados;

  void setCertificados({
    required String cerPath,
    required String keyPath,
    required String password,
  }) {
    _cerPath = cerPath;
    _keyPath = keyPath;
    _cerPassword = password;
    _certificadosCargados = true;
    notifyListeners();
  }

  void limpiarCertificados() {
    _cerPath = null;
    _keyPath = null;
    _cerPassword = null;
    _certificadosCargados = false;
    notifyListeners();
  }
}
