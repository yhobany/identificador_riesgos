// lib/screens/VerReporte.dart
import 'package:flutter/material.dart';
import 'package:printing/printing.dart'; // Importa la librería de vista previa
import 'package:pdf/pdf.dart' as pdf_format;

// Importaciones de nuestro proyecto
import 'package:identificador_riesgos/models/permiso_data.dart';
import 'package:identificador_riesgos/utils/pdf_generator.dart';

class VerReporteScreen extends StatefulWidget {
  @override
  _VerReporteScreenState createState() => _VerReporteScreenState();
}

class _VerReporteScreenState extends State<VerReporteScreen> {
  late PermisoData _data;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments as PermisoData;
      _data = args;
      _initialized = true;
    }
  }

  void _continuarAFirmas() {
    // Navega a la pantalla de firmas, pasando los mismos datos
    Navigator.pushNamed(context, '/firmas', arguments: _data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vista Previa del Reporte'),

        // --- ACCIÓN ELIMINADA DE AQUÍ ---
        // actions: [ ... ],
        // --- FIN DE LA ELIMINACIÓN ---
      ),
      body: PdfPreview(
        build: (pdf_format.PdfPageFormat format) {
          // Llama a nuestro generador centralizado con 'includeSignatures: false'
          return PdfGenerator.generatePermisoPdf(_data, false);
        },
        canChangePageFormat: false,
        canDebug: false,
        allowPrinting: false,
        allowSharing: false,

        // --- BOTÓN DE ACCIÓN MOVIDO DE LA BARRA DE APP ---
        // actions: [ ... ],
      ),

      // --- ¡BOTÓN AÑADIDO AQUÍ! ---
      // Añadimos un Botón de Acción Flotante para hacerlo más notorio
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _continuarAFirmas,
        icon: Icon(Icons.edit_document), // Icono para "firmar"
        label: Text('Confirmar y Firmar'),
        backgroundColor: Colors.green.shade700, // Color notorio
      ),
      // --- FIN DE LA ADICIÓN ---
    );
  }
}