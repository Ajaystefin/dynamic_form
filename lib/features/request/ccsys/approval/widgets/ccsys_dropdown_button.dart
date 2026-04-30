import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/features/request/ccsys/approval/model.dart";
import "package:wcas_frontend/features/request/ccsys/approval/widgets/ccsys_custom_dropdown_btn.dart";

class CcsysDropdownButton extends StatelessWidget {
  const CcsysDropdownButton({
    required this.viewModel,
    required this.label,
    super.key,
  });
  final CcsysApprovalViewModel viewModel;
  final String label;

  @override
  Widget build(BuildContext context) {
    return CustomDropdownButton(
      label: label.tr(),
      showValueWithLabel: true,
      // No initial selection => shows "Return ▾" and opens dropdown on tap
      initialOption: null,
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
          orElse: () => CustomDropdownItem(label: null, value: null),
        );

        final String userId =
            selected.value?.toString() ?? selectedUserId.toString();
        final String userName = selected.label ?? "";

        // Print/log both
        // For Flutter apps, prefer debugPrint to avoid truncation in long lines
        debugPrint("Selected User → id: $userId, name: $userName");
        viewModel.selectedUserId = userId;
        viewModel.selectedUserName = userName;
      },
      // NEW: also capture bpmRole header name
      callBackWithHeader: (selectedUserId, headerName, roleCode) {
        // basic user info
        final CustomDropdownItem selected = viewModel.userList.firstWhere(
          (o) => o.value == selectedUserId,
          orElse: () => CustomDropdownItem(label: null, value: null),
        );

        viewModel.selectedUserId = selectedUserId;
        viewModel.selectedUserName = selected.label ?? "";

        // BPM role (label + code)
        viewModel.selectedUserBpmRole = headerName ?? "";
        viewModel.selectedUserBpmRoleCode = roleCode ?? "";

        debugPrint("Selected BPM Role → ${viewModel.selectedUserBpmRole}");
        debugPrint(
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
