import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/information/request_info/model.dart';
import 'package:wcas_frontend/features/request/information/request_info/state.dart';

class NextReviewDate extends StatelessWidget {
  final RequestInfoViewModel viewModel;
  final RequestInfoState state;
  const NextReviewDate(
      {super.key, required this.viewModel, required this.state});

  @override
  Widget build(BuildContext context) {
    bool? isValid = viewModel.otherRolesCheck()
        ? viewModel.canEdit
            ? state.overrideDate ?? false
            : false
        : false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: 'requestInformation.requestInformation.nextReviewDate'.tr(),
          isRequired: true,
          showLabel: true,
          child: CustomDatePicker(
          key: ValueKey(state.nextReviewDate),
            semanticLabel:
                'requestInformation.requestInformation.nextReviewDate'.tr(),
            isEnabled: isValid,
            initialDateTime:
                state.nextReviewDate ?? state.defaultNextReviewDate,
            blockedDates: const [],
            firstDate: state.presentReviewDate ?? DateTime.now(),
            // lastDate: state.defaultNextReviewDate ?? DateTime.now(),
            onSubmit2: (date) {
              viewModel.validateAndSetNextReviewDate(date);
            },
            validator: CustomValidator.date,
          ),
        ),
      ],
    );
  }
}
