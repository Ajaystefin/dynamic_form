import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/state.dart";

class InitalContractValueVarient extends StatelessWidget {
  const InitalContractValueVarient({required this.viewModel, super.key});
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditContractViewModel, EditContractState>(
      builder: (context, state) {
        return LabelWidget(
          label: "project.linkContract.variation".tr(),
          child: CustomTextField(
            semanticLabel: "project.linkContract.variation".tr(),
            controller: viewModel.variationController,
            // initialValue:
            // viewModel.contract.variationContractValue.toString(),
            readOnly: true,
            filled: true,
            fillColor: AppColors.tableActivatedColor,
            // Optional: allow only "+/-" numbers or "NA". It's readOnly anyway.
            inputFormatters: [
              DecimalInputFormatter(
                regEx: RegExp(r"^([+-])?[0-9,]{0,21}(\.\d{0,6})?$|^NA$"),
              ),
            ],
          ),
        );
      },
    );
  }
}
