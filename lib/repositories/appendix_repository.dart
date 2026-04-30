import "dart:convert"; // base64Encode, base64Decode
import "dart:typed_data"; // Uint8List

// import 'package:file_picker/file_picker.dart';
import "package:flutter/material.dart";

import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix_comment.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix_image.dart";
import "package:wcas_frontend/models/request/file_attachment/business_segment_payload.dart";
// import 'package:wcas_frontend/models/request/file_attachment/document.dart';
import "package:wcas_frontend/models/request/file_attachment/group_corporate_structure_payload.dart";

/// Repository that handles Appendix-related APIs (images, comments, business
/// segment).
///
class AppendixRepository {
  AppendixRepository({APIManager? apiManager})
      : _apiManager = apiManager ?? APIManager();
  // Singleton instance

  static AppendixRepository _instance = AppendixRepository();
  static AppendixRepository get instance => _instance;

  @visibleForTesting
  static set debugReplaceInstance(AppendixRepository fake) {
    _instance = fake;
  }

  // Dependencies
  final APIManager _apiManager;
// in AppendixRepository
  Future<String> extractAppendixXlsxAsMultipart({
    required Uint8List bytes,
    required String fileName,
    required String rimNumber,
    required String userId,
    required String appRefNo,
  }) async {
    final resp = await _apiManager.uploadFile(
      APIEndpoints.extractAppendixXlsx,
      "", // path unused for web uploads
      fieldName: "file",
      additionalData: {
        "rimNo": rimNumber,
        "userID": userId,
        "appRefNo": appRefNo,
      },
      fileBytes: bytes, // <-- now it exists
      fileNameOverride: fileName, // <-- now it exists
    );

    final statusDescription =
        resp.body?["baseResponse"]?["status"]?["statusDescription"];

    return statusDescription ?? resp.message;
  }

  Future<List<dynamic>> fetchFiAppendixXlsx(String appRefNo) async {
    final req = BaseRequest.baseRequest({"appRefNo": appRefNo});

    final AppResponse resp =
        await _apiManager.post(APIEndpoints.fetchAppendixXlsx, req);

    final statusDesc =
        resp.body?["baseResponse"]?["status"]?["statusDescription"];
    resp.message = statusDesc ?? resp.message;

    if (resp.status != ResponseStatus.success) {
      throw resp.message;
    }

    final data = resp.body?["responseData"];
    if (data is List) return data;
    if (data != null) return [data];
    return [];
  }

  Future<String> deleteExtractAppendixXlsx({
    required int appendixXlsxId,
  }) async {
    if (appendixXlsxId <= 0) {
      throw ArgumentError("appendixXlsxId must be > 0. Got: $appendixXlsxId");
    }

    final Map<String, dynamic> requestBody = BaseRequest.baseRequest({});
    requestBody["requestData"] = <String, dynamic>{
      "appendixXlsxID": appendixXlsxId,
    };

    final AppResponse response = await _apiManager.post(
      APIEndpoints.deleteExtractAppendixXlsx,
      requestBody,
    );

    // Normalize backend message from statusDescription (if present)
    final String? statusDescription = response.body?["baseResponse"]?["status"]
        ?["statusDescription"] as String?;
    final String message = statusDescription ?? response.message;

    if (response.status != ResponseStatus.success) {
      throw message;
    }

    return message;
  }

