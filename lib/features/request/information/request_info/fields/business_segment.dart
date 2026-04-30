import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";

class BusinessSegmentField extends StatelessWidget {
  const BusinessSegmentField({required this.viewModel, super.key});
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
//        viewModel.applicationDetails?.businessSegment?.isNotEmpty ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.businessSegment".tr(),
          isRequired: false,
          showLabel: true,
          child: CustomTextField(
            filled: true,
            semanticLabel:
                "requestInformation.requestInformation.businessSegment".tr(),
            readOnly: true,
            initialValue: ((viewModel.isFI)
                    ? viewModel.applicationDetails?.businessSegment ??
                        Globals.user?.segments?.first ??
                        Globals.request?.businessSegment?.name ??
                        ""
                    : viewModel.applicationDetails?.businessSegment ??
                        Globals.request?.businessSegment?.name ??
                        Globals.user?.segments?.first ??
                        "")
                .capitalizeFirstLetterFirstSecond(),
            onSaved: (String? value) {
              viewModel.applicationDetails?.businessSegment = value;
            },
          ),
        ),
      ],
    );
  }
}
