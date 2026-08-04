import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/view.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/add_facility_button.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/add_sublimit_button.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/create_facility_button.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/currency_amount_cell.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/delete_facility_button.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/filter_table.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";

final NumberFormat _kFmt = NumberFormat("#,###");

/// Reusable facility-group table for non-project groups:
/// - General Working Capital (11312)
/// - Term Loans (11313)
/// - PFE Limits (11314)
///
/// Responsibilities:
/// - Render a table of FacilityDis rows (excluding non-facility rows such as Limit Caps/CLT)
/// - Provide per-row edit controls for editable roles (PageMode.edit)
/// - Show tooltips for changed values (via ViewModel tooltip cache)
///
/// Business rules & validations follow the Facility Summary FSD:
/// - Main/Sub-limit hierarchy via controlling limit number
/// - Mandatory fields conditional on product/category
/// - Proposed values are editable only for authorized roles/assignments
///
/// Widget for displaying facility limits in a tabular format.
///
/// Supports grouping facilities by limit group and provides configurable
/// column sizing for proposed limit and tenor values.
class FacilityLimitsTable extends StatelessWidget {
  /// Creates a facility limits table widget.
  const FacilityLimitsTable({
    required this.viewModel,
    required this.customer,
    required this.groupId,
    required this.groupIndex,
    super.key,
    this.autoFitWidth = true,
    this.proposedColumnWidth,
    this.tenorColumnWidth,
  });

  /// View model containing facility summary data and actions.
  final FacilitiesSummaryViewModel viewModel;

  /// Customer whose facility limits are displayed in the table.
  final FacilitySummaryList customer;

  /// Identifier of the limit group.
  ///
  /// Examples: `11312`, `11313`, `11314`.
  final int groupId;

  /// Index used to retrieve the corresponding group from the customer data.
  final int groupIndex;

  /// Indicates whether table columns should automatically adjust their width.
  final bool autoFitWidth;

  /// Custom width for the proposed limit column.
  final double? proposedColumnWidth;

  /// Custom width for the tenor column.
  final double? tenorColumnWidth;

