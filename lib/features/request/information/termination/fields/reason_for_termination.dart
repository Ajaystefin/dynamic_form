import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/information/termination/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/comment.dart';

class ReasonForTermination extends StatelessWidget {
  final TerminationViewModel viewModel;
  const ReasonForTermination({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final List<Comment> reviewComments = viewModel.getReviewComments ?? [];
    final int? selectedReasonId =
        reviewComments.isNotEmpty && reviewComments.first.reasonList != null
            ? int.tryParse(reviewComments.first.reasonList!)
            : null;

    return LabelWidget(
      isRequired: true,
      label: 'requestInformation.terminateWithdrawal.reasonForTermination'.tr(),
      child: CustomDropdown<Reference>(
        isEnabled: viewModel.canEdit,
        items: viewModel.reasonForTermination,
        onSelected: (selectedValue) {
          final selected = selectedValue.first;
          viewModel.reasonForTerminationSelected(selected);

          if (reviewComments.isNotEmpty) {
            reviewComments.first.reasonList = selected.id.toString();
          }
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
