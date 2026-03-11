import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/draft/draft_handler_base.dart';
import 'package:wcas_frontend/repositories/draft_repository.dart';

/// Mixin that adds draft autosave and load capability to any screen ViewModel.
///
/// ## To adopt autosave on a new screen:
///
/// 1. Add `with DraftMixin<YourViewModel>` to the ViewModel class.
/// 2. Override [draftModuleKey] — return the module constant from [DraftModuleKeys].
/// 3. Override [draftFormKey] — return the screen's route string from `Routes`.
/// 4. Override [draftHandler] — return an instance of the screen's [DraftHandler].
/// 5. In `init()`: call [registerDraftCallback] then [loadDraftIfAvailable].
/// 6. After a successful explicit save: call [deleteDraft] (fire-and-forget).
/// 7. In `dispose()` / `close()`: call [unregisterDraftCallback].
mixin DraftMixin<T> {
  /// Module key — top-level category (e.g. `DraftModuleKeys.profitabilityAndAccountConduct`).
  String get draftModuleKey;

  /// Form key — screen-level identifier (typically the screen's route string).
  String get draftFormKey;

  /// The screen-specific handler that owns [buildDraftData] and [applyDraft].
  DraftHandler<T> get draftHandler;

  /// Saves the current form state as a draft to the backend.
  ///
  /// Called fire-and-forget (not awaited) by [Globals.onAutoSave].
  /// Errors are silently swallowed.
  Future<void> saveDraft() async {
    try {
      await DraftRepository.instance.saveDraft(
        module: draftModuleKey,
        screen: draftFormKey,
        draftJson: draftHandler.buildDraftData(this as T),
      );
    } catch (_) {}
  }

  /// Deletes the backend draft after the screen is explicitly saved by the user.
  ///
  /// Call this inside your save method after a successful API response.
  /// Errors are silently swallowed.
  Future<void> deleteDraft() async {
    try {
      await DraftRepository.instance.deleteDraft(
        module: draftModuleKey,
        screen: draftFormKey,
      );
    } catch (_) {}
  }

  /// Finds this screen's draft in [Globals.drafts] and applies it via [draftHandler].
  ///
  /// Call this from `init()` after the screen's data has been loaded from the API,
  /// so the draft can correctly override the live values.
  /// Does nothing if no draft exists for this screen.
  void loadDraftIfAvailable() {
    try {
      final Map<String, dynamic> match = Globals.drafts.firstWhere(
        (Map<String, dynamic> d) =>
            d['moduleKey'] == draftModuleKey && d['formKey'] == draftFormKey,
      );
      final Map<String, dynamic>? payload =
          match['payload'] as Map<String, dynamic>?;
      if (payload != null) {
        draftHandler.applyDraft(this as T, payload);
      }
    } catch (_) {}
  }

  /// Registers [saveDraft] as the global [Globals.onAutoSave] callback.
  ///
  /// Call this from `init()` so that navigation and logout
  /// trigger a save for this screen.
  void registerDraftCallback() {
    Globals.onAutoSave = saveDraft;
  }

  /// Clears the [Globals.onAutoSave] callback.
  ///
  /// Call this from `dispose()` / `close()` to prevent stale callbacks.
  void unregisterDraftCallback() {
    Globals.onAutoSave = null;
  }
}
