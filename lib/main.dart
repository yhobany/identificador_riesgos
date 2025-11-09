import 'package:flutter/material.dart';
import 'screens/TareaForm.dart';
import 'screens/PeligrosForm.dart';
import 'screens/HerramientasSeguridad.dart';
import 'screens/PasoAPaso.dart';
import 'screens/FirmasPermiso.dart';

// --- NUEVAS IMPORTACIONES ---
import 'screens/VerReporte.dart'; // La nueva pantalla
import 'utils/pdf_generator.dart'; // Para la GlobalKey
// --- FIN DE NUEVAS IMPORTACIONES ---

void main() {
  runApp(PermisosApp());
}

class PermisosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // --- CLAVE AÑADIDA ---
      navigatorKey: navigationKey, // Conecta la clave global
      // --- FIN DE CLAVE ---
      title: 'Permisos de Seguridad',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => TareaForm(),
        '/peligros': (context) => PeligrosForm(),
        '/herramientas': (context) => HerramientasSeguridad(),
        '/pasoapaso': (context) => PasoAPasoScreen(),
        '/firmas': (context) => FirmasPermiso(),

        // --- NUEVA RUTA AÑADIDA ---
        '/ver_reporte': (context) => VerReporteScreen(),
        // --- FIN DE NUEVA RUTA ---
      },
    );
  }
}