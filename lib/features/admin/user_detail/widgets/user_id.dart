import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/admin/user_detail/model.dart";

class UserId extends StatelessWidget {
  const UserId({required this.viewModel, super.key});
  final UserDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final userId = viewModel.userDetails?.id;
    final bool hasData = userId?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "admin.userManagementDetail.userId".tr(),
          isRequired: false,
          showLabel: true,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          child: CustomTextField(
            semanticLabel: "admin.userManagementDetail.userId".tr(),
            controller: TextEditingController(text: userId),
            readOnly: true,
            filled: true,
            fillColor: AppColors.textFieldDisabledFill,
            validator: hasData ? null : CustomValidator.requiredField,
            onSaved: (String? value) {
              if (viewModel.userDetails != null) {
                viewModel.userDetails!.id = value;
              }
            },
          ),
        ),
      ],
    );
  }
}
