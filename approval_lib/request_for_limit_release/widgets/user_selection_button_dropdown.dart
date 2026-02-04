import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wcas_frontend/core/components/button_dropdown.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/approval/request_for_limit_release/model.dart';

import '../../../../../core/components/dropdown/model.dart';
import '../../../../../models/login/user.dart';

class RecommendationDropdown extends StatelessWidget {
  //final List<CustomDropdownItem> options;
  final List<User> options;
  final String label;
  final RequestForLimitReleaseViewModel viewModel;
  final UserAction userAction;

  const RecommendationDropdown(
      {super.key,
      required this.options,
      required this.label,
      required this.viewModel,
      required this.userAction});

  @override
  Widget build(BuildContext context) {
    debugPrint(" viewModel.userList : ${viewModel.userList.length}");
    return CustomDropdownButton(
      label: label.tr(),
      initialOption: CustomDropdownItem(
        value: label.tr(),
        onPressed: () async {
          viewModel.selectedUser = User(id: "0");
        },
      ),
      options: viewModel.getUserListDropDownItems(options),
      callBack: (value) async {
        viewModel.selectedUserId = value;
        await viewModel.submitApplication(userAction);
      },
    );
  }
}
