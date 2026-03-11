import 'dart:convert';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/core/services/api_service/base_request.dart';

/// Repository for autosave draft operations.
///
/// Handles saving, retrieving, and deleting per-screen draft data from the backend.
/// Uses the same singleton + APIManager pattern as other repositories.
class DraftRepository {
  static DraftRepository _singleton = DraftRepository();
  static DraftRepository get instance => _singleton;

  static void overrideInstance(DraftRepository newInstance) {
    _singleton = newInstance;
  }

  final APIManager _apiManager;

  DraftRepository({APIManager? apiManager})
      : _apiManager = apiManager ?? APIManager();

  /// Fetches all drafts for the current user and application.
  ///
  /// Returns a [List] of draft entries, each containing at minimum:
  /// - `moduleKey` ([String]) — the module identifier
  /// - `formKey` ([String]) — the screen route identifier
  /// - `payload` ([Map<String, dynamic>]) — the saved form payload, decoded from JSON string
  ///
  /// Throws on API error.
  Future<List<Map<String, dynamic>>> getDrafts() async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({
      'appRefNo': Globals.request?.applicationRefNo,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getDraft, payload);

    if (response.status == ResponseStatus.error) {
      throw response.message;
    }

    final dynamic autoSaveList = response.body['responseData']?['autoSaveList'];

    if (autoSaveList is! List) {
      return <Map<String, dynamic>>[];
    }

    // payload arrives as a JSON string — decode it back to a Map
    return autoSaveList
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> entry) {
      final dynamic rawPayload = entry['payload'];
      Map<String, dynamic> decodedPayload = <String, dynamic>{};

      if (rawPayload is String && rawPayload.isNotEmpty) {
        try {
          decodedPayload = json.decode(rawPayload) as Map<String, dynamic>;
        } catch (_) {}
      }

      return <String, dynamic>{
        ...entry,
        'payload': decodedPayload, // replace string with decoded map
      };
    }).toList();
  }

  /// Saves the draft payload for a specific screen.
  ///
  /// - [module] is the module identifier (from [DraftModuleKeys]).
  /// - [screen] is the screen identifier (usually the route string).
  /// - [draftJson] is the JSON-serialisable form payload.
  ///
  /// Throws on API error.
  Future<void> saveDraft({
    required String module,
    required String screen,
    required Map<String, dynamic> draftJson,
  }) async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({
      'appRefNo': Globals.request?.applicationRefNo,
      'module': module,
      'screen': screen,
      'draftJson': draftJson,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveDraft, payload);

    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
  }

  /// Deletes the draft for a specific screen.
  ///
  /// Called after a user explicitly saves a screen to clear the draft.
  ///
  /// Throws on API error.
  Future<void> deleteDraft({
    required String module,
    required String screen,
  }) async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({
      'appRefNo': Globals.request?.applicationRefNo,
      'module': module,
      'screen': screen,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.deleteDraft, payload);

    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
  }
}
