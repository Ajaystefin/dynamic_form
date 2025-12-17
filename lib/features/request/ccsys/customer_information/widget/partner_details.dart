import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class PartnerDetails extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const PartnerDetails({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "Partner / Shareholder Details",
      child: CustomRawTable(
        columns: getTableColumns(),
        headerFontSize: AppStyle.columnName,
        rows: [
          [
            const CustomTextField(
              initialValue: "John",
            ),
            CustomDropdown<Reference>(
              validationMessage:
                  "customerInformation.customerInformation.selectOwnerName"
                      .tr(),
              isEnabled: true,
              items: viewModel.residencyStatus,
              itemBuilder: (context, item, isDisabled, isSelected) {
                return dropdownItemBuildWidget(item.name);
              },
              onSelected: (selectedValue) {},
              dropdownBuilder: (context, item) =>
                  dropdownBuilderWidget(text: item?.name, showToolTip: false),
              selectedItems: null,
            ),
            CustomDropdown<Reference>(
              validationMessage:
                  "customerInformation.customerInformation.selectOwnerName"
                      .tr(),
              isEnabled: true,
              items: viewModel.shareholderTypes,
              itemBuilder: (context, item, isDisabled, isSelected) {
                return dropdownItemBuildWidget(item.name);
              },
              onSelected: (selectedValue) {},
              dropdownBuilder: (context, item) =>
                  dropdownBuilderWidget(text: item?.name, showToolTip: false),
              selectedItems: null,
            ),
            CustomTextField(
              initialValue: "75",
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d{1,3}$')),
              ],
            ),
            CustomTextField(
              initialValue: "150000.50",
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            CustomDropdown<Reference>(
              validationMessage:
                  "customerInformation.customerInformation.selectOwnerName"
                      .tr(),
              isEnabled: true,
              items: viewModel.legalStatusPartners,
              itemBuilder: (context, item, isDisabled, isSelected) {
                return dropdownItemBuildWidget(item.name);
              },
              onSelected: (selectedValue) {},
              dropdownBuilder: (context, item) =>
                  dropdownBuilderWidget(text: item?.name, showToolTip: false),
              selectedItems: null,
            ),
            const CustomTextField(initialValue: "784-1234-5678901-2"),
            CustomDatePicker(
              initialDateTime: DateTime.now().add(const Duration(days: 365)),
              blockedDates: const [],
              dateFormat: 'dd/MM/yyyy',
              onSubmit2: (_) {},
            ),
            const CustomTextField(initialValue: "AK00000/CA"),
            CustomDatePicker(
              initialDateTime: DateTime.now().add(const Duration(days: 730)),
              blockedDates: const [],
              dateFormat: 'dd/MM/yyyy',
              onSubmit2: (_) {},
            ),
            const SizedBox(),
            const CustomTextField(initialValue: "TL123456"),
            const SizedBox(),
            CustomRadioButton<Reference>(
              scrollDirection: Axis.horizontal,
              options: viewModel.radioButtonItems,
              itemBuilder: (context, item, isSelected, isEnabled) =>
                  Text(item.name ?? ''),
              selectedValue: viewModel.radioButtonItems[0],
              onChanged: (Reference psLei) {
                viewModel.customerInformation.radioButtonItems = psLei;
              },
            ),
            const CustomTextField(initialValue: "LEI123456789"),
            CustomDropdown<Reference>(
              validationMessage:
                  "customerInformation.customerInformation.selectOwnerName"
                      .tr(),
              isEnabled: true,
              items: viewModel.genders,
              itemBuilder: (context, item, isDisabled, isSelected) {
                return dropdownItemBuildWidget(item.name);
              },
              onSelected: (selectedValue) {},
              dropdownBuilder: (context, item) =>
                  dropdownBuilderWidget(text: item?.name, showToolTip: false),
              selectedItems: null,
            )
          ],
        ],
      ),
    );
  }

  List<TableColumn> getTableColumns() {
    return [
      const TableColumn(
        label: Text("Name (in English)"),
      ),
      TableColumn(label: const Text("Residence"), forcedWidth: 120.w),
      TableColumn(label: const Text("Type"), forcedWidth: 120.w),
      const TableColumn(
        label: Text("Holding (%)"),
      ),
      const TableColumn(
        label: Text("Networth (In AED)"),
      ),
      TableColumn(label: const Text("Legal Status"), forcedWidth: 120.w),
      const TableColumn(
        label: Text("Emirates ID"),
      ),
      const TableColumn(
        label: Text("Emirates ID Expiry Date"),
      ),
      const TableColumn(
        label: Text("Passport Number / Country Code"),
      ),
      const TableColumn(
        label: Text("Passport Expiry Date"),
      ),
      TableColumn(label: const Text("Nationality"), forcedWidth: 120.w),
      const TableColumn(label: Text("TL Number")),
      const TableColumn(
        label: Text("Place of Issue of TL No."),
      ),
      const TableColumn(
        label: Text("LE Identifier"),
      ),
      const TableColumn(
        label: Text("LEI Number"),
      ),
      TableColumn(label: const Text("Gender"), forcedWidth: 80.w),
    ];
  }
}
