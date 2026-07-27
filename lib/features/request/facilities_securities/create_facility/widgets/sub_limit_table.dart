import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/sub_types_checkbox.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/allocate_limit_dialog_box.dart";
import "package:wcas_frontend/features/request/facilities_securities/sublimit_conditions_dialog/view.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";

/// Widget for displaying and managing facility subtype entries.
class FacilitySubTypeTable extends StatelessWidget {
  /// Creates a facility subtype table widget.
  const FacilitySubTypeTable({
    required this.viewModel,
    super.key,
  });

  /// View model containing facility subtype data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool canOpenAllocationDialog = Utils.isGroupApplication() &&
        viewModel.isAnnualReview &&
        viewModel.getFacility.sharedLimit?.id == ServerConstants.optionYESid;

    final bool hasAnySelectedSubType =
        viewModel.facilitySubTypes.any((f) => f.subTypeSelected ?? false);

    final List<TableColumn> columns = <TableColumn>[
      TableColumn(
        forcedWidth: 210.w,
        label: const Text("Sub types"),
      ),
      TableColumn(
        forcedWidth: 110.w,
        label: const Text("Committment A/c No"),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: const Text("Current Outstanding "),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: const Text("Past Dues"),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: const Text("Existing Limits"),
      ),

      TableColumn(
        forcedWidth: 140.w,
        label: _headerText("Proposed Limit", required: hasAnySelectedSubType),
      ),

      TableColumn(
        forcedWidth: 180.w,
        label: const Text("Tenor"),
      ),

      // Benchmark / Index (Text only)
      TableColumn(
        forcedWidth: 160.w,
        label: _headerText("Benchmark", required: hasAnySelectedSubType),
      ),

      // Spread / Commission (Text only)
      TableColumn(
        forcedWidth: 150.w,
        label:
            _headerText("Spread/Commission", required: hasAnySelectedSubType),
      ),

      TableColumn(
        forcedWidth: 70.w,
        label: const Text("Allocate Limits"),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: const Text("Conditions"),
      ),
    ];

