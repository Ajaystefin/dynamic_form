import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/checkbox.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/information/security_perfection/model.dart';

class CovenantTable extends StatelessWidget {
  final SecurityPerfectionViewModel viewModel;
  const CovenantTable({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "requestInformation.securityPerfection.forCovenant".tr(),
      child: CustomRawTable(
        key: UniqueKey(),
        columns: [
          const TableColumn(label: Text("")),
          TableColumn(
              label: Text(
                  "requestInformation.securityPerfection.covenantNumber".tr())),
          TableColumn(
              label: Text(
                  "requestInformation.securityPerfection.covenantDescription"
                      .tr())),
          TableColumn(
              label: Text(
                  "requestInformation.securityPerfection.covenantDeferral"
                      .tr())),
        ],
        rows:
            List.generate(viewModel.securityDeferral.covenant!.length, (index) {
          final info = viewModel.securityDeferral.covenant![index];

          return [
            CustomCheckbox(
              value: info.isChecked,
              onChange: (value) {
                info.isChecked = value!;
                viewModel.updateTableStateChanges(); // triggers rebuild
              },
            ),
            Text(info.number.toString()),
            Text(info.description.toString()),
            info.isChecked
                ? CustomDatePicker(
                    key: UniqueKey(),
                    initialDateTime: info.date,
                    blockedDates: const [],
                    onSubmit2: (date) {
                      info.date = date;
                    },
                    validator: CustomValidator.date,
                  )
                : const CustomTextField(
                    initialValue: '',
                    filled: true,
                    readOnly: true,
                    fillColor: AppColors.textFieldDisabledFill,
                  ),
          ];
        }),
      ),
    );
  }
}
