import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class BorrowerSubsidiary extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const BorrowerSubsidiary({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'ccsys.customerInformation.borrowingSubsidiary'.tr(),
      isRequired: true,
      child: CustomRadioButton<Reference?>(
        scrollDirection: Axis.horizontal,
        options: viewModel.radioButtonItems,
        itemBuilder: (context, item, isSelected, isEnabled) =>
            Text(item?.name ?? ''),
        selectedValue: viewModel.customerInformation.radioButtonItems,
        onChanged: (Reference? selectedOption) =>
            viewModel.onChangeBorrowingSubsidiary(selectedOption),
      ),
    );
  }
}