    return CustomRawTable(
      key: UniqueKey(),
      columns: columns,
      rowHeight: 50,
      rowsPerPage: 5,
      rows: List.generate(viewModel.facilitySubTypes.length, (index) {
        final NumberFormat numberFormatter = NumberFormat("#,###");
        final FacilitySubTypes currentSubType =
            viewModel.facilitySubTypes[index];
        final List<Reference> displayBenchmarkItems =
            viewModel.subTypeBenchmarkItemsForUi(index);

        final Reference? selectedBenchmarkReference =
            viewModel.selectedSubTypeBenchmarkForUi(index);
        final int proposedLimitAmount = currentSubType.proposedLimit ?? 0;
        final String selectedCurrencyCode =
            (currentSubType.currency ?? "AED").toUpperCase();
        final num rate = viewModel.rateForSubType(index);
        final String tooltipMsg = (selectedCurrencyCode != "AED" &&
                rate > 0 &&
                proposedLimitAmount > 0)
            ? "AED: ${numberFormatter.format((proposedLimitAmount * rate).toInt())}"
            : "";

        return [
          SubtypesCheckbox(
            viewModel: viewModel,
            facilitySubType: viewModel.facilitySubTypes[index],
          ),

          //commitment account number
          CustomDropdown<String>(
            key: ValueKey("accNo-$index"),
            showClearIcon: false,
            isEnabled:
                (viewModel.facilitySubTypes[index].subTypeSelected ?? false) ||
                    (viewModel.facilitySubTypes[index].alreadyExistingSubType ??
                        false),
            selectedItems: [
              viewModel.facilitySubTypes[index].commitmentAccountNumber,
            ],
            onSelected: (selectedValue) {
              if (selectedValue.isNotEmpty) {
                final String selectedCommitmentAccountNumber =
                    selectedValue.first.trim();
                viewModel.getFacility.commitmentAccountNumber =
                    Reference(name: selectedCommitmentAccountNumber);
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await viewModel.setCommitementAccountNumber(
                    selectedCommitmentAccountNumber,
                    index,
                  );
                });
              }
            },
            items: viewModel.commitmentAccountNumberItemsForUi,
            itemBuilder: (context, item, {isDisabled, isSelected}) {
              return dropdownItemBuildWidget(
                item,
                isSelected: isSelected ?? false,
              );
            },
            dropdownBuilder: (context, data) {
              return Text(
                data ?? "",
                style: const TextStyle(fontSize: 14),
              );
            },
          ),

          CustomTextField(
            readOnly: true,
            hintText:
                "${viewModel.facilitySubTypes[index].currentOutstanding ?? ""}",
          ),
          CustomTextField(
            readOnly: true,
            hintText: "${viewModel.facilitySubTypes[index].pastDues ?? ""}",
          ),
          CustomTextField(
            readOnly: true,
            hintText:
                "${viewModel.facilitySubTypes[index].existingAmounts ?? ""}",
          ),

          // proposed limit
          CustomTooltip(
            message: tooltipMsg,
            child: CustomTextField(
              textAlign: TextAlign.end,
              validator: (value) =>
                  viewModel.validateSubTypeProposedLimit(index, value),
              readOnly: !((viewModel.facilitySubTypes[index].subTypeSelected ??
                      false) ||
                  (viewModel.facilitySubTypes[index].alreadyExistingSubType ??
                      false)),
              initialValue: proposedLimitAmount > 0
                  ? numberFormatter.format(proposedLimitAmount)
                  : "",
              keyboardType: TextInputType.number,
              controller: viewModel.proposedLimitControllerFor(index),
              inputFormatters: [
                LengthLimitingTextInputFormatter(15),
                ThousandsSeparatorFormatter(),
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) =>
                  viewModel.onSubTypeProposedLimitChanged(index, value),
              prefixIcon: Builder(
                builder: (cellCtx) => CustomDropdown<Reference>(
                  key: ValueKey("currency-$index"),
                  showClearIcon: false,
                  isEnabled:
                      (viewModel.facilitySubTypes[index].subTypeSelected ??
                              false) ||
                          (viewModel.facilitySubTypes[index]
                                  .alreadyExistingSubType ??
                              false),
                  validationMessage: "",
                  width: 70.w,
                  height: null,
                  items: viewModel.currencyCodes,
                  selectedItems: [
                    matchOrFirstByName(
                      viewModel.currencyCodes,
                      currentSubType.currency ?? "AED",
                    ),
                  ],
                  onSelected: (selectedValue) async {
                    if (selectedValue.isNotEmpty) {
                      final Reference selectedRef = selectedValue.first;
                      currentSubType.currency = selectedRef.name;
                      await viewModel.getSubTypeCurrencyRate(
                        index,
                        selectedRef,
                      );
                    }
                  },
                  itemBuilder: (context, item, {isDisabled, isSelected}) {
                    return dropdownMultiItemBuildWidget(
                      item.name,
                      isSelected: isSelected ?? false,
                    );
                  },
                  dropdownBuilder: (context, data) {
                    return Text(
                      data?.name ?? "",
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
            ),
          ),

          //tenor days ---editable
          CustomTextField(
            readOnly: !((viewModel.facilitySubTypes[index].subTypeSelected ??
                    false) ||
                (viewModel.facilitySubTypes[index].alreadyExistingSubType ??
                    false)),
            initialValue:
                "${viewModel.facilitySubTypes[index].tenorValue ?? ""}",
            keyboardType: TextInputType.number,
            onChanged: (String value) {
              viewModel.facilitySubTypes[index].tenorValue =
                  int.tryParse(value);
            },
            prefixIcon: Builder(
              builder: (cellCtx) {
                //  determine whether product is Overdraft

                final String facilityDescriptionRef4 =
                    (viewModel.getFacility.facilityDescription?.reference4 ??
                            "")
                        .trim()
                        .toLowerCase();
                final bool isOverdraft =
                    facilityDescriptionRef4 == "overdraft".toLowerCase();

                //  filter "On Demand" when NOT Overdraft
                final List<Reference> availableTenorUnits = isOverdraft
                    ? viewModel.period
                    : viewModel.period
                        .where(
                          (r) =>
                              (r.name ?? "").trim().toLowerCase() !=
                              "on demand",
                        )
                        .toList();

                final Reference selectedTenorUnit = matchOrFirstByName(
                  availableTenorUnits,
                  viewModel.facilitySubTypes[index].tenorUnit,
                );

                return CustomDropdown<Reference>(
                  key: ValueKey("tenorUnit-$index"),
                  showClearIcon: false,
                  isEnabled:
                      (viewModel.facilitySubTypes[index].subTypeSelected ??
                              false) ||
                          !(viewModel.facilitySubTypes[index]
                                  .alreadyExistingSubType ??
                              false),
                  width: 100.w,
                  height: null,
                  items: availableTenorUnits,
                  selectedItems: [
                    selectedTenorUnit,
                  ],
                  onSelected: (selectedValue) {
                    if (selectedValue.isNotEmpty) {
                      final Reference sel = selectedValue.first;
                      viewModel.facilitySubTypes[index].tenorUnit = sel.name;
                    }
                  },
                  itemBuilder: (context, item, {isDisabled, isSelected}) {
                    return dropdownMultiItemBuildWidget(
                      item.name,
                      isSelected: isSelected ?? false,
                    );
                  },
                  dropdownBuilder: (context, data) {
                    return Text(
                      data?.name ?? "",
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                );
              },
            ),
          ),

          //benchmark -------editable
          CustomDropdown<Reference>(
            key: ValueKey("benchmark-$index"),
            showClearIcon: false,
            isEnabled:
                (viewModel.facilitySubTypes[index].subTypeSelected ?? false) ||
                    (viewModel.facilitySubTypes[index].alreadyExistingSubType ??
                        false),
            items: displayBenchmarkItems,
            validationMessage:
                (viewModel.facilitySubTypes[index].subTypeSelected ?? false) ||
                        (viewModel.facilitySubTypes[index]
                                .alreadyExistingSubType ??
                            false)
                    ? "common.validation.emptyField".tr()
                    : null,
            selectedItems: selectedBenchmarkReference != null
                ? [selectedBenchmarkReference]
                : const [],
            onSelected: (selectedValue) {
              if (selectedValue.isNotEmpty) {
                final Reference selectedBenchmark = selectedValue.first;
                viewModel.facilitySubTypes[index].index =
                    selectedBenchmark.id?.toString() ??
                        selectedBenchmark.name ??
                        "";
              }
            },
            itemBuilder: (context, item, {isDisabled, isSelected}) {
              return dropdownItemBuildWidget(
                item.name,
                isSelected: isSelected ?? false,
              );
            },
            dropdownBuilder: (context, data) {
              return Text(
                data?.name ?? "",
                style: const TextStyle(fontSize: 14),
              );
            },
          ),

          //spread -------editable
          CustomTextField(
            readOnly: !((viewModel.facilitySubTypes[index].subTypeSelected ??
                    false) ||
                (viewModel.facilitySubTypes[index].alreadyExistingSubType ??
                    false)),
            validator: (value) {
              final bool selected = (viewModel
                          .facilitySubTypes[index].subTypeSelected ??
                      false) ||
                  (viewModel.facilitySubTypes[index].alreadyExistingSubType ??
                      false);
              if (!selected) {
                return null;
              }
              final bool has = (value ?? "").trim().isNotEmpty;
              return has ? null : "common.validation.emptyField".tr();
            },
            prefixIcon: Builder(
              builder: (cellCtx) => CustomDropdown<Reference>(
                key: ValueKey("marginSign-$index"),
                showClearIcon: false,
                isEnabled: (viewModel.facilitySubTypes[index].subTypeSelected ??
                        false) ||
                    (viewModel.facilitySubTypes[index].alreadyExistingSubType ??
                        false),
                width: 60.w,
                height: null,
                items: viewModel.marginSign,
                selectedItems: [
                  matchOrFirstByRef1(
                    viewModel.marginSign,
                    viewModel.facilitySubTypes[index].marginSign,
                  ),
                ],
                onSelected: (selectedValue) {
                  if (selectedValue.isNotEmpty) {
                    final Reference sel = selectedValue.first;
                    viewModel.facilitySubTypes[index].marginSign =
                        sel.reference1;
                  }
                },
                itemBuilder: (context, item, {isDisabled, isSelected}) {
                  return dropdownMultiItemBuildWidget(
                    item.reference1,
                    isSelected: isSelected ?? false,
                  );
                },
                dropdownBuilder: (context, data) {
                  return Text(
                    data?.reference1 ?? "",
                    style: const TextStyle(fontSize: 20),
                  );
                },
              ),
            ),
            initialValue:
                (viewModel.facilitySubTypes[index].marginValue != null)
                    ? "${viewModel.facilitySubTypes[index].marginValue}"
                    : "",
            keyboardType: TextInputType.number,
            onChanged: (String? value) {
              final RegExpMatch? match =
                  RegExp(r"[-]?\d*\.?\d").firstMatch(value ?? "");
              viewModel.facilitySubTypes[index].marginValue = match?.group(0);
            },
          ),

          TextButton(
            onPressed: (canOpenAllocationDialog &&
                    ((viewModel.facilitySubTypes[index].subTypeSelected ??
                            false) ||
                        (viewModel.facilitySubTypes[index]
                                .alreadyExistingSubType ??
                            false)))
                ? () {
                    DialogHelper.showCustomDialog(
                      barrierDismissible: false,
                      title: "facilities.createFacility.limitAllocation".tr(),
                      content: BlocProvider.value(
                        value: viewModel,
                        child: AllocateLimitDialogBox(
                          viewModel: viewModel,
                          rowIndex: index,
                        ),
                      ),
                      context: context,
                    );
                  }
                : null, // disables the button when condition is false
            child: Text(
              "click here",
              style: TextStyle(
                decoration: TextDecoration.underline,
                decorationColor:
                    ((viewModel.facilitySubTypes[index].subTypeSelected ??
                                false) ||
                            (viewModel.facilitySubTypes[index]
                                    .alreadyExistingSubType ??
                                false))
                        ? AppColors.darkBlue
                        : AppColors.darkGrey,
                fontSize: AppStyle.fontSizeSmall,
              ),
            ),
          ),
// Conditions
          TextButton(
            onPressed: (viewModel.facilitySubTypes[index].subTypeSelected ??
                        false) ||
                    (viewModel.facilitySubTypes[index].alreadyExistingSubType ??
                        false)
                ? () async {
                    await viewModel.getFacilityConditionsList(
                      isSubLimitTable: true,
                      limitCode: viewModel.facilitySubTypes[index].limitCode,
                    );
                    if (context.mounted) {
                      await DialogHelper.showCustomDialog(
                        width: 700.w,
                        barrierDismissible: false,
                        title: "facilities.createFacility.limitAllocation".tr(),
                        content: BlocProvider.value(
                          value: viewModel,
                          child: ConditionsDialog(
                            createFacilityViewModel: viewModel,
                            rowIndex: index,
                          ),
                        ),
                        context: context,
                      );
                    }
                  }
                : null,
            child: Text(
              "click here",
              style: TextStyle(
                decoration: TextDecoration.underline,
                decorationColor:
                    (viewModel.facilitySubTypes[index].subTypeSelected ??
                                false) ||
                            (viewModel.facilitySubTypes[index]
                                    .alreadyExistingSubType ??
                                false)
                        ? AppColors.darkBlue
                        : AppColors.darkGrey,
                fontSize: AppStyle.fontSizeSmall,
              ),
            ),
          ),
        ];
      }),
    );
  }
}

Text _headerText(String title, {bool required = false}) {
  return Text.rich(
    TextSpan(
      text: title,
      children: required
          ? const [
              TextSpan(
                text: " *",
                // color your asterisk only; base text style remains table
                // default
                style: TextStyle(color: AppColors.failure),
              ),
            ]
          : const [],
    ),
  );
}

/// Returns the first reference that matches the provided reference value.
///
/// If no match is found, the first item in the list is returned.
/// Returns an empty [Reference] when the list is empty.
Reference matchOrFirstByRef1(List<Reference> list, String? ref1) {
  if (list.isEmpty) {
    return Reference();
  }
  if ((ref1 ?? "").isEmpty) {
    return list.first;
  }
  final String lower = ref1!.trim().toLowerCase();
  return list.firstWhere(
    (r) => (r.reference1 ?? "").trim().toLowerCase() == lower,
    orElse: () => list.first,
  );
}

/// Returns the first reference that matches the provided name.
///
/// If no match is found, the first item in the list is returned.
/// Returns an empty [Reference] when the list is empty.
Reference matchOrFirstByName(List<Reference> list, String? name) {
  if (list.isEmpty) {
    return Reference();
  }
  if ((name ?? "").isEmpty) {
    return list.first;
  }
  final String target = name!.trim().toLowerCase();
  return list.firstWhere(
    (r) => (r.name ?? "").trim().toLowerCase() == target,
    orElse: () => list.first,
  );
}
