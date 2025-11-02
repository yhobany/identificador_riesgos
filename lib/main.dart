import 'package:flutter/material.dart';
import 'screens/TareaForm.dart'; // Importa TareaForm desde su archivo correcto
import 'screens/PeligrosForm.dart';
import 'screens/HerramientasSeguridad.dart';
import 'screens/PasoAPaso.dart'; // Importa PasoAPasoScreen desde su archivo correcto
import 'screens/FirmasPermiso.dart'; // Nuevo import

void main() {
  runApp(PermisosApp());
}

class PermisosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Permisos de Seguridad',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => TareaForm(), // TareaForm como widget
        '/peligros': (context) => PeligrosForm(),
        '/herramientas': (context) => HerramientasSeguridad(),
        '/pasoapaso': (context) =>
            PasoAPasoScreen(), // PasoAPasoScreen como widget
        '/firmas': (context) => FirmasPermiso(), // Nueva ruta
      },
    );
  }
}
