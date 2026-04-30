import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/models/request/application_details.dart";

class ReconsiderationField extends StatelessWidget {
  const ReconsiderationField({required this.viewModel, super.key});
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label:
              "requestInformation.requestInformation.reconsiderationReferenceNo"
                  .tr(),
          isRequired: true,
          showLabel: true,
          child: CustomDropdown<ApplicationDetails>(
            key: const ValueKey(
              "requestInformation.requestInformation."
              "reconsiderationReferenceNo",
            ),
            isEnabled: viewModel.canEdit,
            //  isEnabled: viewModel.canEdit
            //     ? viewModel.viewAccessRolesCheck()
            //         ? true
            //         : false
            //     : false,
            semanticLabel: "requestInformation.requestInformation."
                    "reconsiderationReferenceNo"
                .tr(),
            itemBuilder: (context, item, isDisabled, isSelected) {
              return dropdownItemBuildWidget(
                item.applicationRefNo,
                isListTile: true,
                isSelected: isSelected,
              );
            },
            dropdownBuilder: (context, data) {
              return Text(
                data?.applicationRefNo ?? "",
                style: const TextStyle(fontSize: 14),
              );
            },
            items: viewModel.reconsiderations ?? [],
            onSelected: (selected) {
              viewModel.onReconsiderationSelected(selected.first);
            },
            selectedItems: viewModel.selectedReconsiderations == null
                ? null
                : [viewModel.selectedReconsiderations],
            validationMessage:
                "requestInformation.requestInformation.requiredField".tr(),
          ),
        ),
      ],
    );
  }
}
