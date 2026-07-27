import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

/// Widget for selecting a commitment account number.
class CommitmentAccountNumber extends StatelessWidget {
  /// Creates a commitment account number selector.
  const CommitmentAccountNumber({required this.viewModel, super.key});

  /// View model containing commitment account number data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.commitmentAccountNumber".tr(),
      isRequired: !viewModel.isFIFlow,
      child: CustomDropdown<String>(
        editInputFormatters: [
          LengthLimitingTextInputFormatter(15),
          FilteringTextInputFormatter.digitsOnly,
        ],
        showEditIcon: viewModel.isCmoUpdate(),
        onEditComplete: (editedValue) {
          if (editedValue.isNotEmpty) {
            viewModel.setCommitmentAccNumber(editedValue);
          }
        },
        onTextChanged: (updatedText) {
          if (updatedText.isNotEmpty) {
            viewModel.setCommitmentAccNumber(updatedText);
          }
        },
        ignoreProvider: viewModel.isCmoUpdate(),
        validationMessage:
            !viewModel.isFIFlow ? "common.validation.emptyField".tr() : null,
        semanticLabel: "facilities.createFacility.commitmentAccountNumber".tr(),
        items: viewModel.commitmentAccountNumberItemsForUi,
        selectedItems: viewModel.commitmentAccSelectedForUi,
        onSelected: (selectedValue) async {
          if (selectedValue.isNotEmpty) {
            await viewModel.setCommitmentAccNumber(selectedValue.first);
          }
        },
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownMultiItemBuildWidget(
            item,
            isSelected: isSelected ?? false,
          );
        },
        dropdownBuilder: (context, data) {
          return Text(
            data ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }
}
