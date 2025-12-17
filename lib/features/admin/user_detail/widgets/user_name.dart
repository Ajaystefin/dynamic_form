import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/admin/user_detail/model.dart';

class UserName extends StatelessWidget {
  const UserName({super.key, required this.viewModel});
  final UserDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool hasData = viewModel.userDetails?.name?.isNotEmpty ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: 'admin.userManagementDetail.userName'.tr(),
          isRequired: false,
          showLabel: true,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          child: CustomTextField(
            semanticLabel: 'admin.userManagementDetail.userName'.tr(),
            controller:
                TextEditingController(text: viewModel.userDetails?.name),
            readOnly: true,
            filled: true,
            fillColor: AppColors.textFieldDisabledFill,
            validator: hasData ? null : CustomValidator.requiredField,
            onSaved: (String? value) {
              viewModel.userDetails?.name = value;
            },
          ),
        )
      ],
    );
  }
}
