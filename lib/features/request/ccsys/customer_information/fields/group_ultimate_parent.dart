import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';

class GroupUltimateParent extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const GroupUltimateParent({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'ccsys.customerInformation.groupUltimateParent'.tr(),
      isRequired: viewModel.isBorrowingSubsidiary,
      child: CustomTextField(
        semanticLabel: 'ccsys.customerInformation.groupUltimateParent'.tr(),
        initialValue: viewModel.isBorrowingSubsidiary ? "NA" : null,
        validator: viewModel.isBorrowingSubsidiary
            ? CustomValidator.requiredField
            : null,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
        ],
        onSaved: (String? groupUltimateParent) {
          viewModel.customerInformation.groupUltimateParent =
              groupUltimateParent;
        },
      ),
    );
  }
}
