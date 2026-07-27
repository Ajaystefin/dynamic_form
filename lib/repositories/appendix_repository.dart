import "dart:convert";
import "dart:typed_data";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix_comment.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix_image.dart";
import "package:wcas_frontend/models/request/file_attachment/business_segment_payload.dart";
import "package:wcas_frontend/models/request/file_attachment/group_corporate_structure_payload.dart";

/// Repository responsible for handling Appendix-related APIs.
///
/// Provides operations for managing appendix-related data,
/// including images, comments, and business segment information.
class AppendixRepository {
  /// Creates an instance of [AppendixRepository].
  ///
  /// Optionally accepts an [APIManager] for dependency injection.
  /// If not provided, a default instance will be used.
  AppendixRepository({APIManager? apiManager})
      : _apiManager = apiManager ?? APIManager();

  /// Singleton instance of [AppendixRepository].
  static AppendixRepository _instance = AppendixRepository();

  /// Provides access to the singleton instance.
  static AppendixRepository get instance => _instance;

  /// Allows replacing the repository instance for testing purposes.
  @visibleForTesting
  static AppendixRepository get debugReplaceInstance => _instance;

  /// Replaces the repository instance (used in tests).
  @visibleForTesting
  static set debugReplaceInstance(AppendixRepository fake) {
    _instance = fake;
  }

  /// Handles API communication for appendix-related operations.
  final APIManager _apiManager;

