// lib/models/request/file_attachment/appendix_image_item.dart
import "dart:convert";
import "dart:typed_data";

class AppendixImageItem {
  const AppendixImageItem({
    required this.imageData,
    required this.fileName,
    this.imageType,
    this.customerType,
    this.fileId,
  });

  /// Build from any backend shape (Map or raw String)
  factory AppendixImageItem.fromAny(dynamic any) {
    if (any is Map) {
      return AppendixImageItem.fromMap(any.cast<String, dynamic>());
    } else if (any is String) {
      return AppendixImageItem(
        imageData: any.isNotEmpty ? any : null,
        fileName: "",
        imageType: null,
        customerType: null,
        fileId: null,
      );
    }
    // Unknown shape → empty item
    return const AppendixImageItem(
      imageData: null,
      fileName: "",
      imageType: null,
      customerType: null,
      fileId: null,
    );
  }

  /// Normalize common keys into a stable DTO.
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

  /// Base64 payload (normalized)
  final String? imageData;

  /// Optional metadata
  final String fileName;
  final String? imageType;
  final String? customerType;
  final int? fileId;

  /// Convenience: indicates if usable payload is present
  bool get hasBase64 => imageData != null && imageData!.isNotEmpty;

  /// Convenience: decode to bytes (returns null on failure)
  Uint8List? tryDecodeBytes() {
    if (!hasBase64) return null;
    try {
      return base64Decode(imageData!);
    } catch (_) {
      return null;
    }
  }
}
