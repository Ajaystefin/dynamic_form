import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/button_dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/approval/comments/model.dart";
import "package:wcas_frontend/models/login/user.dart";

class RecommendationDropdown extends StatelessWidget {
  const RecommendationDropdown({
    required this.options,
    required this.label,
    required this.viewModel,
    required this.userAction,
    super.key,
  });
  final Map<String, List<User>> options;
  // final List<User> options;
  final String label;
  final CommentsViewModel viewModel;
  final UserAction userAction;

  @override
  Widget build(BuildContext context) {
    final LayoutViewModel layoutViewModel = context.watch<LayoutViewModel>();
    // debugPrint(" viewModel.userList : ${viewModel.userList.length}");
    return CustomDropdownButton(
      label: label.tr(),
      showValueWithLabel: true,
      initialOption: CustomDropdownItem(
        isHeader: true,
        // label: "common.select".tr(),
        value: "",
        onPressed: () async {
          viewModel.selectedUser = User(id: "0");
        },
      ),
      options: viewModel.getUserListDropDownItems(options),
      callBack: (value) async {
        viewModel.selectedUserId = value;
      },
      onButtonPressed: () async {
        final List<String> result =
            await viewModel.submitApplication(userAction);
        if (result.isNotEmpty) {
          if (context.mounted &&
              result.first == "layout.topmenu.comfirmation".tr()) {
            await layoutViewModel.showConfirmationDialog(context, result.last);
          } else if (context.mounted) {
            await layoutViewModel.showWarningDialog(context, result);
          }
        }
      },
    );
  }
}
