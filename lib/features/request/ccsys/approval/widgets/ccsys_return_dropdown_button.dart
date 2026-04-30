import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/features/request/ccsys/approval/model.dart";
import "package:wcas_frontend/features/request/ccsys/approval/widgets/ccsys_custom_dropdown_btn.dart";

class CcsysReturnDropdownButton extends StatelessWidget {
  const CcsysReturnDropdownButton({
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
      initialOption: null,
      options: viewModel.userListReturn,
      // selection callback (keep yours)

      callBack: (selectedUserId) {
        final selected = viewModel.userListReturn.firstWhere(
          (o) => (o.value?.toString() ?? "") == selectedUserId,
          orElse: () => CustomDropdownItem(label: null, value: null),
        );

        final userId = selected.value?.toString() ?? selectedUserId.toString();
        final userName = selected.label ?? "";

        debugPrint("Selected User → id: $userId, name: $userName");
        viewModel.selectedReturnUserId = userId;
        viewModel.selectedReturnUserName = userName;
      },

      // role from the *selected item*
      callBackWithHeader: (selectedUserId, headerName, roleCode) {
        final CustomDropdownItem selected = viewModel.userListReturn.firstWhere(
          (o) =>
              !o.isHeader &&
              o.value?.toString() == selectedUserId.toString() &&
              (o.headerName == headerName || o.title == headerName),
          orElse: () => CustomDropdownItem(value: null, label: null),
        );

        viewModel.selectedReturnUserBpmRole =
            selected.headerName ?? (headerName ?? "");
        debugPrint(
          "Selected BPM Role → ${viewModel.selectedReturnUserBpmRole}",
        );

        //  viewModel.selectedUserBpmRoleCode = roleCode ?? '';
        // debugPrint('Selected User → rolecode:
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
