import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/identification_dropdown.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/nationality_dropdown.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/customer.dart";

class OwnershipDetailsTable extends StatelessWidget {
  const OwnershipDetailsTable({
    required this.viewModel,
    required this.row,
    super.key,
  });

  final CustomerInfoViewModel viewModel;
  final List<CustomerOwnerShipInfo>? row;

  @override
  Widget build(BuildContext context) {
    final List<String> yesNoItems = [
      "customerInformation.customerInformation.yes".tr(),
      "customerInformation.customerInformation.no".tr(),
    ];

    return LabelWidget(
      label: "customerInformation.customerInformation.ownershipDetails".tr(),
      isRequired: !viewModel.isFI,
      child: CustomRawTable(
        key: UniqueKey(), //const ValueKey('ownership_details_table'),
        autoFitWidth: true,
        columnHeaderHeight: 55.w,
        headerFontSize: AppStyle.columnName,
        columns: getTableColumns(),
        rows: List.generate(row?.length ?? 0, (index) {
          final owner = row![index];

          /// One-time Phoenix → UI init
          if (!owner.hasRimInitialized) {
            owner
              ..hasRim =
                  owner.custOwnershipRim != null && owner.custOwnershipRim! > 0
              ..hasRimInitialized = true;
          }

          final bool hasRimChecked = owner.hasRim;

          final bool enableRimField = hasRimChecked;
          final bool enableOwnerNameField = !hasRimChecked;

          viewModel
            ..ensureRimController(
              index,
              owner.custOwnershipRim,
              isNew: owner.isNewlyAdded == true,
            )
            ..residentCountryCode = owner.nationality?.trim();

          Country? selectedCountry;
          final matches = viewModel.countries?.where(
            (c) => c.code?.trim() == viewModel.residentCountryCode?.trim(),
          );

          if (matches != null && matches.isNotEmpty) {
            selectedCountry = matches.first;
          }

          return [
            /// ---------------- HAS RIM ----------------
            Checkbox(
              value: hasRimChecked,
              onChanged: (v) => viewModel.updateOwnershipRim(index, v ?? false),
            ),

            /// ---------------- RIM NO ----------------
            CustomTextField(
              controller: viewModel.rimControllers[index],
              readOnly: !enableRimField,
              filled: !enableRimField,
              suffixIcon: enableRimField
                  ? Padding(
                      padding: const EdgeInsets.all(4),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: InkWell(
                          onTap: () async {
                            await viewModel.updateRimNo(
                              viewModel.rimControllers[index].text,
                              index,
                            );
                          },
                          child: const Icon(
                            Icons.search_rounded,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),

            /// ---------------- OWNER NAME ----------------
            CustomTextField(
              maxLength: 50,
              readOnly: !enableOwnerNameField,
              filled: !enableOwnerNameField,
              initialValue: owner.custOwnershipName,
              onChanged: (v) => owner.custOwnershipName = v,
              validator: CustomValidator.requiredField,
            ),

            /// ---------------- OWNER TYPE (OPTIONAL) ----------------
            CustomDropdown<Reference>(
              key: ValueKey("owner_dropdown_$index"),
              items: viewModel.referenceData[ReferenceDataKeys.ownerType] ?? [],
              isEnabled: viewModel.canEdit,
              selectedItems: owner.custOwnershipType != null
                  ? [Reference(name: owner.custOwnershipType)]
                  : null,
              dropdownBuilder: (_, item) =>
                  dropdownBuilderWidget(text: item?.name),
              itemBuilder: (_, item, __, ___) =>
                  dropdownItemBuildWidget(item.name),
              onSelected: (val) => owner.custOwnershipType = val.first.name,
            ),

            /// ---------------- NATIONALITY ----------------
            NationalityDropdown(
              key: ValueKey("nationality_dropdown_$index"),
              viewModel: viewModel,
              index: index,
              selectedNationality: selectedCountry,
              initial: selectedCountry?.description ?? owner.nationality ?? "",
              isEnabled: true,
              onSelected: (c) => owner.nationality = c.code,
            ),

            /// ---------------- SHAREHOLDING % ----------------
            _percentageField(
              owner.shareHoldingPercentage,
              !viewModel.canEdit,
              (v) => owner.shareHoldingPercentage = v,
              viewModel.isFI ? null : viewModel.shareHoldingPercentageValidator,
            ),

            /// ---------------- RESIDENT ----------------
            CustomDropdown<String>(
              key: ValueKey("resident_dropdown_$index"),
              items: yesNoItems,
              isEnabled: true,
              selectedItems: owner.resident == "y"
                  ? [yesNoItems[0]]
                  : owner.resident == "n"
                      ? [yesNoItems[1]]
                      : [],
              onSelected: (v) =>
                  owner.resident = v.first == yesNoItems[0] ? "y" : "n",
              validationMessage:
                  "customerInformation.customerInformation.selectResident".tr(),
            ),

            /// ---------------- BENEFICIAL % ----------------
            _percentageField(
              owner.beneficialOwnerhipPercentage,
              !viewModel.canEdit,
              (v) => owner.beneficialOwnerhipPercentage = v,
              viewModel.isFI
                  ? null
                  : viewModel.beneficialOwnerhipPercentageValidator,
            ),

            /// ---------------- IDENTIFICATION DETAILS (OPTIONAL)
            /// ----------------
            IdentificationDropdown(
              owner: owner,
              index: index,
              viewModel: viewModel,
              isEnabled: true,
            ),

            /// ---------------- IDENTIFICATION NUMBER (OPTIONAL)
            /// ----------------
            CustomTextField(
              maxLength: 50,
              initialValue: owner.identificationNumber,
              onChanged: (v) => owner.identificationNumber = v,
            ),

            /// ---------------- DELETE ----------------
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => viewModel.removeOwnershipTableRow(index),
            ),
          ];
        }),
      ),
    );
  }

  /// ---------------- TABLE COLUMNS ----------------
  List<TableColumn> getTableColumns() => [
        TableColumn(
          label: Text(
            "customerInformation.customerInformation.hasRIM".tr(),
          ),
        ),
        TableColumn(
          forcedWidth: 60.w,
          label: Text(
            "customerInformation.customerInformation.rimNo".tr(),
          ),
        ),
        TableColumn(
          forcedWidth: 60.w,
          label: _asterisk(
            "customerInformation.customerInformation.ownersName".tr(),
          ),
        ),
        TableColumn(
          forcedWidth: 80.w,
          label: _asterisk(
            "customerInformation.customerInformation.ownersType".tr(),
          ),
        ),
        TableColumn(
          forcedWidth: 105.w,
          label: _asterisk(
            "customerInformation.customerInformation.nationality".tr(),
          ),
        ),
        TableColumn(
          forcedWidth: 50.w,
          label: _asterisk(
            "customerInformation.customerInformation.shareHoldings".tr(),
          ),
        ),
        TableColumn(
          forcedWidth: 70.w,
          label: _asterisk(
            "customerInformation.customerInformation.resident".tr(),
          ),
        ),
        TableColumn(
          forcedWidth: 45.w,
          label: _asterisk(
            "customerInformation.customerInformation.beneficialOwnership".tr(),
          ),
        ),
        TableColumn(
          forcedWidth: 90.w,
          label: Text(
            "customerInformation.customerInformation.identificationDetails"
                .tr(),
          ),
        ),
        TableColumn(
          forcedWidth: 57.w,
          label: Text(
            "customerInformation.customerInformation.identificationNumber".tr(),
          ),
        ),
        TableColumn(
          forcedWidth: 20.w,
          label: Text(
            "customerInformation.customerInformation.delete".tr(),
          ),
        ),
      ];

  Widget _asterisk(String text) {
    return viewModel.isFI
        ? Text(text)
        : Text.rich(
            TextSpan(
              text: text,
              children: const [
                TextSpan(
                  text: " *",
                  style: TextStyle(color: AppColors.failure),
                ),
              ],
            ),
          );
  }

  Widget _percentageField(
    double? value,
    bool readOnly,
    void Function(double?) onChange,
    String? Function(String?)? validator,
  ) =>
      CustomTextField(
        initialValue: value == null || value == 0 ? "" : value.toString(),
        readOnly: readOnly,
        filled: readOnly,
        inputFormatters: [
          TextInputFormatter.withFunction((oldValue, newValue) {
            final text = newValue.text;

            // Allow empty while typing/backspacing
            if (text.isEmpty) return newValue;

            // If user types exactly "0", clear the field
            if (text == "0" || oldValue.text == "0") {
              return const TextEditingValue(
                text: "",
                selection: TextSelection.collapsed(offset: 0),
              );
            }

            // Allow only digits with optional decimal part (up to 2 places)
            final matchesPattern =
                RegExp(r"^\d{0,3}(\.\d{0,2})?$").hasMatch(text);
            if (!matchesPattern) return oldValue;

            // If "100", no decimals allowed
            if (text == "100") return newValue;
            if (text.startsWith("100.")) return oldValue;

            // Parse number and enforce max <= 100
            final value = double.tryParse(text);
            if (value == null) return oldValue;

            // Disallow any value greater than 100
            if (value > 100) return oldValue;

            // Otherwise allow (e.g., 0–99.99, 99.25, 12, 12.3, 12.34)
            return newValue;
          }),
        ],
        onChanged: (v) => onChange(double.tryParse(v)),
        validator: validator,
      );
}