  /// Uploads an Appendix Excel file and extracts its contents on the server.
  ///
  /// Sends the file as multipart data along with required metadata such as
  /// [rimNumber], [userId], and [appRefNo].
  ///
  /// - [bytes] contains the raw file data.
  /// - [fileName] is the name of the uploaded file.
  /// - [rimNumber] represents the RIM identifier.
  /// - [userId] represents the current user.
  /// - [appRefNo] represents the application reference number.
  ///
  /// Returns a success or response message based on API processing.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<String> extractAppendixXlsxAsMultipart({
    required Uint8List bytes,
    required String fileName,
    required String rimNumber,
    required String userId,
    required String appRefNo,
  }) async {
    final AppResponse response = await _apiManager.uploadFile(
      APIEndpoints.extractAppendixXlsx,
      "", // path unused for web uploads
      additionalData: {
        "rimNo": rimNumber,
        "userID": userId,
        "appRefNo": appRefNo,
        "fileNames": fileName,
      },
      fileBytes: bytes, // <-- now it exists
      fileNameOverride: fileName, // <-- now it exists
    );

    if (response.status == ResponseStatus.success) {
      if (response.body["baseResponse"]["status"]["errorCode"] != "1") {
        return response.body?["baseResponse"]?["status"]
                ?["statusDescription"] ??
            response.message;
      } else {
        return response.body?["responseData"].toString() ?? response.message;
      }
    } else {
      throw ApiException(response.message);
    }
  }

  /// Fetches Appendix Excel (XLSX) data for the given application reference number.
  ///
  /// Sends a request to retrieve previously uploaded appendix data
  /// associated with the provided [appRefNo].
  ///
  /// - [appRefNo] represents the application reference identifier.
  ///
  /// Returns a list of dynamic objects representing the appendix data.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<List<dynamic>> fetchFiAppendixXlsx(String appRefNo) async {
    final req = BaseRequest.baseRequest({"appRefNo": appRefNo});

    final AppResponse resp =
        await _apiManager.post(APIEndpoints.fetchAppendixXlsx, req);

    final statusDesc =
        resp.body?["baseResponse"]?["status"]?["statusDescription"];
    resp.message = statusDesc ?? resp.message;

    if (resp.status != ResponseStatus.success) {
      throw ApiException(resp.message);
    }

    final data = resp.body?["responseData"];
    if (data is List) {
      return data;
    }
    if (data != null) {
      return [data];
    }
    return [];
  }

  /// Deletes an extracted Appendix XLSX record by its identifier.
  ///
  /// Sends a request to remove the appendix Excel data associated
  /// with the given [appendixXlsxId].
  ///
  /// - [appendixXlsxId] must be greater than 0 and uniquely identifies
  ///   the appendix record to be deleted.
  ///
  /// Returns a success message from the API response if the operation succeeds.
  ///
  /// Throws an [ArgumentError] if the provided ID is invalid.
  /// Throws an [ApiException] if the API request fails.
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
    if (response.status != ResponseStatus.success) {
      throw ApiException(statusDescription ?? response.message);
    }

    return statusDescription ?? response.message;
  }

  /// Fetches the appendix image in Base64 format for the given application reference number.
  ///
  /// Sends a request to retrieve the appendix image associated with [appRefNo]
  /// and normalizes different possible response formats into a Base64 string.
  ///
  /// - [appRefNo] represents the application reference identifier.
  ///
  /// Returns a Base64-encoded image string if available, otherwise returns `null`.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<String?> getAppendixImageBase64({
    required String appRefNo,
  }) async {
    final Map<String, dynamic> requestBody = BaseRequest.baseRequest({
      "appRefNo": appRefNo, // String
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getAppendixImage, requestBody);

    if (response.status != ResponseStatus.success) {
      //throw Exception(response.message);
      throw ApiException(response.message);
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

  /// Retrieves appendix image as raw bytes for a given application reference number.
  ///
  /// First attempts to fetch and decode the image from a Base64 response.
  /// If Base64 data is not available or decoding fails, falls back to
  /// downloading the image as raw bytes from the API.
  ///
  /// - [appRefNo] represents the application reference identifier.
  ///
  /// Returns a [Uint8List] containing image bytes if available,
  /// otherwise returns `null`.
  ///
  /// Throws an [ApiException] if the API request fails during Base64 retrieval.
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
      } on Object catch (_) {
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

  /// Saves appendix business segment data using the provided payload.
  ///
  /// Wraps the [payload] inside a `requestData` array (as required by the backend)
  /// and sends it to the API for persistence.
  ///
  /// - [payload] contains the business segment details to be saved.
  ///
  /// Returns a success message from the API response if the operation succeeds.
  ///
  /// Throws an [ApiException] if the API request fails.
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
      throw ApiException(statusDescription ?? response.message);
    }

    final String? statusDescription = response.body?["baseResponse"]?["status"]
        ?["statusDescription"] as String?;
    return statusDescription ?? response.message;
  }

  /// Fetches appendix image details as a raw [AppResponse].
  ///
  /// Provides direct access to the unprocessed API response,
  /// allowing advanced callers to handle parsing or extraction logic.
  ///
  /// - [appRefNo] represents the application reference identifier.
  ///
  /// Returns the full [AppResponse] with normalized status message.
  ///
  /// Throws an [ApiException] if the API request fails.
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

  /// Fetches and returns a normalized list of [AppendixImageItem] for the given [appRefNo].
  ///
  /// Retrieves appendix image data and converts different possible response formats
  /// (Map, List, or String) into a uniform list of [AppendixImageItem] objects.
  ///
  /// Filters and includes only items that contain valid Base64 image data.
  ///
  /// - [appRefNo] represents the application reference identifier.
  ///
  /// Returns a list of [AppendixImageItem] with valid image content.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<List<AppendixImageItem>> fetchAppendixImageItems(
    String appRefNo,
  ) async {
    final AppResponse response = await fetchAppendixImages(appRefNo);

    if (response.status != ResponseStatus.success) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }

    final dynamic payload = response.body?["responseData"];
    final List<AppendixImageItem> items = <AppendixImageItem>[];

    if (payload == null) {
      return items;
    }

    if (payload is Map<String, dynamic>) {
      final item = AppendixImageItem.fromMap(payload);
      if (item.hasBase64) {
        items.add(item);
      }
    } else if (payload is List) {
      for (final dynamic any in payload) {
        final item = AppendixImageItem.fromAny(any);
        if (item.hasBase64) {
          items.add(item);
        }
      }
    } else if (payload is String) {
      if (payload.isNotEmpty) {
        items.add(AppendixImageItem.fromAny(payload));
      }
    }

    return items;
  }

  /// Saves an appendix image to the backend.
  ///
  /// Sends image data along with required metadata to persist
  /// appendix images for a specific application.
  ///
  /// - [appRefNo] represents the application reference identifier.
  /// - [customerType] defines the customer category (e.g., "Bank", "Country").
  /// - [fileName] is the name of the uploaded image file.
  /// - [imageType] specifies the type of image
  ///   (e.g., "Financial", "RatingSP", "CountryMap", "CountryGovt").
  /// - [imageDataBase64] contains the Base64-encoded image data.
  ///
  /// Returns a status message from the API response if the operation succeeds.
  ///
  /// Throws an [ApiException] if the API request fails.
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
      return response.body["baseResponse"]["status"]["statusDescription"];
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Saves an appendix image using raw byte data.
  ///
  /// Converts the provided [bytes] into a Base64 string and delegates
  /// the request to [saveAppendixImage].
  ///
  /// - [appRefNo] represents the application reference identifier.
  /// - [customerType] defines the customer category.
  /// - [fileName] is the name of the image file.
  /// - [imageType] specifies the type of image.
  /// - [bytes] contains the raw image data.
  ///
  /// Returns a status message from the API response if the operation succeeds.
  ///
  /// Throws an [ApiException] if the API request fails.
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

  /// Deletes an appendix image for the specified file and context.
  ///
  /// Sends a request to remove an appendix image using the provided
  /// [fileId], [appRefNo], and [customerType].
  ///
  /// - [fileId] uniquely identifies the image file.
  /// - [appRefNo] represents the application reference identifier.
  /// - [customerType] defines the customer category.
  ///
  /// Returns a status message from the API response if the operation succeeds.
  ///
  /// Throws an [ApiException] if the API request fails.
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
      throw ApiException(statusDescription ?? response.message);
    }

    final String? statusDescription = response.body?["baseResponse"]?["status"]
        ?["statusDescription"] as String?;
    return statusDescription ?? response.message;
  }

  /// Fetches appendix business segment data and maps it to an [Appendix] model.
  ///
  /// Sends a request using [appRefNo] (and optionally [rimNo]) to retrieve
  /// appendix business segment data from the backend, then normalizes
  /// different response formats into a consistent model.
  ///
  /// Handles both nested (`countryOverView`) and flat response structures.
  ///
  /// - [appRefNo] represents the application reference identifier.
  /// - [rimNo] represents the RIM identifier (if applicable).
  ///
  /// Returns an [Appendix] model if data is available, otherwise returns `null`.
  ///
  /// Throws an [ApiException] if the API request fails.
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
      throw ApiException(statusDescription ?? response.message);
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
    if (item == null) {
      return null;
    }

    // Map<String, dynamic>?
    final Map<String, dynamic>? countryOverview =
        (item["countryOverView"] as Map?)?.cast<String, dynamic>();

    if (countryOverview != null) {
      return Appendix.fromCountryOverViewJson(countryOverview);
    }

    return Appendix.fromFlatJson(item);
  }

  /// Deletes a review entry of type "strengths" or "threats".
  ///
  /// Sends a request to remove review data for the specified [appRefNo],
  /// based on the provided [type]. The type is normalized internally
  /// to ensure valid values ("strengths" or "threats").
  ///
  /// - [appRefNo] represents the application reference identifier.
  /// - [type] must be either "strengths" or "threats".
  /// - [strengths] optional value used when deleting strengths.
  /// - [threats] optional value used when deleting threats.
  ///
  /// Returns a status message from the API response if the operation succeeds.
  ///
  /// Throws an [ArgumentError] if the type is invalid.
  /// Throws an [ApiException] if the API request fails.
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
      throw ApiException(statusDescription ?? response.message);
    }

    final String? statusDescription = response.body?["baseResponse"]?["status"]
        ?["statusDescription"] as String?;
    return statusDescription ?? response.message;
  }

  /// Saves a list of "Group Corporate Structure" comment entries.
  ///
  /// Wraps the provided [list] into a `requestData` array as required by
  /// the backend and sends it to the API for persistence.
  ///
  /// - [list] contains multiple comment payloads to be saved.
  ///
  /// Returns a status message from the API response if the operation succeeds.
  ///
  /// Throws an [ApiException] if the API request fails.
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
      throw ApiException(statusDescription ?? response.message);
    }

    final String? statusDescription = response.body?["baseResponse"]?["status"]
        ?["statusDescription"] as String?;
    return statusDescription ?? response.message;
  }

  /// Fetches appendix comments for a given [appRefNo].
  ///
  /// Sends a request to retrieve comments and maps the response
  /// into a list of [AppendixComment] objects. Optionally filters
  /// and sorts the results for consistent usage.
  ///
  /// - [appRefNo] represents the application reference identifier.
  /// - [onlyGroupCorporateStructure] filters results to only
  ///   "Group Corporate Structure" comments when set to true.
  ///
  /// Returns a sorted list of [AppendixComment] objects.
  ///
  /// Throws an [ApiException] if the API request fails.
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
      throw ApiException(apiResponse.message);
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

  /// Deletes an appendix comment for the specified application reference.
  ///
  /// Sends a request to remove the comment identified by [appendixRemarkId]
  /// for the given [appRefNo].
  ///
  /// - [appRefNo] represents the application reference identifier.
  /// - [appendixRemarkId] uniquely identifies the comment to be deleted.
  ///
  /// Returns a status message from the API response if the operation succeeds.
  ///
  /// Throws an [ApiException] if the API request fails.
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
      throw ApiException(apiResponse.message);
    }

    return apiResponse.message;
  }
}
