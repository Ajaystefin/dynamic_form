import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";
import "package:wcas_frontend/models/request/project/link_commitment_number.dart";

class ProjectCollectionAcc extends StatelessWidget {
  ProjectCollectionAcc({required this.viewModel, super.key});
  final EditContractViewModel viewModel;
  final ScrollController contrlr = ScrollController();

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.projectCollectionAmount".tr(),
      child: CustomMultiSelectDropdown<LinkCommitmentNumber>(
        isEnabled: (viewModel.canEdit) ? true : false,
        filterFn: (LinkCommitmentNumber item, String filter) {
          return (item.projectAllocationAccount ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        // compareFn: (a, b) {
        //   final String? filterItemOld =
        //       a.projectAllocationAccount?.trim().toLowerCase();
        //   final String? filterItemNew =
        //       b.projectAllocationAccount?.trim().toLowerCase();
        //   return filterItemOld == filterItemNew;
        // },
        key: ValueKey(viewModel.contract.linkCommitmentNumberWith?.length),
        semanticLabel:
            "project.viewEditContractDetails.projectCollectionAmount".tr(),
        isSearchable: true,

        // validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.linkContract ?? [],
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownMultiItemBuildWidget(
            item.projectAllocationAccount,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        dropdownBuilder: (context, data) {
          return multiSelectDropDownBuilderWidget(
            data: data!,
            controller: contrlr,
            key: ValueKey(viewModel.contract.linkCommitmentNumberWith?.length),
            itemBuilder: (index) {
              final country = data[index];
              return Container(
                margin: const EdgeInsets.only(
                  left: 5,
                  top: 5,
                  bottom: 5,
                  right: 15,
                ),
                child: buildMultiSelectChip(
                  label: buildItemText(
                    country.projectAllocationAccount ?? "",
                    FontSizeHelper(size: FontSize.small),
                  ),
                  onDeleted: () => viewModel.linkCommitmentNumberDeleted(index),
                ),
              );
            },
          );
        },
        onSelected: (selected) {
          viewModel.updateLinkCommitmentNumberWith(selected);
        },
        selectedItems: viewModel.contract.linkCommitmentNumberWith ?? [],
      ),
    );
  }
}
