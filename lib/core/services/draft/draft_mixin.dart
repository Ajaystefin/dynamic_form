import "dart:convert";
import "package:crypto/crypto.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/browser_unload_service.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";

/// Mixin that adds draft autosave and load capability to any screen ViewModel.
///
/// ## To adopt autosave on a new screen:
///
/// 1. Add `with DraftMixin<YourViewModel>` to the ViewModel class.
/// 2. Override [draftModuleKey] — return the module constant from
/// [`DraftModuleKeys`].
/// 3. Override [draftFormKey] — return the screen's route string from `Routes`.
/// 4. Override [draftHandler] — return an instance of the screen's
/// [DraftHandler].
/// 5. In `init()`: call [registerDraftCallback] then [loadDraftIfAvailable].
/// 6. After a successful explicit save: call [deleteDraft] (fire-and-forget).
/// 7. In `dispose()` / `close()`: call [unregisterDraftCallback].
mixin DraftMixin<T> {
  /// Module key — top-level category (e.g.
  /// `DraftModuleKeys.profitabilityAndAccountConduct`).
  String get draftModuleKey;

  /// Form key — screen-level identifier (typically the screen's route string).
  String get draftFormKey;

  /// The screen-specific handler that owns `buildDraftData` and `applyDraft`.
  DraftHandler<T> get draftHandler;

  /// Stores the MD5 hash of the screen's JSON state when it was first loaded.
  String? _initialDraftHash;

  /// The [saveDraft] tear-off that was passed to [Globals.onAutoSave] during
  /// [registerDraftCallback]. Stored so [unregisterDraftCallback] can verify
  /// ownership before clearing the global slot.
  Future<void> Function()? _registeredAutoSave;

  /// The [saveDraftSync] tear-off that was passed to [Globals.onAutoSaveSync]
  /// during [registerDraftCallback]. Same ownership-check purpose.
  void Function()? _registeredAutoSaveSync;

  /// Helper to generate a hash from the current JSON state.
  String _generateHash(Map<String, dynamic> data) {
    return md5.convert(utf8.encode(jsonEncode(data))).toString();
  }

  /// Takes a snapshot of the current state.
  /// This is called automatically at the end of [loadDraftIfAvailable].
  void captureInitialDraftState() {
    try {
      final data = draftHandler.buildDraftData(this as T);
      _initialDraftHash = _generateHash(data);
    } on Object catch (_) {}
  }

  /// Saves the current form state as a draft to the backend.
  ///
  /// Called fire-and-forget (not awaited) by [Globals.onAutoSave].
  /// Errors are silently swallowed.
  Future<void> saveDraft() async {
    try {
      final currentData = draftHandler.buildDraftData(this as T);
      final currentHash = _generateHash(currentData);

      // If the state hasn't changed since init, do nothing!
      if (currentHash == _initialDraftHash) {
        return;
      }

      await DraftRepository.instance.saveDraft(
        module: draftModuleKey,
        screen: draftFormKey,
        draftJson: currentData,
      );

      // Optionally update the hash so subsequent identical saves are blocked
      _initialDraftHash = currentHash;
    } on Object catch (_) {}
  }

  /// Deletes the backend draft after the screen is explicitly saved by the
  /// user.
  ///
  /// Call this inside your save method after a successful API response.
  /// Errors are silently swallowed.
  Future<void> deleteDraft() async {
    try {
      await DraftRepository.instance.deleteDraft(
        module: draftModuleKey,
        screen: draftFormKey,
      );
      // Reset the baseline hash after explicitly saving,
      // so we don't immediately auto-save the same data as a draft when
      // navigating away.
      captureInitialDraftState();
    } on Object catch (_) {}
  }

  /// Finds this screen's draft by calling the backend API and applies it via
  /// [draftHandler].
  ///
  /// Call this from `init()` after the screen's data has been loaded from the
  /// API,
  /// so the draft can correctly override the live values.
  /// Does nothing if no draft exists for this screen.
  Future<void> loadDraftIfAvailable() async {
    try {
      final Map<String, dynamic>? match =
          await DraftRepository.instance.getDraft(
        module: draftModuleKey,
        screen: draftFormKey,
      );

      if (match != null) {
        final Map<String, dynamic>? payload =
            match["payload"] as Map<String, dynamic>?;
        if (payload != null) {
          draftHandler.applyDraft(this as T, payload);
        }
      }
    } on Object catch (_) {}

    // Capture the baseline state after attempting to load the draft.
    // This ensures any live data fetched beforehand, plus any draft overrides,
    // are part of the baseline hash.
    captureInitialDraftState();
  }

  /// Registers [saveDraft] as the global [Globals.onAutoSave] callback and
  /// [saveDraftSync] as [Globals.onAutoSaveSync], then starts the
  /// [BrowserUnloadService] so browser tab/window close and page refresh events
  /// also trigger an autosave.
  ///
  /// Call this from `init()` so that navigation, logout, and browser unload
  /// all trigger a save for this screen.
  void registerDraftCallback() {
    // Capture the tear-offs once so we can identity-check them in unregister.
    _registeredAutoSave = saveDraft;
    _registeredAutoSaveSync = saveDraftSync;

    Globals.onAutoSave = _registeredAutoSave;
    Globals.onAutoSaveSync = _registeredAutoSaveSync;
    BrowserUnloadService.instance.register();
  }

  /// Clears the [Globals.onAutoSave] and [Globals.onAutoSaveSync] callbacks
  /// and stops the [BrowserUnloadService] listener.
  ///
  /// Call this from `dispose()` / `close()` to prevent stale callbacks.
  void unregisterDraftCallback() {
    // Only clear the global slot if WE are still the registered owner.
    // Another ViewModel may have taken ownership since we registered;
    // blindly nulling the slot would silently kill their autosave.
    if (Globals.onAutoSave == _registeredAutoSave) {
      Globals.onAutoSave = null;
    }
    if (Globals.onAutoSaveSync == _registeredAutoSaveSync) {
      Globals.onAutoSaveSync = null;
    }

    // Always unregister the browser listener — it is tied to this instance.
    BrowserUnloadService.instance.unregister();

    // Release the stored references.
    _registeredAutoSave = null;
    _registeredAutoSaveSync = null;
  }

  /// Saves the draft via `navigator.sendBeacon` — used exclusively by
  /// [BrowserUnloadService] when the browser page is being torn down.
  ///
  /// Falls back to the regular async [saveDraft] if sendBeacon is unavailable
  /// or rejected (e.g. on non-web platforms or when the payload is too large).
  void saveDraftSync() {
    try {
      final Map<String, dynamic> currentData =
          draftHandler.buildDraftData(this as T);
      final String currentHash = _generateHash(currentData);

      // Skip if the state hasn't changed since the last baseline.
      if (currentHash == _initialDraftHash) {
        return;
      }

      // saveDraftBeacon is fire-and-forget by design (no await).
      DraftRepository.instance.saveDraftBeacon(
        module: draftModuleKey,
        screen: draftFormKey,
        draftJson: currentData,
      );
    } on Object catch (_) {}
  }
}
