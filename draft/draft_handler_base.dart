/// Abstract base class for per-screen draft handlers.
///
/// Each screen that supports autosave should provide its own concrete
/// implementation of this class, living in a `draft_handler.dart` file
/// alongside the screen's `model.dart`.
///
/// [T] is the ViewModel type — giving the handler direct, typed access
/// to the ViewModel's fields without exposing internals through a generic map.
///
/// ## Usage
/// ```dart
/// class MyScreenDraftHandler extends DraftHandler<MyScreenViewModel> {
///   @override
///   Map<String, dynamic> buildDraftData(MyScreenViewModel vm) {
///     return {'field': vm.field};
///   }
///
///   @override
///   void applyDraft(MyScreenViewModel vm, Map<String, dynamic> data) {
///     vm.field = data['field'] as String?;
///   }
/// }
/// ```
abstract class DraftHandler<T> {
  /// Serialises the current ViewModel state into a JSON-serialisable map.
  ///
  /// If the screen uses `onSaved` callbacks on form fields,
  /// call `vm.formKey.currentState?.save()` at the top of this method
  /// to flush field values into the model before reading them.
  Map<String, dynamic> buildDraftData(T viewModel);

  /// Restores previously saved draft data into the ViewModel's fields.
  ///
  /// After this runs, the ViewModel's data should reflect the same values
  /// that were present when the draft was last saved.
  void applyDraft(T viewModel, Map<String, dynamic> data);
}
