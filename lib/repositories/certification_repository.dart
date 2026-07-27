import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/certification_data.dart";
import "package:wcas_frontend/models/request/esg_certification.dart";

/// Repository responsible for handling certification-related operations.
/// 
/// Provides methods to interact with certification APIs and maintains
/// a singleton instance for shared usage across the application.
class CertificationRepository {
  CertificationRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  /// Internal singleton instance of [CertificationRepository].
  static final _singleton = CertificationRepository();

  /// Returns the singleton instance of [CertificationRepository].
  static CertificationRepository get instance => _singleton;

  /// API manager used to perform network requests.
  final APIManager _apiManager;

  /// Retrieves ESG certification details for the current application.
  /// 
  /// Sends the application reference number to the backend and parses
  /// the response into an [EsgCertification] object.
  /// Returns the certification details on success.
  /// Throws [ApiException] if the API call fails.
  Future<EsgCertification> getEsgCertificationDetails() async {
    final payload = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
    });

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getEsgCertificateDetails,
      payload,
    );

    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }

    final data = response.body["responseData"] as Map<String, dynamic>;
    return EsgCertification.fromJson(data);
  }

  /// Saves ESG certification details for the current application.
  /// 
  /// Enriches the certification payload with audit fields, submits it to the backend,
  /// and parses the response into an updated [EsgCertification] object.
  /// Returns the saved certification details on success.
  /// Throws [ApiException] if the API call fails.
  Future<EsgCertification> postEsgCertificationDetails(
    EsgCertification certification,
  ) async {
    final body = certification.toJson();

    if (body["esRiskRating"] is List) {
      body["esRiskRating"] = (body["esRiskRating"] as List).map((e) {
        final data = Map<String, dynamic>.from(e);
        data["createdBy"] = certification.createdBy;
        data["createdDate"] = certification.createdDate?.toIso8601String();
        data["updatedBy"] = certification.updatedBy;
        data["updatedDate"] = certification.updatedDate?.toIso8601String();

        return data;
      }).toList();
    }

    final payload = BaseRequest.baseRequest(body);

    try {
      final response = await _apiManager.post(
        APIEndpoints.saveEsgCertificationDetails,
        payload,
      );

      if (response.status == ResponseStatus.error) {
        //throw Exception(response.message);
        throw ApiException(response.message);
      }

      final data = response.body["responseData"] as Map<String, dynamic>;
      return EsgCertification.fromJson(data);
    } catch (e, stack) {
      logger.i(stack.toString());
      rethrow;
    }
  }

  /// Retrieves and processes other certification details for the current application.
  /// 
  /// Fetches certification data from the backend, groups entries by category,
  /// and selects the most recent record for each category based on the highest
  /// application certification ID. Maps the filtered results into a list of
  /// [CertificationData] using provided reference data.
  /// Returns the processed list of certifications on success.
  /// Throws [ApiException] if the API call fails.
  Future<List<CertificationData>> getOtherCertificationDetails(
    List<Reference> certificateTypes,
    List<Reference> yesNoNaOptions,
  ) async {
    final Map<String, dynamic> requestPayload = BaseRequest.baseRequest(
      {"appRefNo": Globals.request!.applicationRefNo},
    );

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getCertificateDetails,
      requestPayload,
    );

    if (response.status == ResponseStatus.error) {
     // throw Exception(response.message);
      throw ApiException(response.message);
    }

    final List<dynamic> rawList =
        response.body["responseData"] as List<dynamic>;

    // Group by certificationCategory and pick the latest (highest
    // appCertificationId)
    final Map<int, Map<String, dynamic>> latestByCategory = {};

    for (final item in rawList) {
      final Map<String, dynamic> json = item as Map<String, dynamic>;
      final int? categoryId = json["certificationCategory"];
      final int? appCertId = json["appCertificationId"];

      if (categoryId != null && appCertId != null) {
        if (!latestByCategory.containsKey(categoryId) ||
            appCertId >
                (latestByCategory[categoryId]!["appCertificationId"] as int)) {
          latestByCategory[categoryId] = json;
        }
      }
    }

    final List<CertificationData> filteredCertifications = [];

    for (final json in latestByCategory.values) {
      final int? categoryId = json["certificationCategory"];
      final int? appCertId = json["appCertificationId"];
      final String? optionStr = json["option"];
      final String? remarks = json["remarks"];

      final Reference category = certificateTypes.firstWhere(
        (ref) => ref.id == categoryId,
        orElse: () => Reference(id: categoryId),
      );

      final Reference selectedOption = yesNoNaOptions.firstWhere(
        (ref) => ref.name?.toUpperCase() == optionStr?.toUpperCase(),
        orElse: () => Reference(id: -1, name: optionStr),
      );

      if (certificateTypes.any((ref) => ref.id == categoryId)) {
        filteredCertifications.add(
          CertificationData(
            appCertificationId: appCertId,
            certificateInformation: category,
            selectedOption: selectedOption,
            remarks: remarks ?? "",
          ),
        );
      }
    }

    return filteredCertifications;
  }

  /// Saves other certification details for the current application.
  /// 
  /// Constructs the request payload using the provided list of [CertificationData],
  /// including category, selected option, and remarks, and submits it to the backend.
  /// Throws [ApiException] if the API call fails.
  Future<void> postOtherCertificationDetails(
    List<CertificationData> certifications,
  ) async {
    final Map<String, dynamic> requestPayload = BaseRequest.baseRequest({
      "appRefNo": Globals.request!.applicationRefNo,
      "role": Globals.user?.currentRole?.code,
      "certificateDetails": certifications
          .map(
            (cert) => {
              "certificationCategory": cert.certificateInformation.id,
              "option": cert.selectedOption?.name!.toUpperCase(),
              "remarks": cert.remarks,
            },
          )
          .toList(),
    });

    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveCertificateDetails,
      requestPayload,
    );

    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }
}
