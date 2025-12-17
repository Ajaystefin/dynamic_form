import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/date_time_utils.dart';
import 'package:wcas_frontend/features/request/information/request_info/model.dart';

class CaDate extends StatelessWidget {
  final RequestInfoViewModel viewModel;
  const CaDate({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // final bool isEditable = viewModel.canEdit;
    // final bool hasCaValue =
    // viewModel.requestInformation.cda?.isNotEmpty ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: 'requestInformation.requestInformation.caDate'.tr(),
          isRequired: false,
          showLabel: true,
          child: CustomTextField(
            filled: true,
            semanticLabel: 'requestInformation.requestInformation.caDate'.tr(),
            readOnly: true,
            initialValue: viewModel.isNewRequest
                ? DateFormat('dd/MM/yyyy').format(DateTime.now().toLocal())
                : DateFormat('dd/MM/yyyy').format(
                    DateTimeUtils.convertToDate(
                        viewModel.applicationDetails?.cda),
                  ),
            onSaved: (String? value) {
              viewModel.applicationDetails?.cda = value;
            },
          ),
        )
      ],
    );
  }
}
