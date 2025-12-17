import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/core/services/api_service/base_request.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/request/comment.dart';

class CommonRepository {
  static CommonRepository _singleton = CommonRepository();
  static CommonRepository get instance => _singleton;

  static void overrideInstance(CommonRepository newInstance) {
    _singleton = newInstance;
  }

  final APIManager _apiManager;

  CommonRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  Future<List<Comment>> getComments(
      CommentsType type, EntityIdentifier? entityIdentifier) async {
    Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "commentCategoryId": ServerConstants.commentTypeId[type],
      "entityIdentifier": ServerConstants.entityId[entityIdentifier]
    });
    AppResponse response =
        await _apiManager.post(APIEndpoints.getComments, data);
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
    final List<dynamic> raw =
        response.body['responseData']['commentList'] as List;
    return raw.map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String> saveComment(Comment comment) async {
    Map data = BaseRequest.baseRequest({
      "commentList": [comment.toSaveJson()],
    });

    AppResponse response =
        await _apiManager.post(APIEndpoints.saveComments, data);
    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<List<Comment>> getApplicationStrategyDetails(
      CommentsType type, EntityIdentifier entityIdentifier,
      {String? appReffNo}) async {
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

      final List<Comment> comments =
          (response.body["responseData"]?["commentList"] as List<dynamic>?)
                  ?.map((item) => Comment.fromJson(item))
                  .toList() ??
              [];

      return comments;
    }

    throw response.message;
  }

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
      response.message = response.body["responseData"].toString();
      return response.message;
    }

    throw response.message;
  }

  Future<List<Comment>> getStategyComment(
      int? categoryID, String? strategyCategory) async {
    Map<String, dynamic> data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "categoryId": categoryID,
      "strategyCategory": strategyCategory,
    });

    AppResponse response =
        await _apiManager.post(APIEndpoints.getStategyComment, data);

    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
    if (response.body['responseData'] == null) {
      return [];
    }
    final List<dynamic> raw = response.body['responseData'] as List;
    return raw.map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String> saveStategyComment(Comment? comment) async {
    if (comment == null) {
      return ("comment is null");
    }

    Map<String, dynamic> data = BaseRequest.baseRequest({
      ...comment.toSaveStrategyCommentJson(),
      "appRefNo": Globals.request?.applicationRefNo,
      "rimNo": Globals.request?.customerRimNo,
    });

    AppResponse response =
        await _apiManager.post(APIEndpoints.saveStategyComment, data);

    if (response.status == ResponseStatus.error) {
      throw response.message;
    }

    return response.message;
  }
}
