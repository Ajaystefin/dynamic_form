import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/identification_dropdown.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/nationality_dropdown.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/country.dart';
import 'package:wcas_frontend/models/request/customer.dart';

class OwnershipDetailsTable extends StatelessWidget {
  final CustomerInfoViewModel viewModel;
  final List<CustomerOwnerShipInfo>? row;

  const OwnershipDetailsTable({
    super.key,
    required this.row,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      "customerInformation.customerInformation.yes".tr(),
      "customerInformation.customerInformation.no".tr()
    ];

    return LabelWidget(
      label: "customerInformation.customerInformation.ownershipDetails".tr(),
      isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
      child: CustomRawTable(
        key: UniqueKey(),
        autoFitWidth: true,
        headerFontSize: AppStyle.columnName,
        columnHeaderHeight: 55.w,
        columns: getTableColumns(),
        rows: List.generate(row?.length ?? 0, (index) {
          viewModel.rimControllers = List.generate(row?.length ?? 0, (index) {
            final rimValue =
                viewModel.customerOwnerShipInfo?[index].custOwnershipRim;
            final textValue =
                (rimValue == null || rimValue == -1 || rimValue == 0)
                    ? ''
                    : rimValue.toString();
            return TextEditingController(text: textValue);
          });

          if (viewModel.checkboxes.length < row!.length) {
            viewModel.checkboxes.addAll(List.generate(
              row!.length - viewModel.checkboxes.length,
              (_) => true,
            ));
          }

          CustomerOwnerShipInfo? owner =
              viewModel.customerOwnerShipInfo?[index];

          viewModel.residentCountryCode = owner?.nationality?.trim();

          Country? selectedCountry;
          var matches = viewModel.countries?.where(
              (c) => c.code?.trim() == viewModel.residentCountryCode?.trim());

          if (matches != null && matches.isNotEmpty) {
            selectedCountry = matches.first;
          }

          final isCheckboxChecked = (owner?.rim ?? 0) != 0;
          final isEditable = owner?.isNewlyAdded == true && !isCheckboxChecked;

          return [
            Theme(
              data: Theme.of(context).copyWith(
                disabledColor:
                    AppColors.textFieldDisabledFill, // visually greyed out
              ),
              child: Checkbox(
                value: (owner?.rim ?? 0) != 0,
                onChanged: owner?.isNewlyAdded == true
                    ? (bool? newValue) {
                        viewModel.updateOwnershipRim(index, newValue ?? false);
                      }
                    : null,
              ),
            ),
            CustomTextField(
              maxLength: 15,
              controller: viewModel.rimControllers[index],
              readOnly: owner?.isNewlyAdded == true
                  ? viewModel.rimFound
                      ? true
                      : isEditable
                  : true,
              filled: owner?.isNewlyAdded == true
                  ? viewModel.rimFound
                      ? true
                      : isEditable
                  : true,
              suffixIcon: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: InkWell(
                    onTap: () async {
                      viewModel.rimControllers[index].text;
                      index;
                      await viewModel.updateRimNo(
                          viewModel.rimControllers[index].text, index);
                    },
                    child: const Icon(
                      Icons.search_rounded,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              initialValue: (owner?.custOwnershipRim != null &&
                      owner!.custOwnershipRim! > 1)
                  ? '${owner.custOwnershipRim}'
                  : '',
            ),
            CustomTextField(
              maxLength: 50,
              readOnly: owner?.isNewlyAdded == true ? !isEditable : true,
              filled: owner?.isNewlyAdded == true ? !isEditable : true,
              initialValue: owner?.custOwnershipName,
              // onSubmitted: (value) {
              //   owner?.custOwnershipName = value;
              // },
              onSaved: (value) {
                owner?.custOwnershipName = value;
              },
              validator: CustomValidator.requiredField,
            ),
            CustomDropdown<Reference>(
              key: ValueKey("owner_dropdown_$index"),
              validationMessage:
                  "customerInformation.customerInformation.selectOwnerType"
                      .tr(),
              // isEnabled: owner?.isNewlyAdded == true ? isEditable : false,
              items: viewModel.referenceData[ReferenceDataKeys.ownerType] ?? [],
              itemBuilder: (context, item, isDisabled, isSelected) {
                return dropdownItemBuildWidget(item.name);
              },
              onSelected: (selectedValue) {
                owner?.custOwnershipType =
                    (selectedValue.first).name.toString();
              },
              dropdownBuilder: (context, item) =>
                  dropdownBuilderWidget(text: item?.name, showToolTip: false),
              selectedItems: owner?.custOwnershipType != null
                  ? [Reference(name: owner?.custOwnershipType)]
                  : null,
            ),
            NationalityDropdown(
              key: ValueKey("nationality_dropdown_$index"),
              viewModel: viewModel,
              initial: selectedCountry?.description ?? owner?.nationality ?? '',
              selectedNationality: selectedCountry,
              isEnabled: (owner?.nationality == null ||
                      owner!.nationality.toString().trim().isEmpty ||
                      owner.rim == null ||
                      owner.rim == 0)
                  ? true
                  : false,
              index: index,
              onSelected: (selectedCountry) {
                owner?.nationality = selectedCountry.code;
              },
            ),
            CustomTextField(
              controller: TextEditingController(
                  text: '${owner?.shareHoldingPercentage}'),
              // readOnly: owner?.isNewlyAdded == true ? !isEditable : false,
              // filled: owner?.isNewlyAdded == true ? !isEditable : false,

              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final text = newValue.text;

                  // Allow empty while typing/backspacing
                  if (text.isEmpty) return newValue;

                  // Allow only digits with optional decimal part (up to 2 places)
                  final matchesPattern =
                      RegExp(r'^\d{0,3}(\.\d{0,2})?$').hasMatch(text);
                  if (!matchesPattern) return oldValue;

                  // If "100", no decimals allowed
                  if (text == '100') return newValue;
                  if (text.startsWith('100.')) return oldValue;

                  // Parse number and enforce max <= 100
                  final value = double.tryParse(text);
                  if (value == null) return oldValue;

                  // Disallow any value greater than 100
                  if (value > 100) return oldValue;

                  // Otherwise allow (e.g., 0–99.99, 99.25, 12, 12.3, 12.34)
                  return newValue;
                }),
              ],

              onChanged: (String value) {
                viewModel.customerOwnerShipInfo?[index].shareHoldingPercentage =
                    double.tryParse(value);
              },
              validator: (value) {
                return viewModel.shareHoldingPercentageValidator(value);
              },
            ),
            CustomDropdown<String>(
              key: ValueKey("resident_dropdown_$index"),
              validationMessage:
                  "customerInformation.customerInformation.selectResident".tr(),
              items: items,
              isEnabled: owner?.isNewlyAdded == true ? isEditable : false,
              selectedItems: owner?.resident == 'y'
                  ? ["customerInformation.customerInformation.yes".tr()]
                  : owner?.resident == 'n'
                      ? ["customerInformation.customerInformation.no".tr()]
                      : [],
              onSelected: (selectedValue) {
                final value = selectedValue[0];
                final mappedValue = value ==
                        "customerInformation.customerInformation.yes".tr()
                    ? ServerConstants.residentYes
                    : value == "customerInformation.customerInformation.no".tr()
                        ? ServerConstants.residentNo
                        : value;
                viewModel.customerOwnerShipInfo?[index].resident = mappedValue;
                // viewModel.updateOwnerResidentAt(index, mappedValue);
              },
            ),
            CustomTextField(
              controller: TextEditingController(
                  text: '${owner?.beneficialOwnerhipPercentage}'),
              // readOnly: owner?.isNewlyAdded == true ? !isEditable : false,
              // filled: owner?.isNewlyAdded == true ? !isEditable : false,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final text = newValue.text;

                  // Allow empty while typing/backspacing
                  if (text.isEmpty) return newValue;

                  // Allow only digits with optional decimal part (up to 2 places)
                  final matchesPattern =
                      RegExp(r'^\d{0,3}(\.\d{0,2})?$').hasMatch(text);
                  if (!matchesPattern) return oldValue;

                  // If "100", no decimals allowed
                  if (text == '100') return newValue;
                  if (text.startsWith('100.')) return oldValue;

                  // Parse number and enforce max <= 100
                  final value = double.tryParse(text);
                  if (value == null) return oldValue;

                  // Disallow any value greater than 100
                  if (value > 100) return oldValue;

                  // Otherwise allow (e.g., 0–99.99, 99.25, 12, 12.3, 12.34)
                  return newValue;
                }),
              ],
              onChanged: (String value) {
                viewModel.customerOwnerShipInfo?[index]
                    .beneficialOwnerhipPercentage = double.tryParse(value);
              },
              validator: (String? value) {
                return viewModel.beneficialOwnerhipPercentageValidator(value);
              },
              // onSubmitted: (String? value) {
              // viewModel.beneficialOwnerhipPercentageValidator(value);
              // final parsed = double.tryParse(value);
              // final other = owner?.shareHoldingPercentage ?? 0;

              // if (parsed != null && parsed + other == 100) {
              //   owner?.beneficialOwnerhipPercentage = parsed;
              // } else {
              //   // Optionally show error or revert input
              // }
              // },
            ),
            IdentificationDropdown(
              owner: owner!,
              index: index,
              isEnabled:
                  owner.rim == null || owner.rim == 0
                      ? true
                      : false,
              viewModel: viewModel,
            ),
            CustomTextField(
              maxLength: 50,
              readOnly:
                  owner.rim == null || owner.rim == 0
                      ? false
                      : true,
              filled:
                  owner.rim == null || owner.rim == 0
                      ? false
                      : true,
              initialValue: owner.identificationNumber,
              onChanged: (value) {
                owner.identificationNumber = value;
              },
            ),
            Center(
              child: IconButton(
                onPressed: () {
                  viewModel.removeOwnershipTableRow(index);
                  viewModel.removeCheckbox(index);
                },
                icon: const Icon(Icons.delete),
              ),
            ),
          ];
        }),
      ),
    );
  }

  Widget addAsterisk(String text) {
    return Text.rich(
      TextSpan(
        text: text,
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: AppColors.failure),
          ),
        ],
      ),
      softWrap: true,
    );
  }

  List<TableColumn> getTableColumns() {
    return [
      TableColumn(
          label: Text(
              key: UniqueKey(),
              "customerInformation.customerInformation.hasRIM".tr())),
      TableColumn(
          forcedWidth: 60.w,
          label: Text(
              key: UniqueKey(),
              "customerInformation.customerInformation.rimNo".tr())),
      TableColumn(
          forcedWidth: 60.w,
          label: addAsterisk(
              "customerInformation.customerInformation.ownersName".tr())),
      TableColumn(
          forcedWidth: 80.w,
          label: addAsterisk(
            "customerInformation.customerInformation.ownersType".tr(),
          )),
      TableColumn(
          forcedWidth: 105.w,
          label: addAsterisk(
            "customerInformation.customerInformation.nationality".tr(),
          )),
      TableColumn(
          forcedWidth: 50.w,
          label: addAsterisk(
            "customerInformation.customerInformation.shareHoldings".tr(),
          )),
      TableColumn(
          forcedWidth: 70.w,
          label: addAsterisk(
            "customerInformation.customerInformation.resident".tr(),
          )),
      TableColumn(
          forcedWidth: 45.w,
          label: addAsterisk(
            "customerInformation.customerInformation.beneficialOwnership".tr(),
          )),
      TableColumn(
          forcedWidth: 90.w,
          label: Text(
              key: UniqueKey(),
              "customerInformation.customerInformation.identificationDetails"
                  .tr())),
      TableColumn(
          forcedWidth: 57.w,
          label: Text(
              key: UniqueKey(),
              "customerInformation.customerInformation.identificationNumber"
                  .tr())),
      TableColumn(
          forcedWidth: 20.w,
          label: Text(
              key: UniqueKey(),
              "customerInformation.customerInformation.delete".tr())),
    ];
  }
}
