import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/checkbox.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/information/security_perfection/model.dart';
import 'package:wcas_frontend/features/request/information/security_perfection/widgets/linked_facilities.dart';
import 'package:wcas_frontend/models/request/security_deferral.dart';

class SecurityPerfectionTable extends StatelessWidget {
  final SecurityPerfectionViewModel viewModel;
  const SecurityPerfectionTable({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "requestInformation.securityPerfection.title".tr(),
      child: CustomRawTable(
        key: UniqueKey(),
        columns: [
          const TableColumn(label: CustomSelectableText(text: "")),
          TableColumn(
              label: Text(
                  "requestInformation.securityPerfection.securityNumber".tr())),
          TableColumn(
              label: Text(
                  "requestInformation.securityPerfection.securityDescription"
                      .tr())),
          TableColumn(
              label: Text(
                  "requestInformation.securityPerfection.securityAmount".tr())),
          TableColumn(
              label:
                  Text("requestInformation.securityPerfection.dateLabel".tr())),
          TableColumn(
              label:
                  Text("requestInformation.securityPerfection.deferral".tr())),
        ],
        rows: List.generate(
            viewModel.securityDeferral.securityDeferralList!.length, (index) {
          final info = viewModel.securityDeferral.securityDeferralList![index];

          return [
            CustomCheckbox(
              value: info.isChecked,
              onChange: (value) {
                info.isChecked = value!;
                viewModel.updateTableStateChanges(); // triggers rebuild
              },
            ),
            Text(info.securityNo.toString()),
            Text(info.securityType.toString()),
            Text(info.proposed.toString()),
            info.isChecked
                ? CustomDatePicker(
                    key: UniqueKey(),
                    initialDateTime: info.dateDeferral,
                    blockedDates: const [],
                    onSubmit2: (date) {
                      info.dateDeferral = date;
                    },
                    validator: CustomValidator.date,
                  )
                : const CustomTextField(
                    initialValue: '',
                    filled: true,
                    readOnly: true,
                    fillColor: AppColors.textFieldDisabledFill,
                  ),
            attachIcon(info.isChecked, viewModel, context, info),
          ];
        }),
      ),
    );
  }

  Widget attachIcon(bool isChecked, SecurityPerfectionViewModel viewModel,
      BuildContext context, SecurityDeferral info) {
    return Center(
      child: InkWell(
        onTap: () {
          isChecked
              ? //show dialog for given data
              DialogHelper.showCustomDialog(
                  barrierDismissible: false,
                  title:
                      "requestInformation.securityPerfection.linkedFacilities"
                          .tr(),
                  content: LinkedFacilities(viewModel: viewModel, info: info),
                  context: context,
                  actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButton(
                              label:
                                  "requestInformation.securityPerfection.save"
                                      .tr(),
                              onPressed: () {
                                viewModel
                                    .onSavePressedLinkedFacilities(context);
                              }),
                          const Gap(
                            size: GapSize.medium,
                            direction: Axis.horizontal,
                          ),
                          CustomButton(
                              label:
                                  "requestInformation.securityPerfection.cancel"
                                      .tr(),
                              onPressed: () {
                                // viewModel.onCancelButtonPressed(context);
                                context.pop();
                              })
                        ],
                      ),
                    ])
              : logger.i("noclick");
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.textFieldBorder),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.attach_file,
            size: 16,
            color: AppColors.buttonBackground,
          ),
        ),
      ),
    );
  }
}
