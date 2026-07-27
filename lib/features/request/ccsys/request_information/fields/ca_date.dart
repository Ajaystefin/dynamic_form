import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/model.dart";

/// Read-only field widget that displays the CA date.
class CaDate extends StatelessWidget {
  /// Creates a [CaDate] widget.
  const CaDate({required this.viewModel, super.key});

  /// View model used to read and save CA date data.
  final RequestInformationViewModel viewModel;

  /// Builds the CA date field.
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "requestInformation.requestInformation.caDate".tr(),
      child: CustomTextField(
        filled: true,
        semanticLabel: "requestInformation.requestInformation.caDate".tr(),
        readOnly: true,
        initialValue: viewModel.isNewRequest
            ? DateFormat("dd/MM/yyyy").format(DateTime.now().toLocal())
            : DateFormat("dd/MM/yyyy").format(
                DateTimeUtils.convertToDate(viewModel.applicationDetails?.cda),
              ),
        onSaved: (String? value) {
          viewModel.applicationDetails?.cda = value;
        },
      ),
    );

    // LabelWidget(
    //   label: 'ccsys.requestInformation.caDate'.tr(),
    //   child: CustomTextField(
    //     filled: true,
    //     readOnly: true,
    //     semanticLabel: 'ccsys.requestInformation.caDate'.tr(),
    //     initialValue: DateTimeUtils.convertToDate(ca).toString(),
    //   ),
    // );
  }
}
