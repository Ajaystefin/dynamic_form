import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class PSLei extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const PSLei({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'ccsys.customerInformation.psLei'.tr(),
      isRequired: true,
      child: CustomRadioButton<Reference?>(
        scrollDirection: Axis.horizontal,
        options: viewModel.radioButtonItems,
        itemBuilder: (context, item, isSelected, isEnabled) =>
            Text(item?.name ?? ''),
        selectedValue: viewModel.customerInformation.pslei,
        onChanged: (Reference? psLei) {
          viewModel.customerInformation.pslei = psLei;
        },
      ),
    );
  }
}
