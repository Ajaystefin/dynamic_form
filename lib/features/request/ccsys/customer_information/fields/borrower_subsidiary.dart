import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class BorrowerSubsidiary extends StatelessWidget {
  const BorrowerSubsidiary({
    required this.viewModel,
    super.key,
  });
  final CustomerInformationViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "ccsys.customerInformation.borrowingSubsidiary".tr(),
      isRequired: viewModel.canEdit,
      child: CustomRadioButton<Reference>(
        isEnabled: (!viewModel.canEdit) ? false : true,
        itemBuilder: (context, item, isSelected, isEnabled) =>
            Text(item.name ?? ""),
        options: viewModel.getFilteredOptions(viewModel.yesNoNaItems),
        selectedValue: viewModel.getSelectedReference(
          options: viewModel.yesNoNaItems,
          selectedValue: viewModel.selectedBorroweSubsidiary,
          fallbackFlag: viewModel.customerInformation.borrowerSubsidiary,
        ),
        validator: (!viewModel.canEdit)
            ? null
            : (value) => viewModel.validateSelection(
                  value?.name,
                  viewModel.getFilteredOptions(viewModel.yesNoNaItems),
                  "requestInformation.requestInformation.selectTpan".tr(),
                ),
        onChanged: (selectedRef) {
          viewModel.onChangeBorrowingSubsidiary(selectedRef);
        },
        selectedColor: AppColors.primary,
        unselectedColor: Colors.grey,
        scrollDirection: Axis.horizontal,
      ),

      //        CustomRadioButton<Reference?>(
      //   scrollDirection: Axis.horizontal,
      //   options: viewModel.radioButtonItems,
      //   itemBuilder: (context, item, isSelected, isEnabled) =>
      //       Text(item?.name ?? ''),
      //   selectedValue: viewModel.customerInformation.radioButtonItems,
      //   onChanged: (Reference? selectedOption) =>
      //       viewModel.onChangeBorrowingSubsidiary(selectedOption),
      // ),
    );
  }
}
