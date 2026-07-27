import "package:flutter/foundation.dart" show visibleForTesting;
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/comment.dart";

/// Repository responsible for handling common/shared application operations.
///
/// Provides reusable API interactions used across multiple modules and
/// maintains a singleton instance for global access.
class CommonRepository {
  CommonRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  /// Internal singleton instance of [CommonRepository].
  static CommonRepository _singleton = CommonRepository();

  /// Returns the singleton instance of [CommonRepository].
  static CommonRepository get instance => _singleton;

  /// Overrides the singleton instance of [CommonRepository].
  ///
  /// Intended for use in testing or controlled scenarios where a custom
  /// repository instance needs to be injected.
  // ignore: avoid_setters_without_getters
  static set overrideInstance(CommonRepository newInstance) {
    _singleton = newInstance;
  }

  /// Overrides the singleton instance of [CommonRepository] for testing purposes.
  ///
  /// Annotated with [visibleForTesting] to indicate that this setter should only
  /// be used in tests or controlled debug scenarios to inject a fake repository.
  // ignore: avoid_setters_without_getters
  @visibleForTesting
  static set debugReplaceInstance(CommonRepository fake) {
    _singleton = fake;
  }

  /// API manager used to perform network requests.
  final APIManager _apiManager;

  /// Retrieves comments based on the specified type and entity identifier.
  /// 
  /// Sends the application reference, comment category, and entity identifier
  /// to the backend and maps the response into a list of [Comment] objects.
  /// Returns the list of comments on success.
  /// Throws [ApiException] if the API call fails.
  Future<List<Comment>> getComments(
    CommentsType type,
    EntityIdentifier? entityIdentifier,
  ) async {
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "commentCategoryId": ServerConstants.commentTypeId[type],
      "entityIdentifier": ServerConstants.entityId[entityIdentifier],
    });
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getComments, data);
    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
    final List<dynamic> raw =
        response.body["responseData"]["commentList"] as List;
    return raw.map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Saves a comment for the current application.
  /// 
  /// Converts the provided [Comment] into the required format and submits it
  /// to the backend for persistence.
  /// Returns a success message string on successful save.
  /// Throws [ApiException] if the API call fails.
  Future<String> saveComment(Comment comment) async {
    final Map data = BaseRequest.baseRequest({
      "commentList": [comment.toSaveJson()],
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveComments, data);
    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves application strategy comments based on type and entity identifier.
  /// 
  /// Sends the application reference number along with strategy comment type
  /// and entity identifier to the backend, and maps the response into a list
  /// of [Comment] objects.
  /// Returns the list of comments on success, or an empty list if no data is found.
  /// Throws [ApiException] if the API call fails.
  Future<List<Comment>> getApplicationStrategyDetails(
    CommentsType type,
    EntityIdentifier entityIdentifier, {
    String? appReffNo,
  }) async {
    final Map<String, dynamic> requestData = {
      "appRefNo": appReffNo ?? Globals.request?.applicationRefNo,
      "strategyCommentsType": ServerConstants.commentTypeId[type],
      "entityIdentifier": ServerConstants.entityId[entityIdentifier],
    };

    final Map<String, dynamic> data = BaseRequest.baseRequest(requestData);

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getApplicationStrategyDetails,
      data,
    );

    if (response.status == ResponseStatus.success) {
      response.message =
          response.body["baseResponse"]?["status"]?["statusDescription"];

      return (response.body["responseData"]?["commentList"] as List<dynamic>?)
              ?.map((item) => Comment.fromJson(item))
              .toList() ??
          [];
    }

    //throw Exception(response.message);
    throw ApiException(response.message);
  }

  /// Saves application strategy details for the current application.
  /// 
  /// Submits strategy comment data, including type and comment list, to the backend.
  /// Returns the response message string on successful save.
  /// Throws [ApiException] if the API call fails.
  Future<String?> saveApplicationStrategyDetails(
    int strategyCommentsType,
    int appStrategyCommentsId,
    Comment? comment,
  ) async {
    final Map<String, dynamic> requestData = {
      "appRefNo": Globals.request?.applicationRefNo,
      "strategyCommentsType": strategyCommentsType,
      "commentList": [
        comment?.toPresentRequestJson(),
      ],
    };

    final Map<String, dynamic> data = BaseRequest.baseRequest(requestData);

    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveApplicationStrategyDetails,
      data,
    );

    if (response.status == ResponseStatus.success) {
      return response.body["responseData"].toString();
    }

    //throw Exception(response.message);
    throw ApiException(response.message);
  }

  /// Retrieves strategy comments based on category and strategy type.
  /// 
  /// Sends category ID, strategy category, and optional application reference
  /// to the backend, and maps the response into a list of [Comment] objects.
  /// Returns the list of comments on success, or an empty list if no data is available.
  /// Throws [ApiException] if the API call fails.
  Future<List<Comment>> getStategyComment(
    int? categoryID,
    String? strategyCategory, {
    String? appRefNo,
  }) async {
    final Map<String, dynamic> data = BaseRequest.baseRequest({
      "appRefNo": appRefNo,
      "categoryId": categoryID,
      "strategyCategory": strategyCategory,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getStategyComment, data);

    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
    if (response.body["responseData"] == null) {
      return [];
    }
    final List<dynamic> raw = response.body["responseData"] as List;
    return raw.map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Saves a strategy comment for the current application.
  /// 
  /// Accepts a [Comment] object, merges it with optional application reference
  /// and RIM number, and submits it to the backend.
  /// Returns a success message string on successful save.
  /// Throws [ApiException] if the API call fails.
  Future<String> saveStategyComment(
    Comment? comment, {
    String? appRefNo,
    int? rimNo,
  }) async {
    if (comment == null) {
      return "comment is null";
    }

    final Map<String, dynamic> data = BaseRequest.baseRequest({
      ...comment.toSaveStrategyCommentJson(),
      "appRefNo": appRefNo,
      "rimNo": rimNo,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveStategyComment, data);

    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }

    return response.message;
  }
}
