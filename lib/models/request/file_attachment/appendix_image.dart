// lib/models/request/file_attachment/appendix_image_item.dart
import "dart:convert";
import "dart:typed_data";

/// Represents an appendix image attachment and its metadata.
class AppendixImageItem {
  /// Creates an [AppendixImageItem] instance.
  const AppendixImageItem({
    required this.imageData,
    required this.fileName,
    this.imageType,
    this.customerType,
    this.fileId,
  });

  /// Creates an [AppendixImageItem] instance from
  /// a supported backend response object.
  factory AppendixImageItem.fromAny(any) {
    if (any is Map) {
      return AppendixImageItem.fromMap(any.cast<String, dynamic>());
    } else if (any is String) {
      return AppendixImageItem(
        imageData: any.isNotEmpty ? any : null,
        fileName: "",
      );
    }
    // Unknown shape → empty item
    return const AppendixImageItem(
      imageData: null,
      fileName: "",
    );
  }

  /// Creates an [AppendixImageItem] instance from a JSON map.
  factory AppendixImageItem.fromMap(Map<String, dynamic> src) {
    // Coalesce common base64 keys into 'imageData'
    final String? base64 = (src["imageData"] ??
        src["imageDataBase64"] ??
        src["contentBase64"] ??
        src["imageBase64"] ??
        src["image"]) as String?;

    return AppendixImageItem(
      imageData: base64,
      fileName: (src["fileName"] as String?) ?? (src["name"] as String?) ?? "",
      imageType: src["imageType"] as String?,
      customerType: src["customerType"] as String?,
      fileId: (src["fileId"] as num?)?.toInt(),
    );
  }

  /// Base64 encoded image data.
  final String? imageData;

  /// File name.
  final String fileName;

  /// Image type.
  final String? imageType;

  /// Customer type.
  final String? customerType;

  /// File identifier.
  final int? fileId;

  /// Indicates whether valid Base64 image data exists.
  bool get hasBase64 => imageData != null && imageData!.isNotEmpty;

  /// Attempts to decode the Base64 image data into bytes.
  Uint8List? tryDecodeBytes() {
    if (!hasBase64) {
      return null;
    }
    try {
      return base64Decode(imageData!);
    } on Object catch (_) {
      return null;
    }
  }
}
