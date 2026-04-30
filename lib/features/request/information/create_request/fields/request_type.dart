import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
// import 'package:responsive_builder/responsive_builder.dart';
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/information/create_request/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class RequestTypeField extends StatelessWidget {
  const RequestTypeField({required this.viewModel, super.key});
  final CreateRequestViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      label: "requestInformation.createRequest.requestType".tr(),
      child: CustomDropdown<Reference>(
        key: ValueKey(viewModel.isResetPressed),
        isLoading: viewModel.fieldLoading,
        showClearIcon: false,
        semanticLabel: "requestInformation.createRequest.requestType".tr(),
        width: context.isDesktop ? 300.w : null,
        validationMessage: "common.validation.pleaseEnter".tr() +
            "requestInformation.createRequest.requestType".tr(),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.name,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        items: viewModel.getRequestTypes(),
        onSelected: (selectedValue) async {
          await viewModel.onRequestTypeChange(selectedValue.first);
        },
        dropdownBuilder: (context, data) {
          return Text(
            data?.name ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
        selectedItems: viewModel.selectedRequestType == null
            ? null
            : [viewModel.selectedRequestType],
      ),
    );
  }
}
