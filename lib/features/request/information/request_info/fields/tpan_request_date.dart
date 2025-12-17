import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
// import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/information/request_info/model.dart';

class TPANRequestDate extends StatelessWidget {
  final RequestInfoViewModel viewModel;
  const TPANRequestDate({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: 'requestInformation.requestInformation.tpanRequestDate'.tr(),
          isRequired: false,
          showLabel: true,
          child: CustomDatePicker(
            isEnabled: viewModel.canEdit
                ? viewModel.viewAccessRolesCheck()
                    ? true
                    : false
                : false,

            key: const ValueKey("tpanRequestDate"),
            semanticLabel:
                'requestInformation.requestInformation.tpanRequestDate'.tr(),
            initialDateTime: viewModel.isNewRequest
                ? null
                : viewModel.applicationDetails?.tpanRequestDate,
            blockedDates: const [],
            onSubmit2: (date) {
              viewModel.applicationDetails?.tpanRequestDate = date;
            },
            // validator: CustomValidator.date,
          ),
        )
      ],
    );
  }
}
