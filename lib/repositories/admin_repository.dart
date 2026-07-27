import "dart:convert";
import "dart:developer";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/models/admin/access_right.dart";
import "package:wcas_frontend/models/admin/file_access.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";

/// Repository responsible for handling admin-related operations.
///
/// Provides APIs and reference data services used across
/// admin-related features.
class AdminRepository {
  /// Creates an instance of [AdminRepository].
  ///
  /// Optionally accepts custom implementations of [APIManager]
  /// and [ReferenceDataService]. Defaults will be used if not provided.
  AdminRepository({
    APIManager? apiManager,
    ReferenceDataService? referenceDataService,
  })  : _apiManager = apiManager ?? APIManager(),
        _referenceDataService = referenceDataService ?? ReferenceDataService();

  /// Singleton instance of [AdminRepository].
  static final _singleton = AdminRepository();

  /// Provides access to the singleton instance.
  static AdminRepository get instance => _singleton;

  /// Handles API communication for admin operations.
  final APIManager _apiManager;

  /// Provides access to reference data services.
  final ReferenceDataService _referenceDataService;

  /// Saves or updates access rights for a given role and request type.
  ///
  /// Sends the [accessRight] data to the backend API after enriching it
  /// with the appropriate request type and role details.
  ///
  /// - [requestType] represents the selected request type.
  /// - [role] represents the selected role.
  /// - [accessRight] contains the access rights configuration.
  /// - [isUpdate] determines whether the operation is an update or a new save.
  ///
  /// Returns a [String] message from the API response on success.
  ///
  /// Throws an [ApiException] if the API call fails
  Future<String?> saveAccessRights(
    Reference requestType,
    Reference role,
    AccessRight accessRight, {
    required bool isUpdate,
  }) async {
    AppResponse? response;
    try {
      if (isUpdate) {
        accessRight
          ..subType = ServerConstants.accessRightUpdate
          ..role = role.reference1
          ..requestType = requestType.reference4
          ..subType = requestType.reference1;
      } else {
        accessRight
          ..subType = ServerConstants.accessRightSave
          ..role = role.reference1
          ..requestType = requestType.reference4
          ..subType = requestType.reference1;
      }

      final Map data = BaseRequest.baseRequest(accessRight.toJson());
      logger.f("UpdateData => ${json.encode(data)}");

      response = await _apiManager.post(APIEndpoints.saveRoleRightMap, data);
      logger.f(response.body.toString());
      if (response.status == ResponseStatus.success) {
        response.message =
            response.body["baseResponse"]["status"]["statusDescription"];
      } else {
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
    } on Object {
      rethrow;
    }

    return response.message;
  }

  /// Retrieves access rights for a given role and request type.
  ///
  /// Sends a request to the backend API using [role] and [requestType]
  /// to fetch the corresponding access rights configuration.
  ///
  /// - [role] represents the selected user role.
  /// - [requestType] represents the selected request type.
  ///
  /// Returns an [AccessRight] object if the API call is successful,
  /// otherwise returns `null`.
  ///
  /// Throws an [ApiException] if the API request fails.
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
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
    } on Object {
      rethrow;
    }

