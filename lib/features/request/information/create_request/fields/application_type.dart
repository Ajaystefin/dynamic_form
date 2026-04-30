import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/information/create_request/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class ApplicationTypeField extends StatelessWidget {
  const ApplicationTypeField({required this.viewModel, super.key});
  final CreateRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: viewModel.fieldLoading,
      child: LabelWidget(
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        isRequired: true,
        label: "requestInformation.createRequest.applicationType".tr(),
        child: CustomDropdown<Reference>(
          isLoading: viewModel.fieldLoading,
          width: context.isDesktop ? 300.w : null,
          semanticLabel:
              "requestInformation.createRequest.applicationType".tr(),
          key: ValueKey(
            viewModel.selectedRequestType?.name.toString() ??
                "${viewModel.businessSegmentValue?.name}",
          ),
          validationMessage: "common.validation.pleaseEnter".tr() +
              "requestInformation.createRequest.applicationType".tr(),
          isEnabled: viewModel.selectedRequestType != null,
          items: viewModel.applicationTypeItems(),
          onSelected: (selectedValue) {
            viewModel.onApplicationTypeChanged(selectedValue.first);
          },
          showClearIcon: false,
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
          selectedItems: viewModel.selectedApplicationType == null
              ? null
              : [viewModel.selectedApplicationType],
        ),
      ),
    );
  }
}
