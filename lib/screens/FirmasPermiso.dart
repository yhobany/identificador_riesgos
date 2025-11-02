import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart' as pdf_format;
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

// Importaciones corregidas para Android Studio
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

  Future<void> _generateAndSharePdf() async {
    final pdf = pw.Document();

    // Cargar fuentes
    final fontRegular = await pw.Font.ttf(await DefaultAssetBundle.of(context)
        .load('assets/fonts/Roboto-Regular.ttf'));
    final fontBold = await pw.Font.ttf(await DefaultAssetBundle.of(context)
        .load('assets/fonts/Roboto-Bold.ttf'));
    final fontMedium = await pw.Font.ttf(await DefaultAssetBundle.of(context)
        .load('assets/fonts/Roboto-Medium.ttf'));

    // Formatear fechas y horas
    String formatDateTime(DateTime? date, TimeOfDay? time) {
      if (date == null || time == null) return 'No especificado';
      final dt =
      DateTime(date.year, date.month, date.day, time.hour, time.minute);
      return '${dt.day}/${dt.month}/${dt.year} – ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    final horaInicioStr = formatDateTime(_data.fechaInicio, _data.horaInicio);
    final horaFinStr = formatDateTime(_data.fechaFin, _data.horaFin);

    // Imágenes de firmas
    final firmaDiligenciadorImg = _data.firmaDiligenciador != null
        ? pw.MemoryImage(_data.firmaDiligenciador!)
        : null;
    final firmaInterventorImg = _data.firmaInterventor != null
        ? pw.MemoryImage(_data.firmaInterventor!)
        : null;

    // Colores
    final colorYes = pdf_format.PdfColor.fromInt(0xFF2E7D32);
    final colorNo = pdf_format.PdfColor.fromInt(0xFFC62828);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdf_format.PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          // === ENCABEZADO ===
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Permiso de Seguridad',
                      style: pw.TextStyle(font: fontBold, fontSize: 20)),
                  pw.Text(
                    'Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: pw.TextStyle(font: fontRegular, fontSize: 10),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 16),
            ],
          ),

          // === SECCIÓN 1: DATOS GENERALES ===
          pw.Text('Datos Generales',
              style: pw.TextStyle(font: fontMedium, fontSize: 14)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(
                width: 0.3, color: pdf_format.PdfColors.grey400),
            columnWidths: {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(3),
            },
            children: [
              pw.TableRow(children: [
                pw.Padding(
                    padding: pw.EdgeInsets.all(6),
                    child: pw.Text('Campo',
                        style: pw.TextStyle(font: fontBold, fontSize: 10))),
                pw.Padding(
                    padding: pw.EdgeInsets.all(6),
                    child: pw.Text('Valor',
                        style: pw.TextStyle(font: fontBold, fontSize: 10))),
              ]),
              ...[
                ['Descripción', _data.descripcion],
                ['Código AST', _data.codigoAST],
                ['Orden de Trabajo', _data.ordenTrabajo],
                ['Ubicación', _data.ubicacion],
                ['Fecha Inicio', horaInicioStr],
                ['Fecha Fin', horaFinStr],
              ].map((row) => pw.TableRow(
                children: row
                    .map((cell) => pw.Padding(
                  padding: pw.EdgeInsets.all(6),
                  child: pw.Text(cell,
                      style: pw.TextStyle(
                          font: fontRegular, fontSize: 9)),
                ))
                    .toList(),
              )),
            ],
          ),
          pw.SizedBox(height: 16),

          // === SECCIÓN 2: PERMISOS ESPECIALES ===
          pw.Text('Permisos Especiales',
              style: pw.TextStyle(font: fontMedium, fontSize: 14)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(width: 0.3),
            children: [
              pw.TableRow(children: [
                pw.Padding(
                    padding: pw.EdgeInsets.all(6),
                    child: pw.Text('Tipo',
                        style: pw.TextStyle(font: fontBold, fontSize: 10))),
                pw.Padding(
                    padding: pw.EdgeInsets.all(6),
                    child: pw.Text('Aplica',
                        style: pw.TextStyle(font: fontBold, fontSize: 10))),
              ]),
              ..._data.permisosEspeciales.entries.map((e) {
                final aplica = e.value ? 'Sí' : 'No';
                final color = e.value ? colorYes : colorNo;
                return pw.TableRow(
                  children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(e.key,
                            style:
                            pw.TextStyle(font: fontRegular, fontSize: 9))),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(6),
                      child: pw.Text(aplica,
                          style: pw.TextStyle(
                              font: fontBold, fontSize: 9, color: color)),
                    ),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 16),

          // === INICIO DE SECCIÓN 3 (LÓGICA CORREGIDA) ===

          // PARTE 1: PELIGROS (SIEMPRE SE MUESTRA SI HAY DATOS)
          if (_data.aplicaCategoria.entries
              .any((e) => e.value == 'Sí')) ...[
            pw.Text('Peligros, Riesgos y Medidas',
                style: pw.TextStyle(font: fontMedium, fontSize: 14)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(
                  width: 0.3, color: pdf_format.PdfColors.grey400),
              columnWidths: {
                0: pw.FixedColumnWidth(80),
                1: pw.FlexColumnWidth(1.6),
                2: pw.FlexColumnWidth(1.6),
              },
              children: [
                pw.TableRow(
                  decoration:
                  pw.BoxDecoration(color: pdf_format.PdfColors.grey300),
                  children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Categoría',
                            style: pw.TextStyle(font: fontBold, fontSize: 9))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Riesgos',
                            style: pw.TextStyle(font: fontBold, fontSize: 9))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Medidas',
                            style: pw.TextStyle(font: fontBold, fontSize: 9))),
                  ],
                ),
                ..._data.aplicaCategoria.entries
                    .where((e) => e.value == 'Sí')
                    .map((entry) {
                  final cat = entry.key;
                  final riesgos =
                  (_data.riesgosSeleccionados[cat] ?? []).join(', ');
                  final medidas =
                  (_data.medidasSeleccionadas[cat] ?? []).join(', ');
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(cat,
                              style: pw.TextStyle(
                                  font: fontRegular, fontSize: 8))),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Paragraph(
                            text: riesgos,
                            style: pw.TextStyle(font: fontRegular, fontSize: 8),
                            margin: pw.EdgeInsets.zero),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Paragraph(
                            text: medidas,
                            style: pw.TextStyle(font: fontRegular, fontSize: 8),
                            margin: pw.EdgeInsets.zero),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 16),
          ],

          // PARTE 2: PASO A PASO (SOLO SI NO HAY AST Y HAY DATOS)
          if (!_data.existeAST && _data.pasos.isNotEmpty) ...[
            pw.Text('Paso a Paso de la Tarea',
                style: pw.TextStyle(font: fontMedium, fontSize: 14)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(
                  width: 0.3, color: pdf_format.PdfColors.grey400),
              columnWidths: {
                0: pw.FixedColumnWidth(25), // Columna para 'N.º'
                1: pw.FlexColumnWidth(1.5), // Tarea
                2: pw.FlexColumnWidth(1.5), // Peligros
                3: pw.FlexColumnWidth(1.5), // Medidas
              },
              children: [
                // Encabezados de la nueva tabla
                pw.TableRow(
                  decoration:
                  pw.BoxDecoration(color: pdf_format.PdfColors.grey300),
                  children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('N.º',
                            style: pw.TextStyle(font: fontBold, fontSize: 9))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Paso de la Tarea',
                            style: pw.TextStyle(font: fontBold, fontSize: 9))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Peligros',
                            style: pw.TextStyle(font: fontBold, fontSize: 9))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Medidas',
                            style: pw.TextStyle(font: fontBold, fontSize: 9))),
                  ],
                ),
                // Contenido de la nueva tabla
                ..._data.pasos.map((paso) {
                  final numero = paso['numero']?.toString() ?? '';
                  final pasoTarea = paso['pasoTarea']?.toString() ?? '';
                  final peligros =
                      (paso['peligros'] as List?)?.join(', ') ?? '';
                  final medidas = (paso['medidas'] as List?)?.join(', ') ?? '';

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(numero,
                              style: pw.TextStyle(
                                  font: fontRegular, fontSize: 8))),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Paragraph(
                            text: pasoTarea,
                            style: pw.TextStyle(font: fontRegular, fontSize: 8),
                            margin: pw.EdgeInsets.zero),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Paragraph(
                            text: peligros,
                            style: pw.TextStyle(font: fontRegular, fontSize: 8),
                            margin: pw.EdgeInsets.zero),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Paragraph(
                            text: medidas,
                            style: pw.TextStyle(font: fontRegular, fontSize: 8),
                            margin: pw.EdgeInsets.zero),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 16),
          ],

          // === FIN DE SECCIÓN 3 ===

          // === SECCIÓN 4: HERRAMIENTAS DE SEGURIDAD ===
          pw.Text('Herramientas de Seguridad',
              style: pw.TextStyle(font: fontMedium, fontSize: 14)),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Aplico las 4P
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Aplico las 4P',
                        style: pw.TextStyle(font: fontBold, fontSize: 11)),
                    pw.SizedBox(height: 4),
                    ..._data.respuestas4P.entries.map((e) {
                      final respuesta = (e.value ?? '').trim();
                      final icon = respuesta == 'Sí' ? 'Sí' : 'No';
                      return pw.Text('${e.key} $icon',
                          style: pw.TextStyle(font: fontRegular, fontSize: 8));
                    }),
                  ],
                ),
              ),
              pw.SizedBox(width: 16),
              // Analizo mi entorno
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Analizo mi entorno',
                        style: pw.TextStyle(font: fontBold, fontSize: 11)),
                    pw.SizedBox(height: 4),
                    ..._data.respuestasEntorno.entries.map((e) {
                      final respuesta = (e.value ?? '').trim();
                      final icon = respuesta == 'Sí' ? 'Sí' : 'No';
                      return pw.Text('${e.key} $icon',
                          style: pw.TextStyle(font: fontRegular, fontSize: 8));
                    }),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // === SECCIÓN 5: FIRMAS ===
          pw.Text('Firmas de Validación',
              style: pw.TextStyle(font: fontMedium, fontSize: 14)),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Diligenciador:',
                        style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    pw.Text(_data.nombreDiligenciador ?? '',
                        style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                    pw.SizedBox(height: 8),
                    if (firmaDiligenciadorImg != null)
                      pw.Container(
                        width: 150,
                        height: 60,
                        child: pw.Image(firmaDiligenciadorImg,
                            fit: pw.BoxFit.contain),
                      ),
                    pw.Divider(),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Interventor / Autorizador:',
                        style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    pw.Text(_data.nombreInterventor ?? '',
                        style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                    pw.SizedBox(height: 8),
                    if (firmaInterventorImg != null)
                      pw.Container(
                        width: 150,
                        height: 60,
                        child: pw.Image(firmaInterventorImg,
                            fit: pw.BoxFit.contain),
                      ),
                    pw.Divider(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // === GENERAR Y COMPARTIR ===
    final pdfBytes = await pdf.save();
    final fileName =
        'Permiso_Seguridad_${DateTime.now().millisecondsSinceEpoch}.pdf';

    // Compartir (Esto SÍ funciona en Android/iOS)
    await Share.shareXFiles(
      [XFile.fromData(pdfBytes, name: fileName, mimeType: 'application/pdf')],
      text: 'Permiso de Seguridad: ${_data.descripcion}',
    );
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
        await _generateAndSharePdf();
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
        padding: const EdgeInsets.all(16.0),
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
              ElevatedButton(
                  onPressed: _guardarYFinalizar,
                  child: Text('Guardar y Exportar PDF')),
            ],
          ),
        ),
      ),
    );
  }
}