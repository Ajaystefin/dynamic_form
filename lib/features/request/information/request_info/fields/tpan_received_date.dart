import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
// import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/information/request_info/model.dart';

class TPANReceivedDate extends StatelessWidget {
  final RequestInfoViewModel viewModel;
  const TPANReceivedDate({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: 'requestInformation.requestInformation.tpanReceivedDate'.tr(),
          isRequired: false,
          showLabel: true,
          child: CustomDatePicker(
            isEnabled: viewModel.canEdit
                ? viewModel.viewAccessRolesCheck()
                    ? true
                    : false
                : false,

            key: const ValueKey("tpanRecievedDate"),
            initialDateTime: viewModel.isNewRequest
                ? null
                : viewModel.applicationDetails?.tpanRecievedDate,
            blockedDates: const [],
            semanticLabel:
                'requestInformation.requestInformation.tpanReceivedDate'.tr(),
            onSubmit2: (date) {
              viewModel.applicationDetails?.tpanRecievedDate = date;
            },
            // validator: CustomValidator.optionalDate,
          ),
        )
      ],
    );
  }
}
