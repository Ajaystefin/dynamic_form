import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/information/request_info/model.dart';
import 'package:wcas_frontend/features/request/information/request_info/state.dart';

class PresentReviewDate extends StatelessWidget {
  final RequestInfoViewModel viewModel;
  final RequestInfoState state;
  const PresentReviewDate(
      {super.key, required this.viewModel, required this.state});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDate = now; // Always today onwards
    final lastDate = now.add(const Duration(days: 300));
    // state.presentReviewDate ?? state.defaultPresentReviewDate ??
    DateTime? initialDate;

    // If NTB → blank (null)
    if (Utils.checkApplicationType(ApplicationType.newToBank)) {
      initialDate = (viewModel.isNewRequest) ? null : state.presentReviewDate;
    } else {
      initialDate =
          (Utils.checkApplicationType(ApplicationType.reconsideration))
              ? state.presentReviewDate
              : viewModel.applicationDetails?.presentReviewDate == null
                  ? null
                  : state.presentReviewDate;
      // For others → use presentReviewDate or clamp within range
      // if (initialDate.isBefore(firstDate)) initialDate = firstDate;
      // if (initialDate.isAfter(lastDate)) initialDate = lastDate;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
            label:
                'requestInformation.requestInformation.presentReviewDate'.tr(),
            isRequired: false,
            showLabel: true,
            child: CustomDatePicker(
              isEnabled: viewModel.canEdit &&
                  viewModel.viewAccessRolesCheck() &&
                  ((viewModel.applicationDetails?.presentReviewDate == null) ||
                      (Utils.checkApplicationType(ApplicationType.newToBank) &&
                          viewModel.isNewRequest)),
              key: ValueKey(initialDate),
              semanticLabel:
                  'requestInformation.requestInformation.presentReviewDate'
                      .tr(),
              initialDateTime: initialDate,
              blockedDates: const [],
              firstDate: firstDate,
              lastDate: lastDate,
              onSubmit2: (date) {
                viewModel.validateAndSetPresentReviewDate(date,
                    details: viewModel.applicationDetails);
              },
            ))
      ],
    );
  }
}
