import "dart:convert";
import "dart:developer";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/models/admin/access_right.dart";
import "package:wcas_frontend/models/admin/file_access.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";

class AdminRepository {
  AdminRepository({
    APIManager? apiManager,
    ReferenceDataService? referenceDataService,
  })  : _apiManager = apiManager ?? APIManager(),
        _referenceDataService = referenceDataService ?? ReferenceDataService();
  static final _singleton = AdminRepository();
  static AdminRepository get instance => _singleton;

  final APIManager _apiManager;
  final ReferenceDataService _referenceDataService;

  Future<String?> saveAccessRights(
    Reference requestType,
    Reference role,
    AccessRight accessRight,
    bool isUpdate,
  ) async {
    AppResponse? response;
    try {
      if (isUpdate) {
        accessRight.subType = ServerConstants.accessRightUpdate;
        accessRight.role = role.reference1;
        accessRight.requestType = requestType.reference4;
        accessRight.subType = requestType.reference1;
      } else {
        accessRight.subType = ServerConstants.accessRightSave;
        accessRight.role = role.reference1;
        accessRight.requestType = requestType.reference4;
        accessRight.subType = requestType.reference1;
      }

      final Map data = BaseRequest.baseRequest(accessRight.toJson());
      logger.f("UpdateData => ${json.encode(data)}");

      response = await _apiManager.post(APIEndpoints.saveRoleRightMap, data);
      logger.f(response.body.toString());
      if (response.status == ResponseStatus.success) {
        response.message =
            response.body["baseResponse"]["status"]["statusDescription"];
      } else {
        throw response.message;
      }
    } catch (e) {
      rethrow;
    }

    return response.message;
  }

  Future<AccessRight?> getAccessRights(
    Reference role,
    Reference requestType,
  ) async {
    AccessRight? accessRight;
    try {
      final Map data = BaseRequest.baseRequest({
        "role": role.reference1,
        "requestType": requestType.reference4,
        "subType": requestType.reference1,
      });

      final AppResponse response =
          await _apiManager.post(APIEndpoints.getRoleRightMap, data);
      if (response.status == ResponseStatus.success) {
        accessRight = AccessRight.fromJson(response.body["responseData"]);
        logger.f("GetData => ${json.encode(accessRight)}");
      }
      if (response.status == ResponseStatus.error) {
        throw response.message;
      }
    } catch (e) {
      rethrow;
    }

    return accessRight;
  }

  Future<List<ReferenceType>> getReferenceTypes() async {
    final Map data = BaseRequest.baseRequest(null);

    final List<ReferenceType> referenceTypes = [];
    final AppResponse response =
        await _apiManager.post(APIEndpoints.configurableReferenceData, data);
    if (response.status == ResponseStatus.success) {
      for (final item
          in (response.body["responseData"]["referenceData"] as List)) {
        referenceTypes.add(ReferenceType.fromJson(item));
      }
      return referenceTypes;
    } else {
      throw response.message;
    }
  }

  Future<List<Reference>> getReferenceData(ReferenceType reference) async {
    final Map data = BaseRequest.baseRequest({
      "referenceDataName": [reference.name],
      "isAdmin": true,
    });

    final List<Reference> references = [];
    final AppResponse response =
        await APIManager.instance.post(APIEndpoints.getReferenceData, data);
    if (response.status == ResponseStatus.success) {
      final responseData =
          response.body["responseData"].first["referenceDataList"];
      for (final item in (responseData as List)) {
        references.add(Reference.fromJson(item));
      }
      return references;
    } else {
      throw response.message;
    }
  }

