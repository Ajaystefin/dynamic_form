import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";

// ignore: avoid_relative_lib_imports — intentional same-feature import
import "package:wcas_frontend/features/request/profitability_account_conduct/share_of_wallet/model.dart";
// Autosave implementation by extended team

/// Draft handler for the Business Volume screen.
/// [ShareOfWalletViewModel] stays focused on business logic only.
class ShareOfWalletDraftHandler extends DraftHandler<ShareOfWalletViewModel> {
  /// Builds draft data for share of wallet.
  @override
  Map<String, dynamic> buildDraftData(ShareOfWalletViewModel vm) {
    // Flush onSaved callbacks — required for screens using onSaved in
    // FormFields.
    vm.formKey.currentState?.save();

    return <String, dynamic>{
      "comments": vm.rmComments,
    };
  }

  /// Applies draft data to share of wallet.
  @override
  void applyDraft(ShareOfWalletViewModel vm, Map<String, dynamic> data) {
    vm.rmComments = data["comments"] ?? vm.rmComments;
  }
}