  @override
  Widget build(BuildContext context) {
    final RimSummary? rim = viewModel.firstRimOfCustomer(customer);
    final RimGroup? group = viewModel.groupByIndex(rim, groupIndex);

    final String title = (group?.groupName ?? "").trim();
    final int? rimNo = viewModel.resolveRimNo(rim);

    // Computed from the unfiltered group so a filter that matches nothing
    // leaves the table (and its filter row) on screen instead of swapping in
    // the "create facility" box.
    final bool hasApiLimits = viewModel.hasNonExcludedRows(group);
    final String scopeKey = viewModel.groupFilterKey(groupId, rimNo);

    return CustomAccordion(
      isSubSection: true,
      title: title,
      textColor: AppColors.primary,
      children: [
        const Gap(),
        if (hasApiLimits)
          CustomRawTable(
            // The filter signature is part of the key so CustomRawTable, which
            // only reads its rows in initState, remounts when the filter
            // changes — and only then, preserving in-progress cell edits.
            key: ValueKey(
              "tbl-$groupId-${customer.hashCode}-$groupIndex"
              "-${viewModel.facilityFilterSignature(scopeKey)}",
            ),
            autoFitWidth: autoFitWidth,
            rowHeight: 46,
            isFilterTable: true,
            columns: _columns(),
            rows: _rows(context, group, rimNo, scopeKey),
          )
        else
          AddFacilitySubLimitBox(
            label: "facilities.facilitySummary.createFacility".tr(),
            limitGroup: groupId,
            selectedRim: rimNo,
            isMainLimit: true,
          ),
        const Gap(),
        if (hasApiLimits && viewModel.canEdit)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AddFacilityButton(
                viewModel: viewModel,
                limitGroup: groupId,
                selectedRim: rimNo,
                isMainLimit: true,
              ),
              CustomButton(
                label: "common.save".tr(),
                onPressed: () {
                  final bool? isValid =
                      viewModel.formKey.currentState?.validate();
                  if (isValid == false) {
                    AlertManager().showFailureToast(
                      "facilities.facilitySummary.fillRequiredFields".tr(),
                    );
                    return;
                  }
                  viewModel.saveFacilitySummaryList(
                    customer,
                    limitGroup: groupId,
                    selectedRim: rimNo,
                  );
                },
              ),
            ],
          ),
      ],
    );
  }

  List<TableColumn> _columns() {
    return [
      TableColumn(label: Text("facilities.facilitySummary.sNo".tr())),
      TableColumn(label: Text("facilities.facilitySummary.limitNo".tr())),
      const TableColumn(label: Text("Controlling Limit Number")),
      TableColumn(label: Text("facilities.facilitySummary.addSublimit".tr())),
      TableColumn(
        label: Text(
          "facilities.facilitySummary.limitDescription".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "facilities.facilitySummary.existingLimits".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: proposedColumnWidth ?? 155.w,
        label: Text("facilities.facilitySummary.proposedLimits".tr()),
      ),
      TableColumn(label: Text("facilities.facilitySummary.os".tr())),
      TableColumn(
        label: Text(
          "facilities.facilitySummary.classification".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: tenorColumnWidth,
        label: Text("facilities.facilitySummary.tenorDays".tr()),
      ),
      TableColumn(
        label: Text(
          "facilities.facilitySummary.applicablePricing".tr(),
        ),
      ),
      const TableColumn(label: Text("Spread/Commision")),
      TableColumn(
        label: Text(
          "facilities.facilitySummary.linkedFacility".tr(),
        ),
      ),
      TableColumn(label: Text("facilities.facilitySummary.action".tr())),
    ];
  }

  Widget _filter(String scopeKey, FacilityFilterField field) =>
      FilterTableWidget.forField(
        viewModel: viewModel,
        scopeKey: scopeKey,
        field: field,
      );

  List<List<Widget>> _rows(
    BuildContext context,
    RimGroup? group,
    int? rimNo,
    String scopeKey,
  ) {
    final List<List<Widget>> rows = <List<Widget>>[
      [
        const SizedBox.shrink(),
        _filter(scopeKey, FacilityFilterField.limitNo),
        _filter(scopeKey, FacilityFilterField.controllingLimitNo),
        const SizedBox.shrink(),
        _filter(scopeKey, FacilityFilterField.limitDescription),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
      ],
    ];

    // Parent lookups resolve against the unfiltered list so a filtered out
    // parent does not change a visible row's controlling limit cap.
    final List<FacilityDis> groupDisList =
        viewModel.filteredSortedDisList(group);
    final List<FacilityDis> apiDisList =
        viewModel.applyFacilityFilters(scopeKey, groupDisList);
    final GroupAmounts totals = group?.amounts ?? GroupAmounts();
    for (final FacilityDis facilityRow in apiDisList) {
      final FacilitySummaryNew? facilitySummary = facilityRow.facility;
      final FacilityDis facilityDis = facilityRow;
      if (facilitySummary == null) {
        continue;
      }

      final List<Reference> selectedSust = viewModel
          .sustainabilityRefs(facilitySummary.sustainabilityClassification);

      final bool requireIndex = viewModel
                  .facilityTypeNameById(facilitySummary.limitDescription)
                  .reference5 !=
              ServerConstants.newProductCode &&
          (facilitySummary.limitCategory?.toUpperCase() == "F");

      final bool isF = (facilitySummary.limitCategory?.toUpperCase() == "F");
      final int? parentCap = viewModel.resolveParentCap(
        facilitySummary.controllingLimitNo,
        groupDisList,
      );

// Filter benchmark list by limitCategory (F / N) for this row
      final List<Reference> benchmarkItems =
          viewModel.benchmarkForLimitCategory(facilitySummary.limitCategory);

// Current saved index from API / model
      final String selectedIndexId = (facilitySummary.index ?? "").trim();

      Reference? selectedBenchmarkReference;

// 1) First try to find selected item inside filtered list
      if (selectedIndexId.isNotEmpty) {
        for (final Reference benchmarkOption in benchmarkItems) {
          final String benchmarkOptionId =
              (benchmarkOption.id?.toString() ?? "").trim();
          if (benchmarkOptionId == selectedIndexId) {
            selectedBenchmarkReference = benchmarkOption;
            break;
          }
        }
      }

// 2) Fallback:
// If current value is not in the filtered list (for example old/inconsistent API data),
// find it in the full benchmark master list so dropdown can still show selected value.
      final List<Reference> displayBenchmarkItems =
          List<Reference>.from(benchmarkItems);

      if (selectedBenchmarkReference == null && selectedIndexId.isNotEmpty) {
        for (final Reference benchmarkOption in viewModel.benchmark) {
          final String benchmarkOptionId =
              (benchmarkOption.id?.toString() ?? "").trim();
          if (benchmarkOptionId == selectedIndexId) {
            selectedBenchmarkReference = benchmarkOption;

// no need to add manually  a item if it's not in the reference data

            // final bool alreadyPresent = displayBenchmarkItems.any(
            //   (item) => (item.id?.toString() ?? "").trim() == selectedIndexId,
            // );

            // if (!alreadyPresent) {
            //   displayBenchmarkItems.insert(0, benchmarkOption);
            // }
            break;
          }
        }
      }
      rows.add([
        //s.no
        Text("${facilityRow.order}"),

        //limit number link to open existing facility
        TextButton(
          onPressed: () {
            router.go(
              Routes.createFacility,
              extra: {
                "facilityArgs": CreateFacilityArgs(
                  facilityId: facilitySummary.facilityId,
                  facility: Facility(
                    facilitySummaryItem: facilitySummary,
                    limitGroupName: facilitySummary.productCode,
                    facilityDescription:
                        viewModel.facility.facilityTypeSelectedValue,
                    limitDescription:
                        viewModel.facility.facilityDescription?.name,
                    limitCode: viewModel.facility.facilityDescription?.id,
                    facilityMasterId: facilitySummary.facilityMasterId,
                    facilityId: facilitySummary.facilityId,
                    selectedProductTypeValue:
                        viewModel.facility.selectedProductTypeValue,
                    rimNo: facilitySummary.rimNo,
                    limitGroup: facilitySummary.limitGroup,
                    isMainLimit: facilitySummary.isMainLimit,
                    totalProposedLimit: parentCap,
                    proposedLimit: parentCap,
                  ),
                  showCreateFacilityForm: false,
                ),
                "pageMode": viewModel.amendPagemode,
              },
            );
          },
          child: Text(
            " ${facilitySummary.limitNo ?? ""}",
            style: const TextStyle(
              fontSize: 13,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.darkBlue,
            ),
          ),
        ),

        //controllingLimitNo text
        Text(facilitySummary.controllingLimitNo ?? ""),

        //add sub limit button
        AddSublimitButton(
          viewModel: viewModel,
          limitGroup: facilitySummary.limitGroup,
          selectedRim: rimNo,
          isMainLimit: false,
          totalProposedLimit: facilitySummary.proposedLimit,
          limitNumber: facilitySummary.limitNo,
        ),

        //limit description
        Text(
          viewModel
                  .facilityTypeNameById(facilitySummary.limitDescription)
                  .name ??
              "",
        ),

        //exsiting limits
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            _kFmt.format((facilitySummary.presentLimitAED ?? 0).round()),
            style: const TextStyle(color: AppColors.darkBlue),
          ),
        ),

        //proposed limits
        CurrencyAmountCell(
          currencies: viewModel.currencyCodes,
          selectedCurrencyCode: ServerConstants.aedCurrency,
          initialAmount: facilitySummary.proposedLimitAED ?? 0,
          originalCurrencyCode: facilitySummary.currency,
          originalAmount: facilitySummary.proposedLimit,
          tooltipMessage: facilityDis.facilityInitFields?.proposedLimitAED !=
                      null &&
                  facilityDis.facilityInitFields!.proposedLimitAED!.isNotEmpty
              ? "Initial Value: ${facilityDis.facilityInitFields?.proposedLimitAED?.join(", ")}"
              : "",
          onCurrencySelected: (Reference ref) =>
              viewModel.onProposedCurrencySelected(facilitySummary, [ref]),
          onAmountChanged: (String value) =>
              viewModel.onProposedLimitChanged(facilitySummary, value),
        ),

        //current outstanding
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            _kFmt.format((facilitySummary.presentOutstandingAED ?? 0).round()),
            style: const TextStyle(color: AppColors.darkBlue),
          ),
        ),

        //sustainbility classification
        CustomMultiSelectDropdown<Reference>(
          selectedItems: selectedSust,
          dropdownBuilder: (context, data) {
            return dropdownMultiItemBuildScrollWidget(
              data,
              (index) => Chip(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                labelStyle: const TextStyle(fontSize: AppStyle.columnName),
                label: Text("${data?[index].name}"),
              ),
            );
          },
          itemBuilder: (context, item, {isDisabled, isSelected}) => ListTile(
            dense: true,
            minVerticalPadding: 0,
            minTileHeight: 34,
            title: Text(item.name ?? ""),
          ),
          items: viewModel.sustanabilityClassifications,
          onSelected: (value) =>
              viewModel.onSustainabilitySelected(facilitySummary, value),
        ),

        //tenor
        CustomTooltip(
          message: viewModel.getFormattedInitialValue(
            facilityDis.facilityInitFields?.tenorUnit,
            facilityDis.facilityInitFields?.tenorValue,
          ),
          child: CustomTextField(
            width: 150.w,
            validator: viewModel
                        .facilityTypeNameById(facilitySummary.limitDescription)
                        .reference5 ==
                    ServerConstants.newProductCode
                ? null
                : (_) {
                    final bool noUnit = facilitySummary.tenorUnit == null ||
                        facilitySummary.tenorUnit!.trim().isEmpty;
                    final bool noValue = (facilitySummary.tenorValue == null);
                    return (noUnit || noValue)
                        ? "Tenor (unit & value) is required"
                        : null;
                  },
            prefixIcon: CustomDropdown<Reference>(
              showClearIcon: false,
              width: 100.w,
              height: null,
              items: viewModel.period,
              selectedItems: [
                viewModel.matchPeriodByAny(
                  viewModel.period,
                  facilitySummary.tenorUnit,
                ),
              ],
              onSelected: (selectedValue) =>
                  viewModel.onTenorUnitSelected(facilitySummary, selectedValue),
              itemBuilder: (context, item, {isDisabled, isSelected}) =>
                  dropdownMultiItemBuildWidget(
                item.name,
                isSelected: isSelected ?? false,
              ),
              dropdownBuilder: (context, data) =>
                  Text(data?.name ?? "", style: const TextStyle(fontSize: 12)),
            ),
            initialValue: (facilitySummary.tenorValue != null)
                ? "${facilitySummary.tenorValue}"
                : "",
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                viewModel.onTenorValueChanged(facilitySummary, value),
          ),
        ),

        //benchmark
        CustomTooltip(
          message: facilityDis.facilityInitFields?.index != null &&
                  (facilityDis.facilityInitFields!.index ?? []).isNotEmpty
              ? "Initial Value: ${viewModel.returnListItemsbasedOnID(
                    viewModel.benchmark,
                    facilityDis.facilityInitFields?.index ?? [],
                  ).map((e) => e.name).join(", ")}"
              : "",
          child: CustomDropdown<Reference>(
            width: 125.w,
            showClearIcon: false,
            validationMessage: requireIndex ? "Index is required" : null,
            items: displayBenchmarkItems, // filtered list
            selectedItems: selectedBenchmarkReference != null
                ? [selectedBenchmarkReference]
                : const [],

            onSelected: (selectedValue) =>
                viewModel.onBenchmarkSelected(facilitySummary, selectedValue),

            itemBuilder: (context, item, {isDisabled, isSelected}) =>
                dropdownItemBuildWidget(
              item.name,
              isSelected: isSelected ?? false,
            ),
            dropdownBuilder: (context, data) =>
                Text(data?.name ?? "", style: const TextStyle(fontSize: 13)),
          ),
        ),

        //spread/commission
        CustomTooltip(
          message: viewModel.getFormattedInitialValue(
            isF ? facilityDis.facilityInitFields?.marginSign : ["%"],
            facilityDis.facilityInitFields?.marginValue,
          ),
          child: CustomTextField(
            width: 120.w,
            validator: viewModel
                        .facilityTypeNameById(facilitySummary.limitDescription)
                        .reference5 ==
                    ServerConstants.newProductCode
                ? null
                : (_) {
                    final bool signMissing = isF &&
                        ((facilitySummary.marginSign ?? "").trim().isEmpty);
                    final bool valMissing =
                        isF && (facilitySummary.marginValue == null);
                    return (signMissing || valMissing)
                        ? "Margin (sign & value) is required"
                        : null;
                  },
            prefixIcon: isF
                ? CustomDropdown<Reference>(
                    showClearIcon: false,
                    width: 60.w,
                    height: null,
                    items: viewModel.marginSign,
                    selectedItems: [
                      viewModel.matchOrFirstByRef1(
                        viewModel.marginSign,
                        facilitySummary.marginSign,
                      ),
                    ],
                    onSelected: (selectedValue) => viewModel
                        .onMarginSignSelected(facilitySummary, selectedValue),
                    itemBuilder: (context, item, {isDisabled, isSelected}) =>
                        dropdownMultiItemBuildWidget(
                      item.reference1,
                      isSelected: isSelected ?? false,
                    ),
                    dropdownBuilder: (context, data) => Text(
                      data?.reference1 ?? "",
                      style: const TextStyle(fontSize: 20),
                    ),
                  )
                : null,
            initialValue: facilitySummary.marginValue != null
                ? "${facilitySummary.marginValue ?? ''}"
                : "",
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                viewModel.onMarginValueChanged(facilitySummary, value),
          ),
        ),

        //dialog linked securities
        Center(
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              final String limitNo = (facilitySummary.limitNo ?? "").trim();
              final String dialogTitle = limitNo.isEmpty
                  ? "facilities.facilitySummary.dialog".tr()
                  : "${"facilities.facilitySummary.dialog".tr()} - $limitNo";

              DialogHelper.showCustomDialog(
                width: 700.w,
                title: dialogTitle,
                content: SelectFacilitiesDialogView(
                  isSecuritySummary: true,
                  linkedLimitNo: (facilitySummary.limitNo ?? "").trim(),
                ),
                context: context,
              );
            },
            icon: const Icon(Icons.link, color: AppColors.buttonBackground),
          ),
        ),

        //delete button
        if (viewModel.canEdit &&
            (facilitySummary.facilityMasterId ?? 0) ==
                0) //  whenc facilityMasterId is equal to 0 then show delete button
          DeleteFacilityButton(
            serialNumber: facilitySummary.facilityId,
            viewModel: viewModel,
          )
        else
          const SizedBox(),
      ]);
    }

    // Footer row
    rows.add([
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          _kFmt.format((totals.totalExistingLimit ?? 0).round()),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          _kFmt.format((totals.totalProposedLimit ?? 0).round()),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          _kFmt.format((totals.totalCurrentOutstanding ?? 0).round()),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
    ]);

    return rows;
  }
}
