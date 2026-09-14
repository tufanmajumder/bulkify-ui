// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;

void downloadBlob(
  List<int> bytes,
  String fileName, {
  String mimeType = 'application/pdf',
}) {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
  Timer(const Duration(seconds: 2), () {
    html.Url.revokeObjectUrl(url);
  });
}