  Future<String?> getAppendixImageBase64({
    required String appRefNo,
  }) async {
    final Map<String, dynamic> requestBody = BaseRequest.baseRequest({
      "appRefNo": appRefNo, // String
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getAppendixImage, requestBody);

    if (response.status != ResponseStatus.success) {
      throw response.message;
    }

    // dynamic (typically Map<String, dynamic>)
    final dynamic responseBody = response.body;

    // String? — backend status message
    final String? statusDescription = responseBody?["baseResponse"]?["status"]
        ?["statusDescription"] as String?;
    response.message = statusDescription ?? response.message;

    // Can be Map<String, dynamic> | List<dynamic> | String
    final dynamic responseData = responseBody?["responseData"];

    // Normalize possible Base64 sources into: String? imageBase64
    String? imageBase64;

    if (responseData is Map) {
      // Known keys where Base64 might be stored
      imageBase64 = (responseData["contentBase64"] ??
          responseData["imageDataBase64"] ??
          responseData["imageBase64"] ??
          responseData["image"]) as String?;
    } else if (responseData is List) {
      // Iterate list items to find the first usable Base64 string
      for (final dynamic item in responseData) {
        final String? candidateBase64 = (item?["contentBase64"] ??
            item?["imageDataBase64"] ??
            item?["imageBase64"] ??
            item?["image"]) as String?;
        if (candidateBase64 != null && candidateBase64.isNotEmpty) {
          imageBase64 = candidateBase64;
          break;
        }
      }
    } else if (responseData is String) {
      imageBase64 = responseData;
    }

    return (imageBase64 != null && imageBase64.isNotEmpty) ? imageBase64 : null;
  }

  /// Fetches appendix image bytes for a given appRefNo.
  ///
  /// Tries to decode JSON Base64 first; if not available, attempts raw bytes
  /// download.
  ///
  /// Returns:
  /// - Uint8List? — the image bytes, or null if unavailable.
  Future<Uint8List?> getAppendixImageBytes({
    required String appRefNo,
  }) async {
    // Attempt JSON flow first to get: String? imageBase64
    final String? imageBase64 =
        await getAppendixImageBase64(appRefNo: appRefNo);
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        // Converts Base64 string into Uint8List
        return base64Decode(imageBase64);
      } catch (_) {
        // If decode fails, continue with raw-bytes fallback
      }
    }

    // Fallback: download raw bytes
    final Map<String, dynamic> requestBody = BaseRequest.baseRequest({
      "appRefNo": appRefNo, // String
    });

    // Expect AppResponse.body to be List<int> for bytes
    final AppResponse downloadResponse = await _apiManager.downloadFile(
      APIEndpoints.getAppendixImage,
      requestBody,
    );

    if (downloadResponse.body is List<int>) {
      return Uint8List.fromList(downloadResponse.body as List<int>);
    }

    return null;
  }

  /// Thin wrapper for the raw response (useful for advanced callers).

