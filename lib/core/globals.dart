import "package:flutter/material.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/ccsys/approval/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";

/// Global application state and shared runtime data.
///
/// Stores application-wide objects, navigation keys, user information,
/// request context, reference data, and utility callbacks.
class Globals {
  /// Root scaffold messenger key used to display global snackbars.
  static final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Global navigator key.
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// Current device screen type.
  static DeviceScreenType? deviceScreenType;

  /// Currently logged-in user.
  static User? user;

  /// Current request data.
  static Request? request = Request();

  /// Current application route.
  static String currentRoute = "/";

  /// Previously visited route.
  static String previousRoute = "/";

  /// Current session identifier.
  static String sessionID = "";

  /// Currency options used by dynamic forms.
  static List<Option>? dynamicFormCurrencyCodes = [];

  /// Economic zone options used by dynamic forms.
  static List<Option>? dynamicFormEconomicZones = [];

  /// Currently selected customer for remarks.
  static Customer? selectedCustomer;

  /// Callback set by the currently active screen's ViewModel to save its draft.
  ///
  /// Invoked fire-and-forget (not awaited) before navigation and logout.
  static Future<void> Function()? onAutoSave;

  /// Synchronous-safe autosave callback used exclusively by browser unload
  /// events (tab/window close, page refresh).
  ///
  /// This callback is triggered by [`BrowserUnloadService`] and must use
  /// `navigator.sendBeacon` (via [`DraftRepository.saveDraftBeacon`]) so the
  /// HTTP request survives page termination.
  static void Function()? onAutoSaveSync;

  /// Request customer information.
  static Customer? requestCustomerInfo;

  /// Available request statuses.
  static List<Map<String?, int?>> requestStatus = [];

  /// Available user actions.
  static List<Map<String?, int?>> userAction = [];

  /// Available FOL type actions.
  static List<Map<String?, int?>> folTypeAction = [];

  /// Super-user role mappings.
  static List<Map<String, String>> superUserRoles = [];

  /// BPM role identifiers for super users.
  static List<Map<String, int>> superBpmRolesId = [];

  /// BPM role names for super users.
  static List<String> superBpmRoles = [];

  /// Role identifiers for super users.
  static List<Map<String, int>> superRolesId = [];

  /// Current application details.
  static ApplicationDetails? applicationDetails;

  /// Indicates whether the application is globally read-only.
  static bool isAllReadOnly = Utils.checkIfAppReadOnly();

  /// Indicates whether the current user initiated the request.
  static bool isInitiated = checkIsInitiated();

  /// References used for recommendation actions.
  static List<Reference> recommendReferences = [];

  /// References used for return actions.
  static List<Reference> returnReferences = [];

  /// References used for delegation actions.
  static List<Reference> delegationReferences = [];

  /// References used for approval actions.
  static List<Reference> approvalReferences = [];

  /// References for document stages.
  static List<Reference> documentStagesReferences = [];

  /// Available decline reasons.
  static List<String> reasonForDecline = [];

  /// References for worklist statuses.
  static List<Reference> worklistStatusReferences = [];

  /// References for limit release stages.
  static List<Reference> limitReleaseStagesReferences = [];

  /// Determines whether the current request was initiated by the current user.
  static bool checkIsInitiated() {
    if (applicationDetails == null) {
      return false;
    }
    logger
      ..i(
        "createdByRole : ${applicationDetails?.createdByRole == Globals.user!.currentRole?.bpmRole} ${applicationDetails?.createdByRole} ${Globals.user!.currentRole?.bpmRole}",
      )
      ..i(
        "createdBy : ${applicationDetails!.createdBy == Globals.user!.id}",
      );
    final bool isInitiatedById =
        (applicationDetails!.createdBy == Globals.user!.id);
    final bool isInitiatedByRole = (applicationDetails?.createdByRole ==
        Globals.user!.currentRole?.bpmRole);
    return isInitiatedById && isInitiatedByRole;
  }

  /// Checks whether the current application status matches any of the
  /// provided statuses.
  static bool checkCurrentStatus(List<RequestStatus> statusList) {
    if (applicationDetails == null && statusList.isEmpty) {
      logger.i("applicationDetails is null or statusList");
      return false;
    }
    if (requestStatus.isEmpty) {
      return false;
    }
    return statusList.any((status) {
      final String title = ServerConstants.requestStatusTitle[status] ?? "";

      final int id = requestStatus.firstWhereOrNull(
            (map) => map.containsKey(title),
          )?[title] ??
          0;
      return applicationDetails?.status == id;
    });
  }

  /// Checks whether the current application sub-status matches the
  /// specified type.
  static bool checkAppSubStatus(String type) {
    if (applicationDetails == null) {
      return false;
    }
    return applicationDetails?.subType == type;
  }

  /// Clears cached global state and request-related data.
  static void cleanGlobalCache() {
    request = Request();
    applicationDetails = null;
    selectedCustomer = null;
    onAutoSave = null;
    onAutoSaveSync = null;
    requestCustomerInfo = null;
  }
}
