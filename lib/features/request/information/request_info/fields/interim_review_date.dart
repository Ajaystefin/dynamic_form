import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/information/request_info/model.dart';

class InterimReviewDate extends StatelessWidget {
  final RequestInfoViewModel viewModel;
  const InterimReviewDate({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: 'requestInformation.requestInformation.interimReviewDate'.tr(),
          isRequired: true,
          showLabel: true,
          child: CustomDatePicker(
            isEnabled: viewModel.canEdit
                ? viewModel.viewAccessRolesCheck()
                    ? true
                    : false
                : false,
            key: const ValueKey("interimReviewDate"),
            initialDateTime: viewModel.isNewRequest
                ? null
                : viewModel.applicationDetails?.interimReviewDate,
            semanticLabel:
                'requestInformation.requestInformation.interimReviewDate'.tr(),
            blockedDates: const [],
            onSubmit2: (date) {
              viewModel.applicationDetails?.interimReviewDate = date;
            },
            validator: (date) {
              return CustomValidator.date(date);
            },
          ),
        )
      ],
    );
  }
}
