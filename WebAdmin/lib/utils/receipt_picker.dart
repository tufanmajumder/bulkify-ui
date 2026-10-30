import 'receipt_picker_stub.dart'
    if (dart.library.html) 'receipt_picker_web.dart'
    as impl;
import 'receipt_picker_stub.dart';

export 'receipt_picker_stub.dart' show PickedReceiptImage;

Future<PickedReceiptImage?> pickReceiptImage() {
  return impl.pickReceiptImageImpl();
}

