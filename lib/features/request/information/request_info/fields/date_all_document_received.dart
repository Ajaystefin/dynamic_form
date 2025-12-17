import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/information/request_info/model.dart';

class DateAllDocumentReceived extends StatelessWidget {
  final RequestInfoViewModel viewModel;
  const DateAllDocumentReceived({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: 'requestInformation.requestInformation.dateAllDocumentReceived'
              .tr(),
          isRequired: false,
          showLabel: true,
          child: CustomDatePicker(
            isEnabled: viewModel.canEdit
                ? viewModel.viewAccessRolesCheck()
                    ? true
                    : false
                : false,
            key: const ValueKey("dateAllDocumentReceived"),
            semanticLabel:
                'requestInformation.requestInformation.dateAllDocumentReceived'
                    .tr(),
            initialDateTime: viewModel.isNewRequest
                ? null
                : viewModel.applicationDetails?.dateAllDocumentReceived,
            blockedDates: const [],
            onSubmit2: (DateTime? date) {
              viewModel.applicationDetails?.dateAllDocumentReceived = date;
            },
          ),
        )
      ],
    );
  }
}
