import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/state.dart";

class ExceptedCompletionDateVarient extends StatelessWidget {
  const ExceptedCompletionDateVarient({required this.viewModel, super.key});
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditContractViewModel, EditContractState>(
      builder: (context, state) {
        return LabelWidget(
          label: "project.linkContract.variation".tr(),
          child: CustomTextField(
            semanticLabel: "project.linkContract.variation".tr(),
            // initialValue: viewModel.contract.variationCompletionDate,
            controller: viewModel.variationCompletionDateController,
            readOnly: true,
            filled: true,
            fillColor: AppColors.tableActivatedColor,
          ),
        );
      },
    );
  }
}
