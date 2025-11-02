import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:identificador_riesgos/models/permiso_data.dart';

class StorageManager {
  static const String _permisosKey = 'permisos_list';

  // Guardar un permiso
  static Future<void> savePermiso(PermisoData permiso) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> permisos = prefs.getStringList(_permisosKey) ?? [];
    permisos.add(jsonEncode(permiso.toJson()));
    await prefs.setStringList(_permisosKey, permisos);
  }
}
