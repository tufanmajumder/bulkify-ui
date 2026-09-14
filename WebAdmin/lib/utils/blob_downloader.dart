import 'blob_downloader_stub.dart'
    if (dart.library.html) 'blob_downloader_web.dart'
    as impl;

void downloadBlob(
  List<int> bytes,
  String fileName, {
  String mimeType = 'application/pdf',
}) {
  impl.downloadBlob(bytes, fileName, mimeType: mimeType);
}
