// lib/utils/dart_html_real.dart
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';

void downloadPdf(Uint8List bytes, String fileName) {
  final base64Bytes = base64Encode(bytes);
  final anchor = html.AnchorElement(
      href: 'data:application/octet-stream;base64,$base64Bytes')
    ..setAttribute('download', fileName)
    ..click();
  html.document.body?.children.remove(anchor);
}