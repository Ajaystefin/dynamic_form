import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/ccsys/termination/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";

class ReasonForTermination extends StatelessWidget {
  const ReasonForTermination({required this.viewModel, super.key});
  final CcsysTerminationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final List<Comment> reviewComments = viewModel.getReviewComments ?? [];
    final int? selectedReasonId =
        reviewComments.isNotEmpty && reviewComments.first.reasonList != null
            ? int.tryParse(reviewComments.first.reasonList!)
            : int.tryParse(viewModel.comment!.reasonList.toString());

    return LabelWidget(
      isRequired: viewModel.canEdit,
      label: "requestInformation.terminateWithdrawal.reasonForTermination".tr(),
      child: CustomDropdown<Reference>(
        key: const ValueKey(
          "requestInformation.terminateWithdrawal.reasonForTermination",
        ),
        isEnabled: viewModel.canEdit,
        items: viewModel.reasonForTermination,
        validationMessage: "common.validation.emptyField".tr(),
        onSelected: (selectedValue) {
          final selected = selectedValue.first;
          viewModel.reasonForTerminationSelected(selected);
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.name,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        dropdownBuilder: (context, data) {
          return Text(
            data?.name ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
        selectedItems: selectedReasonId != null
            ? viewModel.reasonForTermination
                .where((e) => e.id == selectedReasonId)
                .toList()
            : [],
      ),
    );
  }
}
