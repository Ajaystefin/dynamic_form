import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/information/create_request/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class CustomerTypeField extends StatelessWidget {
  const CustomerTypeField({required this.viewModel, super.key});
  final CreateRequestViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      label: "requestInformation.createRequest.customerType".tr(),
      child: CustomDropdown<Reference>(
        isLoading: viewModel.fieldLoading,
        width: context.isDesktop ? 300.w : null,
        semanticLabel: "requestInformation.createRequest.customerType".tr(),
        validationMessage: "common.validation.pleaseEnter".tr() +
            "requestInformation.createRequest.customerType".tr(),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.name,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        showClearIcon: false,
        items: viewModel.customerTypes,
        onSelected: (selectedValue) async {
          await viewModel.onCustomerTypeSelection(selectedValue.first);
        },
        dropdownBuilder: (context, data) {
          return Text(data?.name ?? "");
        },
        selectedItems: viewModel.selectedCustomerType == null
            ? null
            : [viewModel.selectedCustomerType],
      ),
    );
  }
}
