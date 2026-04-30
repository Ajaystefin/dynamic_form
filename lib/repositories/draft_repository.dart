import "dart:convert";

import "package:flutter/foundation.dart" show kIsWeb;
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/services/draft/browser_unload_service.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";

/// Repository for autosave draft operations.
///
/// Handles saving, retrieving, and deleting per-screen draft data from the
/// backend.
/// Uses the same singleton + APIManager pattern as other repositories.
class DraftRepository {
  DraftRepository({APIManager? apiManager})
      : _apiManager = apiManager ?? APIManager();
  static DraftRepository _singleton = DraftRepository();
  static DraftRepository get instance => _singleton;

  static void overrideInstance(DraftRepository newInstance) {
    _singleton = newInstance;
  }

  final APIManager _apiManager;

  /// Fetches the draft for the current user and application for a specific
  /// screen.
  ///
  /// Returns a [Map] containing at minimum:
  /// - `moduleKey` ([String]) — the module identifier
  /// - `formKey` ([String]) — the screen route identifier
  /// - `payload` ([Map<String, dynamic>]) — the saved form payload, decoded
  /// from JSON string
  ///
  /// Throws on API error. Returns null if no draft exists.
  Future<Map<String, dynamic>?> getDraft({
    required String module,
    required String screen,
  }) async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "module": module,
      "screen": screen,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getDraft, payload);

    if (response.status == ResponseStatus.error) {
      throw response.message;
    }

    final dynamic draftObj = response.body["responseData"]?["autoSaveList"];

    if (draftObj is! Map) {
      return null;
    }

    // payload arrives as a JSON string — decode it back to a Map
    final Map<String, dynamic> entry = draftObj as Map<String, dynamic>;
    final dynamic rawPayload = entry["payload"];
    Map<String, dynamic> decodedPayload = <String, dynamic>{};

    if (rawPayload is String && rawPayload.isNotEmpty) {
      try {
        decodedPayload = json.decode(rawPayload) as Map<String, dynamic>;
      } catch (_) {}
    }

    return <String, dynamic>{
      ...entry,
      "payload": decodedPayload, // replace string with decoded map
    };
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
      "appRefNo": Globals.request?.applicationRefNo,
      "module": module,
      "screen": screen,
      "draftJson": json.encode(draftJson),
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
  //
  // ─── Keepalive save (browser close / refresh) ────────────────────────────

  /// Saves the draft via `fetch` with `keepalive: true` — used exclusively
  /// for browser-close, tab-close, page-refresh, and tab-switch scenarios
  /// where the page is being torn down.
  ///
  /// Unlike `sendBeacon`, `fetch + keepalive` supports custom HTTP headers
  /// (`Authorization`, `sessionID`), so the request is fully authenticated.
  ///
  /// The browser (Chromium on Chrome & Edge) guarantees delivery of `keepalive`
  /// requests even after the page lifetime ends.
  ///
  /// Falls back to a regular async [saveDraft] if the keepalive call fails
  /// (e.g. on non-web platforms or if the browser rejects the request).
  ///
  /// This is a no-op on non-web platforms.
  Future<void> saveDraftBeacon({
    required String module,
    required String screen,
    required Map<String, dynamic> draftJson,
  }) async {
    // Only applicable on Flutter Web.
    if (!kIsWeb) return;

    try {
      // Retrieve the auth token to pass as a proper Authorization header.
      final LocalStorageService storage = LocalStorageService();
      final String? token = await storage.get<String>(
        LocalStorageBoxes.user,
        LocalStorageKeys.authToken,
      );

      // Build the standard request body (no token embedding needed).
      final Map<String, dynamic> payload = BaseRequest.baseRequest({
        "appRefNo": Globals.request?.applicationRefNo,
        "module": module,
        "screen": screen,
        "draftJson": json.encode(draftJson),
      });

      final String url = "${EnvConfig.baseUrl}${APIEndpoints.saveDraft}";
      final String body = json.encode(payload);

      // Build the same headers the AuthInterceptor would normally add.
      final Map<String, String> headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
        "sessionID": Globals.sessionID,
      };

      final bool sent = BrowserUnloadService.tryFetchWithKeepalive(
        url: url,
        body: body,
        headers: headers,
      );

      if (!sent) {
        // Keepalive fetch rejected (e.g. payload too large). Fall back to
        // the regular async save, which works as long as the page is still
        // alive.
        await saveDraft(
          module: module,
          screen: screen,
          draftJson: draftJson,
        );
      }
    } catch (_) {
      // Silently swallow — the page may already be tearing down.
    }
  }

  Future<void> deleteDraft({
    required String module,
    required String screen,
  }) async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "module": module,
      "screen": screen,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.deleteDraft, payload);

    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
  }
}
