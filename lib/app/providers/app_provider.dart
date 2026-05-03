import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cotizadeprisa/app/models/cliente.dart';
import 'package:cotizadeprisa/app/models/cotizacion.dart';
import 'package:cotizadeprisa/app/models/empresa_perfil.dart';
import 'package:cotizadeprisa/app/models/factura.dart';
import 'package:cotizadeprisa/app/services/cliente_service.dart';
import 'package:cotizadeprisa/app/services/cotizacion_service.dart';
import 'package:cotizadeprisa/app/services/empresa_perfil_service.dart';
import 'package:cotizadeprisa/app/services/factura_service.dart';
import 'package:cotizadeprisa/app/services/facturapi_service.dart';
import 'package:cotizadeprisa/app/services/logo_service.dart';

enum AppStatus { idle, loading, error }

class AppProvider extends ChangeNotifier {
  final _cotizSvc   = CotizacionService();
  final _facturaSvc = FacturaService();
  final _clienteSvc = ClienteService();
  final _perfilSvc  = EmpresaPerfilService();

  AppStatus _status = AppStatus.idle;
  String?   _errorMessage;
  AppStatus get status       => _status;
  String?   get errorMessage => _errorMessage;
  bool      get isLoading    => _status == AppStatus.loading;

  EmpresaPerfil? _perfil;
  EmpresaPerfil? get perfil => _perfil;
  String? _logoPath;
  String? get logoPath => _logoPath;

  List<Cliente>    _clientes     = [];
  List<Cotizacion> _cotizaciones = [];
  List<Factura>    _facturas     = [];

  List<Cliente>    get clientes     => List.unmodifiable(_clientes);
  List<Cotizacion> get cotizaciones => List.unmodifiable(_cotizaciones);
  List<Factura>    get facturas     => List.unmodifiable(_facturas);

  String? _cerPath, _keyPath, _cerPassword;
  bool _certsCargados = false;
  bool get certificadosCargados => _certsCargados;

  StreamSubscription? _perfilSub, _clientesSub, _cotizSub, _facturaSub;


  Future<void> init(User user) async {
    _iniciarStreams(user.uid);
    _logoPath = await LogoService.instance.obtenerRutaLogo();
    notifyListeners();
  }

  void _iniciarStreams(String uid) {
    _perfilSub?.cancel();
    _perfilSub = _perfilSvc.watchPerfil(uid).listen((p) {
      _perfil = p; notifyListeners();
    });

    _clientesSub?.cancel();
    _clientesSub = _clienteSvc.watchClientes(uid).listen((list) {
      _clientes = list; notifyListeners();
    });

    _cotizSub?.cancel();
    _cotizSub = _cotizSvc.watch(uid).listen((list) {
      _cotizaciones = list; notifyListeners();
    });

    _facturaSub?.cancel();
    _facturaSub = _facturaSvc.watch(uid).listen((list) {
      _facturas = list; notifyListeners();
    });
  }

  void limpiarStreams() {
    _perfilSub?.cancel(); _clientesSub?.cancel();
    _cotizSub?.cancel(); _facturaSub?.cancel();
    _perfil = null; _clientes = []; _cotizaciones = []; _facturas = [];
    _logoPath = null;
    notifyListeners();
  }


  Future<bool> seleccionarLogo() async {
    final p = await LogoService.instance.seleccionarYGuardarLogo();
    if (p != null) { _logoPath = p; notifyListeners(); return true; }
    return false;
  }

  Future<void> eliminarLogo() async {
    await LogoService.instance.eliminarLogo();
    _logoPath = null; notifyListeners();
  }


  void setCertificados({
    required String cerPath,
    required String keyPath,
    required String password,
  }) {
    _cerPath = cerPath; _keyPath = keyPath; _cerPassword = password;
    _certsCargados = true; notifyListeners();
  }

  void limpiarCertificados() {
    _cerPath = _keyPath = _cerPassword = null;
    _certsCargados = false; notifyListeners();
  }


  Future<bool> guardarPerfil(EmpresaPerfil p) async {
    _setLoading();
    try { await _perfilSvc.guardarPerfil(p); _setIdle(); return true; }
    catch (e) { _setError('Error al guardar perfil: $e'); return false; }
  }

