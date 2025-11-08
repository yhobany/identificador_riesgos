// lib/utils/pdf_generator.dart
import 'dart:typed_data';
import 'package:flutter/material.dart'; // Necesario para DefaultAssetBundle
import 'package:pdf/pdf.dart' as pdf_format;
import 'package:pdf/widgets.dart' as pw;
import 'package:identificador_riesgos/models/permiso_data.dart';

/// Clase de utilidad para centralizar la generación del PDF.
/// Esto evita duplicar código en VerReporte.dart y FirmasPermiso.dart.
class PdfGenerator {
  /// Genera el documento PDF completo.
  ///
  /// [data] El objeto PermisoData con toda la información.
  /// [includeSignatures] Si es 'true', añade la sección de firmas.
  ///                     Si es 'false', la omite (para la vista previa).
  static Future<Uint8List> generatePermisoPdf(
      PermisoData data, bool includeSignatures) async {
    final pdf = pw.Document();

    // Cargar fuentes (usamos un truco sin 'context' pasando el bundle)
    final fontRegular = await pw.Font.ttf(
        await DefaultAssetBundle.of(navigationKey.currentContext!)
            .load('assets/fonts/Roboto-Regular.ttf'));
    final fontBold = await pw.Font.ttf(
        await DefaultAssetBundle.of(navigationKey.currentContext!)
            .load('assets/fonts/Roboto-Bold.ttf'));
    final fontMedium = await pw.Font.ttf(
        await DefaultAssetBundle.of(navigationKey.currentContext!)
            .load('assets/fonts/Roboto-Medium.ttf'));

    // Formatear fechas y horas
    String formatDateTime(DateTime? date, TimeOfDay? time) {
      if (date == null || time == null) return 'No especificado';
      final dt =
      DateTime(date.year, date.month, date.day, time.hour, time.minute);
      return '${dt.day}/${dt.month}/${dt.year} – ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    final horaInicioStr = formatDateTime(data.fechaInicio, data.horaInicio);
    final horaFinStr = formatDateTime(data.fechaFin, data.horaFin);

    // Imágenes de firmas
    final firmaDiligenciadorImg = data.firmaDiligenciador != null
        ? pw.MemoryImage(data.firmaDiligenciador!)
        : null;
    final firmaInterventorImg = data.firmaInterventor != null
        ? pw.MemoryImage(data.firmaInterventor!)
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
          _buildHeader(fontBold, fontRegular),

          // === SECCIÓN 1: DATOS GENERALES ===
          _buildSectionTitle('Datos Generales', fontMedium),
          _buildDatosGenerales(
              data, fontBold, fontRegular, horaInicioStr, horaFinStr),
          pw.SizedBox(height: 16),

          // === SECCIÓN 2: PERMISOS ESPECIALES ===
          _buildSectionTitle('Permisos Especiales', fontMedium),
          _buildPermisosEspeciales(
              data, fontBold, fontRegular, colorYes, colorNo),
          pw.SizedBox(height: 16),

          // === SECCIÓN 3: PELIGROS Y PASO A PASO (LÓGICA CONDICIONAL) ===

          // PARTE 1: PELIGROS (SIEMPRE SE MUESTRA SI HAY DATOS)
          if (data.aplicaCategoria.entries.any((e) => e.value == 'Sí')) ...[
            _buildSectionTitle('Peligros, Riesgos y Medidas', fontMedium),
            _buildPeligros(data, fontBold, fontRegular),
            pw.SizedBox(height: 16),
          ],

          // PARTE 2: PASO A PASO (SOLO SI NO HAY AST Y HAY DATOS)
          if (!data.existeAST && data.pasos.isNotEmpty) ...[
            _buildSectionTitle('Paso a Paso de la Tarea', fontMedium),
            _buildPasoAPaso(data, fontBold, fontRegular),
            pw.SizedBox(height: 16),
          ],

          // === SECCIÓN 4: HERRAMIENTAS DE SEGURIDAD ===
          _buildSectionTitle('Herramientas de Seguridad', fontMedium),
          _buildHerramientas(data, fontBold, fontRegular),
          pw.SizedBox(height: 20),

          // === SECCIÓN 5: FIRMAS (CONDICIONAL) ===
          if (includeSignatures) ...[
            _buildSectionTitle('Firmas de Validación', fontMedium),
            _buildFirmas(data, fontBold, fontRegular, firmaDiligenciadorImg,
                firmaInterventorImg),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  // --- Widgets Internos (extraídos para limpieza) ---

  static pw.Widget _buildHeader(pw.Font fontBold, pw.Font fontRegular) {
    return pw.Column(
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
    );
  }

  static pw.Widget _buildSectionTitle(String title, pw.Font fontMedium) {
    return pw.Column(children: [
      pw.Text(title, style: pw.TextStyle(font: fontMedium, fontSize: 14)),
      pw.SizedBox(height: 8),
    ]);
  }

  static pw.Widget _buildDatosGenerales(PermisoData data, pw.Font fontBold,
      pw.Font fontRegular, String horaInicioStr, String horaFinStr) {
    return pw.Table(
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
          ['Descripción', data.descripcion],
          ['Código AST', data.codigoAST],
          ['Orden de Trabajo', data.ordenTrabajo],
          ['Ubicación', data.ubicacion],
          ['Fecha Inicio', horaInicioStr],
          ['Fecha Fin', horaFinStr],
        ].map((row) => pw.TableRow(
          children: row
              .map((cell) => pw.Padding(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text(cell,
                style:
                pw.TextStyle(font: fontRegular, fontSize: 9)),
          ))
              .toList(),
        )),
      ],
    );
  }

  static pw.Widget _buildPermisosEspeciales(
      PermisoData data,
      pw.Font fontBold,
      pw.Font fontRegular,
      pdf_format.PdfColor colorYes,
      pdf_format.PdfColor colorNo) {
    return pw.Table(
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
        ...data.permisosEspeciales.entries.map((e) {
          final aplica = e.value ? 'Sí' : 'No';
          final color = e.value ? colorYes : colorNo;
          return pw.TableRow(
            children: [
              pw.Padding(
                  padding: pw.EdgeInsets.all(6),
                  child: pw.Text(e.key,
                      style: pw.TextStyle(font: fontRegular, fontSize: 9))),
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
    );
  }

  static pw.Widget _buildPeligros(
      PermisoData data, pw.Font fontBold, pw.Font fontRegular) {
    return pw.Table(
      border: pw.TableBorder.all(
          width: 0.3, color: pdf_format.PdfColors.grey400),
      columnWidths: {
        0: pw.FixedColumnWidth(80),
        1: pw.FlexColumnWidth(1.6),
        2: pw.FlexColumnWidth(1.6),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: pdf_format.PdfColors.grey300),
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
        ...data.aplicaCategoria.entries.where((e) => e.value == 'Sí').map((entry) {
          final cat = entry.key;
          final riesgos = (data.riesgosSeleccionados[cat] ?? []).join(', ');
          final medidas = (data.medidasSeleccionadas[cat] ?? []).join(', ');
          return pw.TableRow(
            children: [
              pw.Padding(
                  padding: pw.EdgeInsets.all(4),
                  child: pw.Text(cat,
                      style: pw.TextStyle(font: fontRegular, fontSize: 8))),
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
    );
  }

  static pw.Widget _buildPasoAPaso(
      PermisoData data, pw.Font fontBold, pw.Font fontRegular) {
    return pw.Table(
      border: pw.TableBorder.all(
          width: 0.3, color: pdf_format.PdfColors.grey400),
      columnWidths: {
        0: pw.FixedColumnWidth(25), // N.º
        1: pw.FlexColumnWidth(1.5), // Tarea
        2: pw.FlexColumnWidth(1.5), // Peligros
        3: pw.FlexColumnWidth(1.5), // Medidas
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: pdf_format.PdfColors.grey300),
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
        ...data.pasos.map((paso) {
          final numero = paso['numero']?.toString() ?? '';
          final pasoTarea = paso['pasoTarea']?.toString() ?? '';
          final peligros = (paso['peligros'] as List?)?.join(', ') ?? '';
          final medidas = (paso['medidas'] as List?)?.join(', ') ?? '';
          return pw.TableRow(
            children: [
              pw.Padding(
                  padding: pw.EdgeInsets.all(4),
                  child: pw.Text(numero,
                      style: pw.TextStyle(font: fontRegular, fontSize: 8))),
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
    );
  }

  static pw.Widget _buildHerramientas(
      PermisoData data, pw.Font fontBold, pw.Font fontRegular) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Aplico las 4P',
                  style: pw.TextStyle(font: fontBold, fontSize: 11)),
              pw.SizedBox(height: 4),
              ...data.respuestas4P.entries.map((e) {
                final respuesta = (e.value ?? '').trim();
                final icon = respuesta == 'Sí' ? 'Sí' : 'No';
                return pw.Text('${e.key} $icon',
                    style: pw.TextStyle(font: fontRegular, fontSize: 8));
              }),
            ],
          ),
        ),
        pw.SizedBox(width: 16),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Analizo mi entorno',
                  style: pw.TextStyle(font: fontBold, fontSize: 11)),
              pw.SizedBox(height: 4),
              ...data.respuestasEntorno.entries.map((e) {
                final respuesta = (e.value ?? '').trim();
                final icon = respuesta == 'Sí' ? 'Sí' : 'No';
                return pw.Text('${e.key} $icon',
                    style: pw.TextStyle(font: fontRegular, fontSize: 8));
              }),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFirmas(
      PermisoData data,
      pw.Font fontBold,
      pw.Font fontRegular,
      pw.MemoryImage? firmaDiligenciadorImg,
      pw.MemoryImage? firmaInterventorImg) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Diligenciador:',
                  style: pw.TextStyle(font: fontBold, fontSize: 10)),
              pw.Text(data.nombreDiligenciador ?? '',
                  style: pw.TextStyle(font: fontRegular, fontSize: 9)),
              pw.SizedBox(height: 8),
              if (firmaDiligenciadorImg != null)
                pw.Container(
                  width: 150,
                  height: 60,
                  child:
                  pw.Image(firmaDiligenciadorImg, fit: pw.BoxFit.contain),
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
              pw.Text(data.nombreInterventor ?? '',
                  style: pw.TextStyle(font: fontRegular, fontSize: 9)),
              pw.SizedBox(height: 8),
              if (firmaInterventorImg != null)
                pw.Container(
                  width: 150,
                  height: 60,
                  child:
                  pw.Image(firmaInterventorImg, fit: pw.BoxFit.contain),
                ),
              pw.Divider(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Clave global para acceder al BuildContext de la app.
/// Necesaria para que el generador de PDF (que no es un Widget)
/// pueda acceder a los assets (fuentes).
final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();