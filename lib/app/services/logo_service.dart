import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LogoService {
  LogoService._();
  static final LogoService instance = LogoService._();

  static const _prefKey = 'empresa_logo_path';

  Future<String?> obtenerRutaLogo() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_prefKey);
    if (path == null) return null;
    if (!kIsWeb && !File(path).existsSync()) {
      await prefs.remove(_prefKey);
      return null;
    }
    return path;
  }

  Future<String?> seleccionarYGuardarLogo() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked == null) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final logoDir = Directory('${appDir.path}/logos');
      if (!logoDir.existsSync()) logoDir.createSync(recursive: true);

      final ext = picked.path.split('.').last;
      final destPath = '${logoDir.path}/empresa_logo.$ext';

      final srcFile = File(picked.path);
      await srcFile.copy(destPath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, destPath);

      return destPath;
    } catch (e) {
      debugPrint('LogoService.seleccionarYGuardarLogo error: $e');
      return null;
    }
  }

  Future<void> eliminarLogo() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_prefKey);
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
      await prefs.remove(_prefKey);
    }
  }
}
