import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class BorrowerRole extends StatelessWidget {
  final LinkContractViewModel viewModel;
  const BorrowerRole({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.linkContract.borrowerRole".tr(),
      isRequired: true,
      child: CustomDropdown<Reference>(
        validationMessage: "project.linkContract.pleaseSelectBorrowerRole".tr(),
        semanticLabel: "project.linkContract.borrowerRole".tr(),
        items: viewModel.borrowerRole,
        hintText: "Select Role",
        dropdownBuilder: (context, item) => Text(item?.name ?? ""),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.name,
              isListTile: true, isSelected: isSelected);
        },
        // selectedItems: viewModel.borrowerRole != null
        //     ? [viewModel.borrowerRole!.first]
        //     : [
        //         Reference(
        //           name: "common.selectValue".tr(),
        //         )
        //       ],
        // onSelected: (selectedValue) {
        //   viewModel.borrowerRole = selectedValue.first;
        // },
      ),
    );
  }
}
