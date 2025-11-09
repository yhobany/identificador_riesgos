import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart'; // Importa FileSaver

// kIsWeb nos dice si estamos en un navegador web
import 'package:flutter/foundation.dart' show kIsWeb;
// Nuestro wrapper de HTML
import '../utils/dart_html_wrapper.dart' as html_wrapper;

// Nuestro generador de PDF
import 'package:identificador_riesgos/utils/pdf_generator.dart';
import 'package:identificador_riesgos/models/permiso_data.dart';
import 'package:identificador_riesgos/utils/storage_manager.dart';

class FirmasPermiso extends StatefulWidget {
  @override
  _FirmasPermisoState createState() => _FirmasPermisoState();
}

class _FirmasPermisoState extends State<FirmasPermiso> {
  final _formKey = GlobalKey<FormState>();
  late PermisoData _data;
  bool _initialized = false;

  final SignatureController _controllerDiligenciador = SignatureController(
    penStrokeWidth: 3.0,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final SignatureController _controllerInterventor = SignatureController(
    penStrokeWidth: 3.0,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  String nombreDiligenciador = '';
  String nombreInterventor = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments as PermisoData;
      _data = args;
      nombreDiligenciador = _data.nombreDiligenciador ?? '';
      nombreInterventor = _data.nombreInterventor ?? '';
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _controllerDiligenciador.dispose();
    _controllerInterventor.dispose();
    super.dispose();
  }

  void _limpiarFirmaDiligenciador() => _controllerDiligenciador.clear();
  void _limpiarFirmaInterventor() => _controllerInterventor.clear();

  String _sanitizeFileName(String input) {
    String sanitized = input.replaceAll(' ', '_');
    sanitized = sanitized.replaceAll(RegExp(r'[^\w_]'), '');
    if (sanitized.length > 50) {
      sanitized = sanitized.substring(0, 50);
    }
    return sanitized;
  }

  /// Genera el PDF final (con firmas) y lo comparte o descarga.
  Future<void> _generarYCompartirPdfFinal(PermisoData data) async {
    // 1. Llama al generador centralizado CON firmas
    final Uint8List pdfBytes = await PdfGenerator.generatePermisoPdf(data, true);

    // 2. Formatear la fecha
    final now = DateTime.now();
    final String formattedDate =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    // 3. Limpiar la descripción
    final String sanitizedDesc = _sanitizeFileName(
        data.descripcion.isNotEmpty ? data.descripcion : 'Permiso_Seguridad');

    // 4. Combinar para el nombre de archivo final
    final fileName = '${sanitizedDesc}_${formattedDate}.pdf';

    // 5. Lógica condicional para Web vs Móvil
    if (kIsWeb) {
      // --- LÓGICA WEB (Descarga directa) ---
      html_wrapper.downloadPdf(pdfBytes, fileName);
    } else {
      // --- LÓGICA MÓVIL (Guardar con FileSaver) ---
      try {
        await FileSaver.instance.saveAs(
          name: fileName,
          bytes: pdfBytes,
          fileExtension: 'pdf', // Parámetro corregido
          mimeType: MimeType.pdf,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar el archivo: $e')));
      }
    }
  }

  void _guardarYFinalizar() async {
    if (!_formKey.currentState!.validate() ||
        _controllerDiligenciador.isEmpty ||
        _controllerInterventor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ambas firmas son requeridas')),
      );
      return;
    }

    final Uint8List? firmaDiligenciadorBytes =
    await _controllerDiligenciador.toPngBytes();
    final Uint8List? firmaInterventorBytes =
    await _controllerInterventor.toPngBytes();

    if (firmaDiligenciadorBytes != null && firmaInterventorBytes != null) {
      _data.firmaDiligenciador = firmaDiligenciadorBytes;
      _data.nombreDiligenciador = nombreDiligenciador;
      _data.firmaInterventor = firmaInterventorBytes;
      _data.nombreInterventor = nombreInterventor;

      try {
        await StorageManager.savePermiso(_data);
        await _generarYCompartirPdfFinal(_data);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permiso guardado y PDF generado')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false,
            arguments: PermisoData());
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al exportar firmas')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firmas de Validación')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Firma del Diligenciador de los Formularios',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              TextFormField(
                initialValue: nombreDiligenciador,
                decoration:
                InputDecoration(labelText: 'Nombre del Diligenciador'),
                validator: (v) => v == null || v.isEmpty
                    ? 'Requerido'
                    : v.length < 3
                    ? 'Mínimo 3 caracteres'
                    : null,
                onChanged: (v) => nombreDiligenciador = v,
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4)),
                child: Signature(
                    controller: _controllerDiligenciador,
                    height: 150,
                    backgroundColor: Colors.white),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                  onPressed: _limpiarFirmaDiligenciador,
                  child: Text('Limpiar Firma')),
              SizedBox(height: 32),
              Text(
                  'Firma del Ingeniero Interventor / Validador SW (Autorizador)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              TextFormField(
                initialValue: nombreInterventor,
                decoration:
                InputDecoration(labelText: 'Nombre del Interventor'),
                validator: (v) => v == null || v.isEmpty
                    ? 'Requerido'
                    : v.length < 3
                    ? 'Mínimo 3 caracteres'
                    : null,
                onChanged: (v) => nombreInterventor = v,
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4)),
                child: Signature(
                    controller: _controllerInterventor,
                    height: 150,
                    backgroundColor: Colors.white),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                  onPressed: _limpiarFirmaInterventor,
                  child: Text('Limpiar Firma')),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _guardarYFinalizar,
              child: Text('Guardar y Guardar PDF'),
            ),
          ),
        ),
      ],
    );
  }
}