    return accessRight;
  }

  /// Fetches all reference types from the configurable reference data API.
  ///
  /// Sends a request to retrieve system-wide reference data and
  /// maps the response into a list of [ReferenceType] objects.
  ///
  /// Returns a list of [ReferenceType] on successful response.
  ///
  /// Throws an [ApiException] if the API request fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Fetches reference data for a given [ReferenceType].
  ///
  /// Sends a request to the backend API using the provided [reference]
  /// to retrieve associated reference data entries.
  ///
  /// - [reference] specifies the reference type for which data is required.
  ///
  /// Returns a list of [Reference] objects on successful response.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<List<Reference>> getReferenceData(ReferenceType reference) async {
    final Map data = BaseRequest.baseRequest({
      "referenceDataName": [reference.name],
      "isAdmin": true,
    });

    final List<Reference> references = [];
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getReferenceData, data);
    if (response.status == ResponseStatus.success) {
      final responseData =
          response.body["responseData"].first["referenceDataList"];
      for (final item in (responseData as List)) {
        references.add(Reference.fromJson(item));
      }
      return references;
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Saves or updates configurable reference data information.
  ///
  /// Associates the provided [reference] with the given
  /// [referenceDataTypeID] and sends it to the backend API.
  ///
  /// - [referenceDataTypeID] identifies the reference data type.
  /// - [reference] contains the reference data details to be saved.
  ///
  /// Returns a success message from the API response if the operation succeeds.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<String?> saveReferenceDataInformation(
    int? referenceDataTypeID, //referenceDataTypeId
    Reference? reference,
  ) async {
    reference?.typeId = referenceDataTypeID;
    final Map data = BaseRequest.baseRequest(reference?.toJson());
    log(json.encode(data));

    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveConfigurableReferenceData,
      data,
    );
    if (response.status == ResponseStatus.success) {
      return response.body["baseResponse"]["status"]["statusDescription"];
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Fetches the list of users along with their associated role information.
  ///
  /// Retrieves role reference data and user role groups from the backend,
  /// then maps users with their resolved role details.
  ///
  /// Returns a list of [User] objects enriched with available role information.
  ///
  /// Throws an exception if the API request or data processing fails.
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
      if (responseData == null) {
        return users;
      }

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
    } on Object catch (e) {
      logger.e("Error in getUserList: $e");
      rethrow;
    }
  }

  /// Fetches detailed information for a specific user.
  ///
  /// Sends a request to retrieve user details based on the provided
  /// [userListItem], and resolves the user’s role information using
  /// reference data.
  ///
  /// Returns a [User] object populated with detailed information
  /// and mapped available roles.
  ///
  /// Returns an empty [User] object if the API response is unsuccessful
  /// or contains no data.
  ///
  /// Throws an exception if the API request or processing fails.
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
    try {
      if (response.status != ResponseStatus.success) {
        return User();
      }

      final responseData = response.body["responseData"];
      if (responseData == null) {
        return User();
      }

      final Map<String, dynamic> userData =
          Map<String, dynamic>.from(responseData);
      final List rawRoleList = userData.remove("roleList") ?? [];

      return User.fromJson(userData)
        ..availableRoles = rawRoleList.map((roleCode) {
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
    } on Object catch (e) {
      logger.i(e.toString());
      rethrow;
    }
  }

  /// Saves or updates user details through the admin API.
  ///
  /// Sends the provided [userDetails] to the backend after
  /// converting it into the required request format.
  ///
  /// Returns a success message from the API response if the operation succeeds.
  ///
  /// Throws an [ApiException] if the API request fails.
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
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
    } on Object catch (e) {
      logger.i(e.toString());
      rethrow;
    }
  }

  /// Fetches the latest details of the currently logged-in user.
  ///
  /// Sends a request to retrieve updated user information from the backend
  /// and returns the response data as a key-value map.
  ///
  /// Returns a [Map<String, dynamic>] containing updated user data
  /// on successful response.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<Map<String, dynamic>> getUpdatedUserData() async {
    try {
      final Map data = BaseRequest.baseRequest({});
      logger.f(json.encode(data));
      final AppResponse response =
          await _apiManager.post(APIEndpoints.getLoggedUserDetails, data);
      if (response.status == ResponseStatus.success) {
        return response.body["responseData"];
      } else {
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
    } on Object catch (e) {
      logger.i(e.toString());
      rethrow;
    }
  }

  /// Fetches file attachment access details for a given role.
  ///
  /// Sends a request to the backend API using the provided [role]
  /// to retrieve the list of accessible file attachments.
  ///
  /// - [role] represents the role for which file access details are required.
  ///
  /// Returns a list of [FileAccess] objects on successful response.
  ///
  /// Throws an [ApiException] if the API request fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Saves updated file attachment access rights for a given role.
  ///
  /// Filters the provided [fileAccesses] to include only updated items,
  /// then sends them to the backend API along with the associated [role].
  ///
  /// - [fileAccesses] contains the list of file access configurations.
  /// - [role] represents the role for which access rights are being saved.
  ///
  /// Returns a success message from the API response if the operation succeeds.
  ///
  /// Throws an [ApiException] if the API request fails.
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
      return response.body["baseResponse"]["status"]["statusDescription"];
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }
}