  Future<bool> guardarOnboarding({
    required String uid, required String nombre, required String slogan,
    required String correo, required String telefono, required String usuario,
    required String direccion, required String codigoPostal,
    required String rfc, required String regimenFiscal,
  }) async {
    _setLoading();
    try {
      final p = EmpresaPerfil(
        uid: uid, nombre: nombre.trim(), slogan: slogan.trim(),
        correo: correo.trim(), telefono: telefono.trim(),
        usuario: usuario.trim(), direccion: direccion.trim(),
        codigoPostal: codigoPostal.trim(),
        rfc: rfc.trim().toUpperCase(),
        regimenFiscal: regimenFiscal.isNotEmpty ? regimenFiscal : '601',
      );
      await _perfilSvc.guardarPerfil(p);
      _perfil = p; _setIdle(); return true;
    } catch (e) { _setError('Error onboarding: $e'); return false; }
  }


  Future<Cliente?> crearCliente(String uid, Cliente c) async {
    _setLoading();
    try { final n = await _clienteSvc.crearCliente(uid, c); _setIdle(); return n; }
    catch (e) { _setError('$e'); return null; }
  }

  Future<bool> actualizarCliente(String uid, Cliente c) async {
    _setLoading();
    try { await _clienteSvc.actualizarCliente(uid, c); _setIdle(); return true; }
    catch (e) { _setError('$e'); return false; }
  }

  Future<bool> eliminarCliente(String uid, String id) async {
    _setLoading();
    try { await _clienteSvc.eliminarCliente(uid, id); _setIdle(); return true; }
    catch (e) { _setError('$e'); return false; }
  }


  Future<Cotizacion?> crearCotizacion(String uid, Cotizacion c) async {
    _setLoading();
    try {
      final tasa = _perfil?.impuesto ?? 16.0;
      final nueva = await _cotizSvc.crear(uid, c.copyWith(uid: uid, tasaIva: tasa));
      _setIdle(); return nueva;
    } catch (e) { _setError('$e'); return null; }
  }

  Future<bool> actualizarCotizacion(String uid, Cotizacion c) async {
    _setLoading();
    try { await _cotizSvc.actualizar(uid, c); _setIdle(); return true; }
    catch (e) { _setError('$e'); return false; }
  }

  Future<bool> eliminarCotizacion(String uid, String id) async {
    _setLoading();
    try { await _cotizSvc.eliminar(uid, id); _setIdle(); return true; }
    catch (e) { _setError('$e'); return false; }
  }


  Future<Factura?> crearFactura(String uid, Factura f) async {
    _setLoading();
    try {
      final nueva = await _facturaSvc.crear(uid, f);
      await _cotizSvc.marcarFacturada(uid, f.cotizacionId, nueva.id);
      _setIdle(); return nueva;
    } catch (e) { _setError('$e'); return null; }
  }

  Future<bool> actualizarFactura(String uid, Factura f) async {
    _setLoading();
    try { await _facturaSvc.actualizar(uid, f); _setIdle(); return true; }
    catch (e) { _setError('$e'); return false; }
  }

  Future<bool> eliminarFactura(String uid, String id) async {
    _setLoading();
    try { await _facturaSvc.eliminar(uid, id); _setIdle(); return true; }
    catch (e) { _setError('$e'); return false; }
  }


  Future<TimbradoResult> timbrarFactura(String uid, Factura f) async {
    final errores = f.validarParaCfdi();
    if (errores.isNotEmpty) {
      return TimbradoResult(
        exito: false,
        error: errores.join('\n'),
      );
    }

    _setLoading();
    try {
      final result = await FacturapiService.instance.crearFactura(f);

      if (result.exito && result.uuid != null && result.facturapiId != null) {
        await _facturaSvc.guardarTimbrado(
          uid, f.id,
          uuid: result.uuid!,
          facturapiId: result.facturapiId!,
          pdfUrl: result.pdfUrl,
        );
      }

      _setIdle();
      return result;
    } catch (e) {
      _setError('Error al timbrar: $e');
      return TimbradoResult(exito: false, error: 'Error al timbrar: $e');
    }
  }


  void _setLoading() {
    _status = AppStatus.loading; _errorMessage = null; notifyListeners();
  }
  void _setIdle() {
    _status = AppStatus.idle; _errorMessage = null; notifyListeners();
  }
  void _setError(String m) {
    _status = AppStatus.error; _errorMessage = m; notifyListeners();
  }
  void clearError() {
    _errorMessage = null; _status = AppStatus.idle; notifyListeners();
  }
  String formatearTotal(double t) =>
      '\$${NumberFormat('#,##0.00').format(t)}';
}
