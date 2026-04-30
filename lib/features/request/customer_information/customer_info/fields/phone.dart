import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
// import 'package:wcas_frontend/core/constants/constants.dart';
// import 'package:wcas_frontend/core/utils/validators.dart';
// import 'package:wcas_frontend/core/utils/validators.dart';
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

class Phone extends StatelessWidget {
  const Phone({required this.viewModel, super.key});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final String initialValue = viewModel.customerInformation?.phone ?? "";
    final bool isValid =
        !viewModel.canEdit; // && initialValue.trim().isNotEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LabelWidget(
            isRequired: (viewModel.isFI) ? false : true,
            showLabel: true,
            label: "customerInformation.customerInformation.phone".tr(),
            child: CustomTextField(
              key: const ValueKey("phone"),
              maxLength: 30,
              semanticLabel:
                  "customerInformation.customerInformation.phone".tr(),
              validator: (viewModel.isFI)
                  ? null
                  : (value) {
                      if (value == null || value.isEmpty) {
                        return "customerInformation."
                                "customerInformation.phoneRequired"
                            .tr();
                      }
                      // if (value.length != 9) {
                      //   return

                      //       .tr();
                      // }
                      return null;
                    },
              filled: isValid,
              readOnly: isValid,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                //LengthLimitingTextInputFormatter(9),
                FilteringTextInputFormatter.digitsOnly,
              ],
              prefixText: "+971 ",
              // prefix: const Text('+971 '),
              //hintText: '50xxxxxxx', // hint without prefix
              initialValue: initialValue,
              onSaved: (value) {
                viewModel.customerInformation?.phone = value;
              },
            ),
          ),
        ),
      ],
    );
  }
}
