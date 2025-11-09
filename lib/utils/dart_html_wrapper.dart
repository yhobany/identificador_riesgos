// lib/utils/dart_html_wrapper.dart
import 'dart_html_stub.dart'
if (dart.library.html) 'dart_html_real.dart' as html_wrapper;

import 'dart:typed_data';

void downloadPdf(Uint8List bytes, String fileName) {
  html_wrapper.downloadPdf(bytes, fileName);
}