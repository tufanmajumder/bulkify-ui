// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'receipt_picker_stub.dart';

Future<PickedReceiptImage?> pickReceiptImageImpl() async {
  final completer = Completer<PickedReceiptImage?>();
  final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
  uploadInput.click();

  uploadInput.onChange.listen((event) {
    final files = uploadInput.files;
    if (files == null || files.isEmpty) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      return;
    }

    final file = files.first;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);

    reader.onLoadEnd.listen((_) {
      if (!completer.isCompleted) {
        final result = reader.result;
        if (result is Uint8List) {
          completer.complete(
            PickedReceiptImage(name: file.name, bytes: result),
          );
        } else if (result is ByteBuffer) {
          completer.complete(
            PickedReceiptImage(name: file.name, bytes: result.asUint8List()),
          );
        } else if (result is List<int>) {
          completer.complete(
            PickedReceiptImage(
              name: file.name,
              bytes: Uint8List.fromList(result),
            ),
          );
        } else {
          completer.complete(null);
        }
      }
    });

    reader.onError.listen((_) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });
  });

  return completer.future;
}

