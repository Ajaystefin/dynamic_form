import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/model.dart';

class SearchRimno extends StatelessWidget {
  final LinkContractViewModel viewModel;
  const SearchRimno({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.linkContract.rimNo".tr(),
      isRequired: true,
      child: CustomTextField(
        
        semanticLabel: "project.linkContract.rimNo".tr(),
        keyboardType: TextInputType.number,
       
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(15),
        ],
        controller: viewModel.searchRimController,
      ),
    );
  }
}
