import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';

class GroupImmediateParent extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const GroupImmediateParent({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'ccsys.customerInformation.groupImmediateParent'.tr(),
      isRequired: viewModel.isBorrowingSubsidiary,
      child: CustomTextField(
        semanticLabel: 'ccsys.customerInformation.groupImmediateParent'.tr(),
        initialValue: viewModel.isBorrowingSubsidiary
            ? viewModel.defaultField.name
            : null,
        validator: viewModel.isBorrowingSubsidiary
            ? CustomValidator.requiredField
            : null,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
        ],
        onSaved: (String? groupImmediateParent) {
          viewModel.customerInformation.groupImmediateParent =
              groupImmediateParent;
        },
      ),
    );
  }
}
