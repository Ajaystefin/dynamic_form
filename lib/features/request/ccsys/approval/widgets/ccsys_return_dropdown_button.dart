import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/features/request/ccsys/approval/model.dart";
import "package:wcas_frontend/features/request/ccsys/approval/widgets/ccsys_custom_dropdown_btn.dart";

/// Displays a CCSYS return user dropdown button and handles selected user details.
class CcsysReturnDropdownButton extends StatelessWidget {
  /// Creates the CCSYS return dropdown button widget.
  const CcsysReturnDropdownButton({
    required this.viewModel,
    required this.label,
    super.key,
  });

  /// View model used to provide return users and store selected return user details.
  final CcsysApprovalViewModel viewModel;

  /// Translation key used as the dropdown label.
  final String label;

  @override
  Widget build(BuildContext context) {
    return CustomDropdownButton(
      label: label.tr(),
      options: viewModel.userListReturn,
      // selection callback (keep yours)

      callBack: (selectedUserId) {
        final selected = viewModel.userListReturn.firstWhere(
          (o) => (o.value?.toString() ?? "") == selectedUserId,
          orElse: () => CustomDropdownItem(value: null),
        );

        final userId = selected.value?.toString() ?? selectedUserId;
        final userName = selected.label ?? "";

        logger.i("Selected User → id: $userId, name: $userName");
        viewModel.selectedReturnUserId = userId;
        viewModel.selectedReturnUserName = userName;
      },

      // role from the *selected item*
      callBackWithHeader: (selectedUserId, headerName, roleCode) {
        final CustomDropdownItem selected = viewModel.userListReturn.firstWhere(
          (o) =>
              !o.isHeader &&
              o.value?.toString() == selectedUserId &&
              (o.headerName == headerName || o.title == headerName),
          orElse: () => CustomDropdownItem(value: null),
        );

        viewModel.selectedReturnUserBpmRole =
            selected.headerName ?? (headerName ?? "");
        logger.i(
          "Selected BPM Role → ${viewModel.selectedReturnUserBpmRole}",
        );

        //  viewModel.selectedUserBpmRoleCode = roleCode ?? '';
        // logger.i('Selected User → rolecode:
        // ${viewModel.selectedUserBpmRoleCode}');
      },

      // <-- The button action is now stable and independent of $3
      onButtonPressed: (!viewModel.canEdit)
          ? null
          : () async {
              await viewModel.onSavePress(context, "return");
            },
    );
  }
}
