import 'receipt_image_picker_stub.dart'
    if (dart.library.html) 'receipt_image_picker_web.dart' as impl;

class ReceiptImagePicker {
  static Future<String?> pickImage() => impl.pickReceiptImage();
}
