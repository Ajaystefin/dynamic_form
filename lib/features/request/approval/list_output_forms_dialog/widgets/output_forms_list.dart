import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/approval/list_output_forms_dialog/model.dart";

class OutputFormsList extends StatelessWidget {
  const OutputFormsList({
    required this.viewModel,
    super.key,
  });
  final ListOutputFormsDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      children: List.generate(
        viewModel.outputForms.length,
        (index) {
          final item = viewModel.outputForms[index];
          return CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            title: Text(
              item.name ?? "",
              style: AppStyle.boldLabel,
            ),
            value: item.isSelected,
            onChanged: (_) => viewModel.toggleSelection(index),
          );
        },
      ),
    );
  }
}