// lib/repositories/appendix_repository.dart (or wherever)

  /// Saves Appendix Business Segment using the BusinessSegmentPayload object.
  ///
  /// Sends `requestData` as an array of one item, matching backend contract.
  Future<String?> saveAppendixBusinessSegmentPayload(
    BusinessSegmentPayload payload,
  ) async {
    final Map<String, dynamic> requestBody = BaseRequest.baseRequest({});
    requestBody["requestData"] = [payload.toJson()];

    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveAppendixBusinnesSegment,
      requestBody,
    );

    if (response.status != ResponseStatus.success) {
      final String? statusDescription = response.body?["baseResponse"]
          ?["status"]?["statusDescription"] as String?;
      throw statusDescription ?? response.message;
    }

    final String? statusDescription = response.body?["baseResponse"]?["status"]
        ?["statusDescription"] as String?;
    return statusDescription ?? response.message;
  }

  /// Thin wrapper for the raw response (useful for advanced callers).
  Future<AppResponse> fetchAppendixImages(String appRefNo) async {
    final Map<String, dynamic> requestBody = BaseRequest.baseRequest({
      "appRefNo": appRefNo,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getAppendixImage, requestBody);

    // Normalize message from backend status (if available)
    final String? statusDescription = response.body?["baseResponse"]?["status"]
        ?["statusDescription"] as String?;
    response.message = statusDescription ?? response.message;

    return response;
  }

  /// Fetches and returns a normalized list of AppendixImageItem for a given
  /// appRefNo.
  ///
  /// Throws response.message on non-success.
  Future<List<AppendixImageItem>> fetchAppendixImageItems(
    String appRefNo,
  ) async {
    final AppResponse response = await fetchAppendixImages(appRefNo);

    if (response.status != ResponseStatus.success) {
      throw response.message;
    }

    final dynamic payload = response.body?["responseData"];
    final List<AppendixImageItem> items = <AppendixImageItem>[];

    if (payload == null) return items;

    if (payload is Map<String, dynamic>) {
      final item = AppendixImageItem.fromMap(payload);
      if (item.hasBase64) items.add(item);
    } else if (payload is List) {
      for (final dynamic any in payload) {
        final item = AppendixImageItem.fromAny(any);
        if (item.hasBase64) items.add(item);
      }
    } else if (payload is String) {
      if (payload.isNotEmpty) {
        items.add(AppendixImageItem.fromAny(payload));
      }
    }

    return items;
  }

  /// Saves an appendix image.
  ///
  /// Request:
  /// - appRefNo: String
  /// - customerType: String (e.g., "Bank", "Country")
  /// - fileName: String
  /// - imageType: String ("Financial" | "RatingSP" | "CountryMap" |
  /// "CountryGovt")
  /// - imageDataBase64: String (Base64)
  ///
  /// Returns:
  /// - String? — backend statusDescription message on success
  /// Throws:
  /// - response.message on failure
  Future<String?> saveAppendixImage({
    required String appRefNo,
    required String customerType,
    required String fileName,
    required String imageType,
    required String imageDataBase64,
  }) async {
    final Map<String, dynamic> requestBody = BaseRequest.baseRequest({
      "appRefNo": appRefNo,
      "customerType": customerType,
      "fileName": fileName,
      "imageType": imageType,
      "imageData": imageDataBase64,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveAppendixImage, requestBody);

    if (response.status == ResponseStatus.success) {
      // Map<String, dynamic> → String
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      return response.message;
    } else {
      throw response.message;
    }
  }

  /// Wrapper to save image bytes (Uint8List) — converts to Base64 and
  /// delegates.
  ///
  /// Returns:
  /// - String? — backend statusDescription message on success
  Future<String?> saveAppendixImageBytes({
    required String appRefNo,
    required String customerType,
    required String fileName,
    required String imageType,
    required Uint8List bytes,
  }) {
    final String imageDataBase64 = base64Encode(bytes);
    return saveAppendixImage(
      appRefNo: appRefNo,
      customerType: customerType,
      fileName: fileName,
      imageType: imageType,
      imageDataBase64: imageDataBase64,
    );
  }

  /// Deletes an appendix image by fileId/appRefNo/customerType.
  ///
  /// Request:
  /// - fileId: int
  /// - appRefNo: String
  /// - customerType: String
  ///
  /// Returns:
  /// - String? — backend statusDescription message on success
  /// Throws:
  /// - statusDescription/message on failure
  Future<String?> deleteAppendixImage({
    required int fileId,
    required String appRefNo,
    required String customerType,
  }) async {
    final Map<String, dynamic> requestBody = BaseRequest.baseRequest({
      "fileId": fileId,
      "appRefNo": appRefNo,
      "customerType": customerType,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.deleteAppendixImage, requestBody);

    if (response.status != ResponseStatus.success) {
      final String? statusDescription = response.body?["baseResponse"]
          ?["status"]?["statusDescription"] as String?;
      throw statusDescription ?? response.message;
    }

    final String? statusDescription = response.body?["baseResponse"]?["status"]
        ?["statusDescription"] as String?;
    response.message = statusDescription ?? response.message;
    return response.message;
  }

  /// Retrieves Appendix Business Segment and builds an `Appendix` model.
  ///
  /// Response:
  /// - responseData: Map<String, dynamic> | List<Map<String, dynamic>>
  /// - item["countryOverView"]: Map<String, dynamic>? (when present)
  ///
  /// Returns:
  /// - Appendix? — model built from countryOverView or flat fallback
  Future<Appendix?> getAppendixBusinessSegmentToModel({
    required String appRefNo,
    required int? rimNo,
  }) async {
    final Map<String, dynamic> requestBody = BaseRequest.baseRequest({
      "appRefNo": appRefNo,
      "businessSegment": "corporate",
      // "rimNo": rimNo, // Uncomment if API requires it
    });

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getAppendixBusinessSegement,
      requestBody,
    );

    if (response.status != ResponseStatus.success) {
      final String? statusDescription = response.body?["baseResponse"]
          ?["status"]?["statusDescription"] as String?;
      throw statusDescription ?? response.message;
    }

    final dynamic responseData = response.body?["responseData"]; // dynamic

    // Map<String, dynamic>?
    Map<String, dynamic>? item;
    if (responseData is List &&
        responseData.isNotEmpty &&
        responseData.first is Map) {
      item = (responseData.first as Map).cast<String, dynamic>();
    } else if (responseData is Map<String, dynamic>) {
      item = responseData;
    }
    if (item == null) return null;

    // Map<String, dynamic>?
    final Map<String, dynamic>? countryOverview =
        (item["countryOverView"] as Map?)?.cast<String, dynamic>();

    if (countryOverview != null) {
      return Appendix.fromCountryOverViewJson(countryOverview);
    }

    return Appendix.fromFlatJson(item);
  }

  /// Saves "Group Corporate Structure" comment entry.
  ///
  /// Request:
  /// - requestBody["requestData"]: List<Map<String, dynamic>>
  /// - dates are serialized as ISO-8601 UTC strings (String)
  ///
  /// Returns:
  /// - String — statusDescription or message
  /// Throws:
  /// - message on failure

  Future<String> saveGroupCorporateStructureComment(
    GroupCorporateStructureCommentPayload payload,
  ) async {
    final Map<String, dynamic> requestBody = BaseRequest.baseRequest({});
    requestBody["requestData"] = [payload.toJson()];

    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveAppendixComment,
      requestBody,
    );

    if (response.status != ResponseStatus.success) {
      final String? statusDescription = response.body?["baseResponse"]
          ?["status"]?["statusDescription"] as String?;
      throw statusDescription ?? response.message;
    }

    final String? statusDescription = response.body?["baseResponse"]?["status"]
        ?["statusDescription"] as String?;
    return statusDescription ?? response.message;
  }

  /// Deletes review (either "strengths" or "threats").
  ///
  /// Request:
  /// - type: String ("strengths" | "threats") — normalized to lowercase/trimmed
  ///
  /// Returns:
  /// - String? — statusDescription on success
  /// Throws:
  /// - message on failure
  Future<String?> deleteReview({
    required String appRefNo,
    required String type, // "strengths" or "threats"
    String strengths = "",
    String threats = "",
  }) async {
    final String normalizedType = type.trim().toLowerCase();
    if (normalizedType != "strengths" && normalizedType != "threats") {
      throw ArgumentError('type must be "strengths" or "threats". Got: $type');
    }

    final Map<String, dynamic> requestBody = BaseRequest.baseRequest({
      "appRefNo": appRefNo,
      "type": normalizedType,
      "strengths": strengths,
      "threats": threats,
    });

    final AppResponse response =
        await _apiManager.delete(APIEndpoints.deleteReview, requestBody);

    if (response.status != ResponseStatus.success) {
      final String? statusDescription = response.body?["baseResponse"]
          ?["status"]?["statusDescription"] as String?;
      throw statusDescription ?? response.message;
    }

    final String? statusDescription = response.body?["baseResponse"]?["status"]
        ?["statusDescription"] as String?;
    response.message = statusDescription ?? response.message;
    return response.message;
  }

  Future<String> saveGroupCorporateStructureCommentList(
    List<GroupCorporateStructureCommentPayload> list,
  ) async {
    final Map<String, dynamic> requestBody = BaseRequest.baseRequest({});
    requestBody["requestData"] = list.map((e) => e.toJson()).toList();

    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveAppendixComment,
      requestBody,
    );

    if (response.status != ResponseStatus.success) {
      final String? statusDescription = response.body?["baseResponse"]
          ?["status"]?["statusDescription"] as String?;
      throw statusDescription ?? response.message;
    }

    final String? statusDescription = response.body?["baseResponse"]?["status"]
        ?["statusDescription"] as String?;
    return statusDescription ?? response.message;
  }

  /// Fetches Appendix comments for a given appRefNo.
  ///
  /// Response:
  /// - responseData: List<Map<String, dynamic>>
  ///
  /// Returns:
  /// - List<AppendixComment>
  /// Throws:
  /// - message on failure
  Future<List<AppendixComment>> fetchAppendixComments(
    String appRefNo, {
    bool onlyGroupCorporateStructure = false, // Optional filter
  }) async {
    // 1) Build request
    final Map<String, dynamic> requestPayload = BaseRequest.baseRequest({});
    requestPayload["requestData"] = <String, dynamic>{
      "appRefNo": appRefNo,
    };

    // 2) Call API
    final AppResponse apiResponse =
        await _apiManager.post(APIEndpoints.getAppendixComment, requestPayload);

    // 3) Surface backend status message (if any)
    final String? statusDescription = apiResponse.body?["baseResponse"]
        ?["status"]?["statusDescription"] as String?;
    apiResponse.message = statusDescription ?? apiResponse.message;

    // 4) Check status
    if (apiResponse.status != ResponseStatus.success) {
      throw apiResponse.message;
    }

    // 5) Extract and validate payload
    final Object? responsePayload = apiResponse.body?["responseData"];
    if (responsePayload is! List) {
      return const <AppendixComment>[];
    }

    final List<dynamic> responseList = responsePayload;

    // 6) Parse list items into AppendixComment
    List<AppendixComment> comments = responseList
        .whereType<Map>() // filters to Map<dynamic, dynamic>
        .map(
          (Map<dynamic, dynamic> raw) =>
              AppendixComment.fromJson(raw.cast<String, dynamic>()),
        )
        .toList();

    // Optional: filter to canonical "Group Corporate Structure"
    const String kCanonicalGroupCorporateStructure =
        "Group Corporate Structure";
    if (onlyGroupCorporateStructure) {
      comments = comments
          .where(
            (AppendixComment c) =>
                c.commentType == kCanonicalGroupCorporateStructure,
          )
          .toList();
    }

    // 7) Sort: primary by appendixRemarkId asc (if present), fallback to
    // createdDate asc
    comments.sort((AppendixComment a, AppendixComment b) {
      final int? aId = a.appendixRemarkId;
      final int? bId = b.appendixRemarkId;

      if (aId != null && bId != null) {
        return aId.compareTo(bId);
      }

      final int aEpoch = a.createdDate?.millisecondsSinceEpoch ?? -1;
      final int bEpoch = b.createdDate?.millisecondsSinceEpoch ?? -1;
      return aEpoch.compareTo(bEpoch);
    });

    return comments;
  }

  Future<String?> deleteAppendixComment({
    required String appRefNo,
    required int appendixRemarkId,
  }) async {
    final Map<String, dynamic> requestPayload = BaseRequest.baseRequest({});
    requestPayload["requestData"] = <String, dynamic>{
      "appRefNo": appRefNo,
      "appendixRemarkId": appendixRemarkId,
    };

    final AppResponse apiResponse = await _apiManager.delete(
      APIEndpoints.deletAppendixComment,
      requestPayload,
    );

    // Normalize backend message
    final String? statusDescription = apiResponse.body?["baseResponse"]
        ?["status"]?["statusDescription"] as String?;
    apiResponse.message = statusDescription ?? apiResponse.message;

    if (apiResponse.status != ResponseStatus.success) {
      throw apiResponse.message;
    }

    return apiResponse.message;
  }
}
