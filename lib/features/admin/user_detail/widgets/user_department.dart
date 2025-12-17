import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/admin/user_detail/model.dart';

class UserDepartment extends StatelessWidget {
  const UserDepartment({super.key, required this.viewModel});
  final UserDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final department = viewModel.userDetails?.department?.toString();
    final bool hasData = department?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: 'admin.userManagementDetail.department'.tr(),
          isRequired: false,
          showLabel: true,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          child: CustomTextField(
            semanticLabel: 'admin.userManagementDetail.department'.tr(),
            controller: TextEditingController(text: department),
            readOnly: true,
            filled: true,
            fillColor: AppColors.textFieldDisabledFill,
            validator: hasData ? null : CustomValidator.requiredField,
            onSaved: (String? value) {
              if (viewModel.userDetails != null) {
                viewModel.userDetails!.department = value;
              }
            },
          ),
        ),
      ],
    );
  }
}
