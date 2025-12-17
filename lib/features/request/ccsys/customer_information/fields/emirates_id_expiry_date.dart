import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/date_time_utils.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';

class EmiratesIdExpiry extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const EmiratesIdExpiry({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    bool isMantatory =
        (viewModel.customerInformation.emiratesIdPartner != null) &&
            viewModel.isLegalNpAndResidencyRE();
    return LabelWidget(
      label: 'ccsys.customerInformation.EmiratesIdExpiry'.tr(),
      isRequired:
          isMantatory, //mandatory only if Residency status is RE and Legal Status is NP.
      child: CustomDatePicker(
        semanticLabel: 'ccsys.customerInformation.EmiratesIdExpiry'.tr(),
        isEnabled: viewModel.customerInformation.emiratesIdPartner != null,
        onSubmit2: (DateTime? selectedDate) {
          viewModel.customerInformation.emiratesIdExpiry =
              DateTimeUtils.datetimeToInt(selectedDate);
        },
        validator: isMantatory ? CustomValidator.date : null,
      ),
    );
  }
}
