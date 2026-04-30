import "dart:async";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_conduct/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_conduct/state.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/request/profitability/account_conduct.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

class AccountConductViewModel extends SafeCubit<AccountConductState>
    with DraftMixin<AccountConductViewModel> {
  AccountConductViewModel()
      : super(AccountConductState(loaderStatus: LoadingStatus.loading));

  late ProfitabilityRepository repository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  BuildContext? context;

  Request? request;
  AccountConductResponseData? accountConduct;

  bool isFIApplication = false;

  /// Editable copy for UI binding.
  List<AccountConductDto> customers = [];
  List<AccountConductDto> get customer => customers;

  /// Controllers registry (per row/field).
  /// Keys: 'passDueOrExcesses_0', 'chequeReturns_0', ...,
  /// 'transparencyDisclosureLevels_3'
  final Map<String, TextEditingController> _controllers = {};

  String get previousYearHeader =>
      accountConduct?.previousYearLabel ?? "Previous Year";
  String get currentYearHeader =>
      accountConduct?.currentYearLabel ?? "Current Year";

  PageMode pageMode = PageMode.na;
  bool get canEdit => (pageMode == PageMode.edit);

  bool isEdit =
      Globals.user?.currentRole?.rights?[RightConstants.accountConduct] ==
          AccessType.edit;
  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------
//Autosave implementation by extended team
  @override
  String get draftModuleKey => DraftModuleKeys.profitabilityAndAccountConduct;

  @override
  String get draftFormKey => Routes.accountConduct;

  @override
  DraftHandler<AccountConductViewModel> get draftHandler =>
      AccountConductDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes the `AccountConductViewModel` for the screen.
  ///
  /// Responsibilities:
  /// - Stores the provided [context] for later use.
  /// - Resolves the [ProfitabilityRepository] singleton instance.
  /// - Fetches account conduct data via `getAccountConductData()`.
  /// - Reads the global [Request] from [Globals.request].
  /// - Seeds the editable [customers] list from
  /// `accountConduct.accountConductDtoList`
  ///   (or an empty list when unavailable).
  /// - Determines whether the application is for the Financial Institution
  /// segment
  ///   using
  /// `Utils.checkBusinessSegment(BusinessSegment.financialInstitution)`.
  /// - Initializes all per-row/field text controllers from the current `customers` data.
  /// - Emits a state with `loaderStatus: LoadingStatus.loaded` on success.
  ///
  /// This method should be called once when the screen is created.

  Future<void> init(BuildContext context) async {
    this.context = context;
    pageMode = AuthRepository.getPageMode(RightConstants.accountConduct);
    repository = ProfitabilityRepository.instance;
    accountConduct = await repository.getAccountConductData();
    request = Globals.request;

    customers = List<AccountConductDto>.from(
      accountConduct?.accountConductDtoList ?? const <AccountConductDto>[],
    );

    isFIApplication =
        Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

    // Initialize controllers from current customers data
    _initControllersFromCustomers();
    if (isEdit) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///
  /// Initializes and seeds text controllers for each editable field
  /// across all customer rows.
  ///
  /// For every entry in the [customers] list, this method:
  /// - Iterates by index to maintain row-level identity.
  /// - Extracts the corresponding [AccountConductDto].
  /// - Creates (or reuses) a `TextEditingController` for each numeric field
  ///   using a deterministic key format: `<fieldName>_<rowIndex>`.
  /// - Populates the controller with the DTO’s current value converted to
  /// `double`.
  ///
  /// This ensures that UI fields correctly reflect existing backend data
  /// when the screen is first rendered or reloaded.
  ///
  /// Note:
  /// - Controllers are created only once per key via `_ensureController`.
  /// - This method should be called after [customers] is populated.

  void _initControllersFromCustomers() {
    for (int i = 0; i < customers.length; i++) {
      final dto = customers[i];
      _ensureController(
        "passDueOrExcesses_$i",
        dto.passDueOrExcesses!.toString(),
      );
      _ensureController("chequeReturns_$i", dto.chequeReturns!.toString());
      _ensureController("turnoverInAcc_$i", dto.turnoverInAcc!.toString());
      _ensureController("odHardcore_$i", dto.odHardcore!.toString());
      _ensureController(
        "unusualTransactions_$i",
        dto.unusualTransactions!.toString(),
      );
      _ensureController(
        "transparencyDisclosureLevels_$i",
        dto.transparencyDisclosureLevels!.toString(),
      );
    }
  }

  /// Ensures a `TextEditingController` exists for the given [key].
  ///
  /// - If absent, creates a controller with initial text from [value]
  /// (stringified),
  ///   or an empty string when `null`.
  /// - Returns the existing/created controller and caches it in `_controllers`.
  TextEditingController _ensureController(String key, String? value) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(
        text: value != "null" ? value?.toString() ?? "" : "",
      ),
    );
  }

  /// Returns a controller for a widget to bind to, by field and row index.
  ///
  /// - [fieldKey] is the logical field name (e.g., `'chequeReturns'`).
  /// - [index] is the row number.
  /// - Uses a deterministic key format: `'<fieldKey>_<index>'`.
  /// - Lazily creates a controller if missing (with empty initial value).
  ///
  /// This is the safe accessor for TextFields in the editable table.
  /// Expose controller for widgets
  TextEditingController controllerFor(
    String fieldKey,
    int index,
  ) {
    return _controllers["${fieldKey}_$index"] ??
        _ensureController("${fieldKey}_$index", null);
  }

  /// Replaces the customer DTO at [index] with [updated].
  ///
  /// - Performs bounds checking; no action if [index] is invalid.
  /// - Useful when directly updating the in-memory list without syncing
  /// controllers.
  void updateCustomer(int index, AccountConductDto updated) {
    if (index < 0 || index >= customers.length) return;
    customers[index] = updated;
  }

  /// Synchronizes values from text controllers back into [customers].
  ///
  /// - Iterates all rows, reading each controller’s text and parsing to
  /// `double?`.
  /// - Uses `copyWith` to create updated DTOs.
  /// - Must be called before building/persisting the final payload to ensure
  ///   the `customers` list is the source of truth.
  void syncCustomersFromControllers() {
    for (int i = 0; i < customers.length; i++) {
      final dto = customers[i];
      customers[i] = dto.copyWith(
        passDueOrExcesses: (_controllers["passDueOrExcesses_$i"]?.text),
        chequeReturns: (_controllers["chequeReturns_$i"]?.text),
        turnoverInAcc: (_controllers["turnoverInAcc_$i"]?.text),
        odHardcore: (_controllers["odHardcore_$i"]?.text),
        unusualTransactions: (_controllers["unusualTransactions_$i"]?.text),
        transparencyDisclosureLevels:
            (_controllers["transparencyDisclosureLevels_$i"]?.text),
      );
    }
  }

  /// Parses [s] into a `double`, returning `null` for empty or invalid input.
  ///
  /// - Trims whitespace.
  /// - Uses `double.tryParse` to avoid exceptions.
  double? parseDouble(String? s) {
    final t = s?.trim();
    if (t == null || t.isEmpty) return null;
    return double.tryParse(t);
  }

  /// Saves the Account Conduct data and optionally navigates forward.
  ///
  /// Workflow:
  /// 1) `formKey.currentState?.save()` to persist form changes.
  /// 2) `syncCustomersFromControllers()` to update the DTO list from
  /// controllers.
  /// 3) Creates or updates [accountConduct] with the latest [customers].
  /// 4) Logs the payload (if `toJson` is available).
  /// 5) Posts via `repository.postAccountConductData`.
  /// 6) Shows success toast; navigates to next route when [ifNavigate] is
  /// `true`.
  ///
  /// Error handling:
  /// - Logs error and stack trace.
  /// - Shows failure toast.
  /// - Emits `LoadingStatus.error`.
  Future<void> saveAccConductData({bool ifNavigate = false}) async {
    try {
      formKey.currentState?.save();

      syncCustomersFromControllers();

      if (accountConduct == null) {
        accountConduct = AccountConductResponseData(
          previousYearLable: previousYearHeader,
          currentYearLable: currentYearHeader,
          accountConductDtoList: customers,
        );
      } else {
        accountConduct = accountConduct!.copyWith(
          accountConductDtoList: customers,
        );
      }

      try {
        logger.d("Posting AccountConduct payload: ${accountConduct!.toJson()}");
      } catch (_) {}

      final result = await repository.postAccountConductData(
        accountConduct!,
      );
      unawaited(
        deleteDraft(),
      ); // fire-and-forget: remove backend draft now that data is saved,
      AlertManager().showSuccessToast(result.toString());

      if (ifNavigate) {
        LayoutViewModel().goToNextRoute();
      }
    } catch (e, st) {
      logger.e("saveAccConductData failed: $e", stackTrace: st);
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Re-seed (update) existing controllers from the current [customers] list
  /// without disposing them. Creates missing controllers if any.
  /// Re-seed (update) existing controllers from the current [customers] list
  /// without disposing them. Creates missing controllers if any.
  void reseedControllersFromCustomers() {
    for (int i = 0; i < customers.length; i++) {
      final dto = customers[i];

      _setControllerText("passDueOrExcesses_$i", dto.passDueOrExcesses);
      _setControllerText("chequeReturns_$i", dto.chequeReturns);
      _setControllerText("turnoverInAcc_$i", dto.turnoverInAcc);
      _setControllerText("odHardcore_$i", dto.odHardcore);
      _setControllerText("unusualTransactions_$i", dto.unusualTransactions);
      _setControllerText(
        "transparencyDisclosureLevels_$i",
        dto.transparencyDisclosureLevels,
      );
    }
  }

  /// Ensures controller exists and updates its text only if needed.
  void _setControllerText(String key, String? value) {
    final controller = _controllers[key] ?? _ensureController(key, value ?? "");
    final newText = (value != "null") ? (value ?? "") : "";
    if (controller.text != newText) {
      controller.text = newText; // updates field immediately, no rebuild needed
    }
  }

  /// Disposes all cached text controllers and clears the registry.
  ///
  /// Call this from the screen’s `dispose()` to prevent memory leaks.
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
  }
}