  Future<String?> saveReferenceDataInformation(
    int? referenceDataTypeID, //referenceDataTypeId
    Reference? reference,
  ) async {
    reference?.typeId = referenceDataTypeID;
    final Map data = BaseRequest.baseRequest(reference?.toJson());
    log(json.encode(data).toString());

    final AppResponse response = await APIManager.instance
        .post(APIEndpoints.saveConfigurableReferenceData, data);
    if (response.status == ResponseStatus.success) {
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<List<User>> getUserList() async {
    final List<User> users = <User>[];

    try {
      final Map<String, List<Reference>> referenceData =
          await _referenceDataService.getReferenceData([
        ReferenceDataKeys.roleType,
      ]);

      final List<Reference> roleTypes =
          referenceData[ReferenceDataKeys.roleType] ?? <Reference>[];

      final Map<String, dynamic> data = BaseRequest.baseRequest({
        "roles": <String>[],
      });

      final AppResponse response =
          await _apiManager.post(APIEndpoints.getUsersList, data);

      final responseData = response.body["responseData"];
      if (responseData == null) return users;

      final List<Role> roleGroups = (responseData as List)
          .map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList();

      for (final Role group in roleGroups) {
        final String currentRoleCode = group.name ?? "";
        final List<User> userDetails = (group.users ?? [])
            .map((userJson) => User.fromJson(userJson.toJson()))
            .toList();

        for (final User user in userDetails) {
          final List<String> rawRoleList = <String>[currentRoleCode];
          user.availableRoles = rawRoleList.map((String codeRaw) {
            final String code = codeRaw.trim();
            final Reference roleReference = roleTypes.firstWhere(
              (Reference r) => r.reference1?.trim() == code,
              orElse: Reference.new,
            );
            return Role(
              code: code,
              name: roleReference.reference2 ?? " ",
              group: roleReference.reference3,
            );
          }).toList();

          users.add(user);
        }
      }
      return users;
    } catch (e) {
      logger.e("Error in getUserList: $e");
      rethrow;
    }
  }

  Future<User> getUserDetailList(User? userListItem) async {
    final Map<String, List<Reference>> referenceData =
        await _referenceDataService.getReferenceData([
      ReferenceDataKeys.roleType,
    ]);
    final List<Reference> roleTypes =
        referenceData[ReferenceDataKeys.roleType] ?? [];

    final Map data = BaseRequest.baseRequest(
      {"userId": userListItem?.id, "userName": userListItem?.userName},
    );

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getAdminUserDetails, data);
    User user = User();

    try {
      if (response.status != ResponseStatus.success) return user;

      final responseData = response.body["responseData"];
      if (responseData == null) return user;

      final Map<String, dynamic> userData =
          Map<String, dynamic>.from(responseData);
      final List rawRoleList = userData.remove("roleList") ?? [];

      user = User.fromJson(userData);

      user.availableRoles = rawRoleList.map((roleCode) {
        roleCode = roleCode.trim();
        final Reference roleReference = roleTypes.firstWhere(
          (Reference role) => role.reference1?.trim() == roleCode,
          orElse: Reference.new,
        );
        return Role(
          code: roleCode,
          name: roleReference.reference2,
          group: roleReference.reference3,
        );
      }).toList();

      return user;
    } catch (e) {
      logger.i(e.toString());
      rethrow;
    }
  }

  Future<String?> saveUserDetailsList(
    User? userDetails,
  ) async {
    try {
      final Map data =
          BaseRequest.baseRequest(userDetails?.toSaveDetailsJson());
      logger.f(json.encode(data));
      final AppResponse response =
          await _apiManager.post(APIEndpoints.saveAdminUserDetails, data);
      if (response.status == ResponseStatus.success) {
        return response.message;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      logger.i(e.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUpdatedUserData() async {
    try {
      final Map data = BaseRequest.baseRequest({});
      logger.f(json.encode(data));
      final AppResponse response =
          await _apiManager.post(APIEndpoints.getLoggedUserDetails, data);
      if (response.status == ResponseStatus.success) {
        return response.body["responseData"];
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      logger.i(e.toString());
      rethrow;
    }
  }

  Future<List<FileAccess>> getFileAttachments(Reference? role) async {
    final Map data = BaseRequest.baseRequest({"role": role?.reference1});

    final List<FileAccess> fileAccesses = [];
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getFileAttachments, data);
    if (response.status == ResponseStatus.success) {
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      for (final file in (response.body["responseData"] as List)) {
        fileAccesses.add(FileAccess.fromJson(file));
      }
      return fileAccesses;
    } else {
      throw response.message;
    }
  }

  Future<String?> saveFileAttachments(
    List<FileAccess> fileAccesses,
    Reference? role,
  ) async {
    final List<FileAccess> updatedFileAccesses =
        fileAccesses.where((element) => element.isUpdated).toList();

    final Map data = BaseRequest.baseRequest({
      "role": role?.reference1,
      "accessRightList":
          updatedFileAccesses.map((element) => element.toJson()).toList(),
    });
    logger.f(json.encode(data));

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveFileAttachments, data);
    if (response.status == ResponseStatus.success) {
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      return response.message;
    } else {
      throw response.message;
    }
  }
}
