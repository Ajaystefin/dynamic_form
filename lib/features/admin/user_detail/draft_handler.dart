import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/user_detail/model.dart";
import "package:wcas_frontend/models/login/role.dart";

/// Draft handler for saving and restoring user detail changes.
class UserDetailsDraftHandler extends DraftHandler<UserDetailViewModel> {
  // --------------------------------------------------
  // Draft key (user scoped)
  // --------------------------------------------------

  /// Resolves the draft key for the selected user.
  String resolveDraftKey(UserDetailViewModel vm) {
    final id = vm.userDetails?.id ?? vm.selectUserListItem?.id;
    return id != null && id.isNotEmpty
        ? "${vm.draftFormKey}_$id"
        : vm.draftFormKey;
  }

  // --------------------------------------------------
  // BUILD DRAFT
  // --------------------------------------------------

  /// Builds the draft data from the current user detail view model.
  @override
  Map<String, dynamic> buildDraftData(UserDetailViewModel vm) {
    if (vm.formKey.currentState?.mounted ?? false) {
      vm.formKey.currentState?.save();
    }

    final user = vm.userDetails!;
    return {
      "user": {
        // identity
        "userId": user.id,
        "userDetailId": user.userDetailId,

        // strings
        "name": user.name,
        "userName": user.userName,
        "email": user.email,
        "designation": user.designation,
        "department": user.department,
        "createdBy": user.createdBy,
        "createdDate": user.createdDate,

        // lists
        "regions": user.regions ?? [],
        "segments": user.segments ?? [],
        "roleCodes": user.availableRoles?.map((r) => r.code).toList() ?? [],

        // flags
        "approveOnBehalfOf": user.approveOnBehalfOf,
        "approvalAccess": user.approvalAccess,
        "tranApprovalAccess": user.tranApprovalAccess,
        "accessToVipCust": user.accessToVipCust,
        "isIslamic": user.isIslamic,
        "isActive": user.active,
        "authenticated": user.authenticated,
      },
    };
  }

  // --------------------------------------------------
  // APPLY DRAFT
  // --------------------------------------------------

  /// Applies saved draft data to the current user detail view model.
  @override
  void applyDraft(
    UserDetailViewModel vm,
    Map<String, dynamic> data,
  ) {
    final userJson = data["user"] as Map<String, dynamic>?;
    if (userJson == null || vm.userDetails == null) {
      return;
    }

    final draftUserId = userJson["userId"];
    final currentUserId = vm.userDetails?.id;
    if (draftUserId != null && draftUserId != currentUserId) {
      return;
    }

    final user = vm.userDetails!;

    final roleCodes = (userJson["roleCodes"] as List?)?.cast<String>() ?? [];

    //  Restore core model
    user
      ..id = userJson["userId"]
      ..userDetailId = userJson["userDetailId"]
      ..name = userJson["name"]
      ..userName = userJson["userName"]
      ..email = userJson["email"]
      ..designation = userJson["designation"]
      ..department = userJson["department"]
      ..createdBy = userJson["createdBy"]
      ..createdDate = userJson["createdDate"]
      ..regions = (userJson["regions"] as List?)?.cast<String>() ?? []
      ..segments = (userJson["segments"] as List?)?.cast<String>() ?? []
      ..approveOnBehalfOf = userJson["approveOnBehalfOf"] ?? false
      ..approvalAccess = userJson["approvalAccess"] ?? false
      ..tranApprovalAccess = userJson["tranApprovalAccess"] ?? false
      ..accessToVipCust = userJson["accessToVipCust"] ?? false
      ..isIslamic = userJson["isIslamic"] ?? false
      ..active = userJson["isActive"] ?? false
      ..authenticated = userJson["authenticated"] ?? false
      ..availableRoles = roleCodes.map((c) => Role(code: c)).toList();

    // SINGLE hydration call
    vm
      ..hydrateRegionAndSegmentSelections()
      ..selectedIslamicRelationshipUserValue =
          vm.islamicRelationshipUserOptions.firstWhere(
        (ref) =>
            (ref.name == "requestInformation.requestInformation.yes".tr() &&
                (user.isIslamic ?? false)) ||
            (ref.name == "requestInformation.requestInformation.no".tr() &&
                user.isIslamic == false),
        orElse: () => vm.islamicRelationshipUserOptions.first,
      )
      ..emit(
        vm.state.copyWith(
          approveOnBehalfOf: user.approveOnBehalfOf,
          approvalAccess: user.approvalAccess,
          tranApprovalAccess: user.tranApprovalAccess,
          accessToVipCust: user.accessToVipCust,
          loaderStatus: LoadingStatus.loaded,
        ),
      );

    logger.i("UserDetails draft restored for user=$draftUserId");
  }
}
