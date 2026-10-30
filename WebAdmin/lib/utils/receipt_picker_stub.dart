import 'dart:typed_data';

class PickedReceiptImage {
  final String name;
  final Uint8List bytes;

  const PickedReceiptImage({
    required this.name,
    required this.bytes,
  });
}

Future<PickedReceiptImage?> pickReceiptImageImpl() async {
  return null;
}

