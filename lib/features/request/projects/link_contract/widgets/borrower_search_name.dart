import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/model.dart';

class BorrowerSearchName extends StatelessWidget {
  final LinkContractViewModel viewModel;
  const BorrowerSearchName({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.linkContract.name".tr(),
      isRequired: true,
      child: CustomTextField(
        semanticLabel: "project.linkContract.name".tr(),
       
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          LengthLimitingTextInputFormatter(100),
        ],
        controller: viewModel.searchNameController,
      ),
    );
  }
}
