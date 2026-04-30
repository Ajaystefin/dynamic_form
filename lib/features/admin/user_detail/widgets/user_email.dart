import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
// import 'package:wcas_frontend/core/utils/validators.dart';
import "package:wcas_frontend/features/admin/user_detail/model.dart";

class UserEmail extends StatelessWidget {
  const UserEmail({required this.viewModel, super.key});
  final UserDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // final bool hasData = viewModel.userDetails?.email?.isNotEmpty ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "admin.userManagementDetail.email".tr(),
          isRequired: false,
          showLabel: true,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          child: CustomTextField(
            semanticLabel: "admin.userManagementDetail.email".tr(),
            controller:
                TextEditingController(text: viewModel.userDetails?.email),
            readOnly: true,
            filled: true,
            fillColor: AppColors.accordionSecondary,
            // validator: hasData ? null : CustomValidator,
            onSaved: (String? value) {
              viewModel.userDetails?.email = value;
            },
          ),
        ),
      ],
    );
  }
}
