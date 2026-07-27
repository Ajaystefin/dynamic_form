import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/features/request/ccsys/approval/model.dart";
import "package:wcas_frontend/features/request/ccsys/approval/widgets/ccsys_custom_dropdown_btn.dart";

/// Displays a CCSYS user dropdown button and handles selected user details.
class CcsysDropdownButton extends StatelessWidget {
  /// Creates the CCSYS dropdown button widget.
  const CcsysDropdownButton({
    required this.viewModel,
    required this.label,
    super.key,
  });

  /// View model used to provide users and store selected CCSYS user details.
  final CcsysApprovalViewModel viewModel;

  /// Translation key used as the dropdown label.
  final String label;

  @override
  Widget build(BuildContext context) {
    return CustomDropdownButton(
      label: label.tr(),
      // initialOption: CustomDropdownItem(
      //   label: label.tr(),
      //   value: '',
      //   onPressed: null, // So the dropdown can capture taps initially
      // ),
      options: viewModel.userList,
      //This enables the dropdown and prints userId + userName on selection
      callBack: (selectedUserId) {
        final CustomDropdownItem selected = viewModel.userList.firstWhere(
          (o) => o.value == selectedUserId,
          orElse: () => CustomDropdownItem(value: null),
        );

        final String userId = selected.value?.toString() ?? selectedUserId;
        final String userName = selected.label ?? "";

        // Print/log both
        // For Flutter apps, prefer logger.i to avoid truncation in long lines
        logger.i("Selected User → id: $userId, name: $userName");
        viewModel.selectedUserId = userId;
        viewModel.selectedUserName = userName;
      },
      // NEW: also capture bpmRole header name
      callBackWithHeader: (selectedUserId, headerName, roleCode) {
        // basic user info
        final CustomDropdownItem selected = viewModel.userList.firstWhere(
          (o) => o.value == selectedUserId,
          orElse: () => CustomDropdownItem(value: null),
        );

        viewModel.selectedUserId = selectedUserId;
        viewModel.selectedUserName = selected.label ?? "";

        // BPM role (label + code)
        viewModel.selectedUserBpmRole = headerName ?? "";
        viewModel.selectedUserBpmRoleCode = roleCode ?? "";

        logger..i("Selected BPM Role → ${viewModel.selectedUserBpmRole}")
        ..i(
          "Selected User → rolecode: ${viewModel.selectedUserBpmRoleCode}",
        );
      },

      // <-- The button action is now stable and independent of $3
      onButtonPressed: !viewModel.canEdit
          ? null
          : () async {
              await viewModel.onSavePress(context, "recommend");
            },
    );
  }
}
