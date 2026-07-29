import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/icon.dart";
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
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/allocate_project.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/create_facility_button.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/currency_amount_cell.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/delete_facility_button.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/filter_table.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";

/// Number formatter used to display project standby limit amounts with
/// thousands separators.
final NumberFormat _kFmt = NumberFormat("#,###");

/// Widget for displaying project standby limits in a table.
class ProjectStandbyLimitsTable extends StatefulWidget {
  /// Creates a project standby limits table widget.
  const ProjectStandbyLimitsTable({
    required this.viewModel,
    required this.customer,
    super.key,
    this.groupIndex,
  });

  /// View model containing facility summary data and actions.
  final FacilitiesSummaryViewModel viewModel;

  /// Customer whose project standby limits are displayed.
  final FacilitySummaryList customer;

  /// Index used to retrieve the corresponding project standby limit group.
  final int? groupIndex;

  @override
  State<ProjectStandbyLimitsTable> createState() =>
      _ProjectStandbyLimitsTableState();
}

class _ProjectStandbyLimitsTableState extends State<ProjectStandbyLimitsTable> {
  @override
  Widget build(BuildContext context) {
    final RimSummary? rim = (widget.customer.rims?.isNotEmpty ?? false)
        ? widget.customer.rims!.first
        : null;
    final List<RimGroup> groups = rim?.groups ?? const <RimGroup>[];
    String title = "";
    final RimGroup? selectedGroup = (widget.groupIndex != null &&
            widget.groupIndex! >= 0 &&
            widget.groupIndex! < groups.length)
        ? groups[widget.groupIndex!]
        : null;
    if (selectedGroup != null) {
      title = selectedGroup.groupName ?? title;
    }

    // Show the main table *only* if there's at least one non-header row.
    // final bool hasNonHeaderLimits = limits.any((d) => (d.order?.trim() !=
    // '0'));
    // that is not excluded (not 935 and not CLT).
    final bool hasNonHeaderLimits =
        (selectedGroup?.facilityLimits ?? const <FacilityDis>[]).any((dis) {
      final FacilitySummaryNew? facility = dis.facility;
      if (facility == null) {
        return false;
      }
      final String? limitDescription = facility.limitDescription?.toString();
      final String productCode =
          (facility.productCode ?? "").trim().toUpperCase();
      final bool notExcluded =
          limitDescription != "935" && productCode != "CLT";
      final bool isNonHeader = (dis.order ?? "").trim() != "0";
      return notExcluded && isNonHeader;
    });

    final int? selectedRim = widget.viewModel.extractRimId(rim?.rimName);
    String? headerLimitNoFromGroup;
    final limits = selectedGroup?.facilityLimits ?? const <FacilityDis>[];
    final GroupAmounts totals = selectedGroup?.amounts ?? GroupAmounts();
    final headerRows = limits.where((d) => d.order?.trim() == "0").toList();

    for (final h in headerRows) {
      final f = h.facility;
      final ld = f?.limitDescription?.toString();
      final pc = (f?.productCode ?? "").trim().toUpperCase();
      final isExcluded = (ld == "935") || (pc == "CLT");
      if (!isExcluded) {
        headerLimitNoFromGroup = f?.limitNo;
        break;
      }
    }
    return CustomAccordion(
      isSubSection: true,
      title: title,
      children: [
        const Gap(),
        CustomRawTable(
          key: ValueKey('psl-header-${selectedRim ?? ''}'),
          columns: getProjectTableColumns(),
          rows: getProjectTableRows(),
        ),
        const Gap(),
        if (hasNonHeaderLimits)
          CustomRawTable(
            key: UniqueKey(),
            rowHeight: 46,
            isFilterTable: true,
            columns: getTableColumns(),
            rows: getTableRows(context),
          )
        else
          AddFacilitySubLimitBox(
            label: "facilities.facilitySummary.createFacility".tr(),
            limitGroup: ServerConstants.projectStandByLimitID,
            selectedRim: selectedRim,
            proposedLimit: widget.viewModel.proposedLimitForGroup(
              ServerConstants.projectStandByLimitID,
              rimNo: selectedRim!,
            ),
            isStanbySublimitValidation: false,
            isMainLimit: true,
            totalProposedLimit: totals.totalProposedLimit?.toInt(),
            limitNumber: headerLimitNoFromGroup,
          ),
        const Gap(),
        if (hasNonHeaderLimits && widget.viewModel.canEdit)
          Row(
            children: [
              AddFacilityButton(
                viewModel: widget.viewModel,
                limitGroup: ServerConstants.projectStandByLimitID,
                selectedRim: selectedRim,
                isStanbySublimitValidation: false,
                totalProposedLimit: totals.totalProposedLimit?.toInt(),
                proposedLimit: widget.viewModel.proposedLimitForGroup(
                  ServerConstants.projectStandByLimitID,
                  rimNo: selectedRim!,
                ),
                isMainLimit: false,
              ),
              const Gap(
                direction: Axis.horizontal,
              ),
              CustomButton(
                label: "Create New Project/Contract",
                onPressed: () {
                  router.go(Routes.createProject);
                },
              ),
              const Spacer(),
              CustomButton(
                label: "common.save".tr(),
                onPressed: () {
                  final isValid =
                      widget.viewModel.formKey.currentState?.validate();
                  if (isValid == false) {
                    AlertManager()
                        .showFailureToast("Please fill required fields");
                    return;
                  }
                  widget.viewModel.saveFacilitySummaryList(
                    widget.customer,
                    limitGroup: ServerConstants.projectStandByLimitID,
                    selectedRim: selectedRim,
                  );
                  widget.viewModel.getProjectList(
                    ServerConstants.projectStandByLimitID,
                    selectedRim,
                  );
                },
              ),
            ],
          ),
      ],
    );
  }

  List<List<Widget>> getTableRows(BuildContext context) {
    final filterRows = <Widget>[
      const SizedBox.shrink(),
      const SizedBox.shrink(),
      const FilterTableWidget(),
      const FilterTableWidget(),
      const FilterTableWidget(),
      const SizedBox.shrink(),
      const FilterTableWidget(),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
    ];

    final tableRows = <List<Widget>>[filterRows];

    final rim = (widget.customer.rims?.isNotEmpty ?? false)
        ? widget.customer.rims!.first
        : null;
    final groups = rim?.groups ?? const <RimGroup>[];

    final RimGroup? selectedGroup = (widget.groupIndex != null &&
            widget.groupIndex! >= 0 &&
            widget.groupIndex! < groups.length)
        ? groups[widget.groupIndex!]
        : null;
    final int? selectedRim = widget.viewModel.extractRimId(rim?.rimName);

    final List<FacilityDis> apiDisList = List<FacilityDis>.from(
      selectedGroup?.facilityLimits ?? const <FacilityDis>[],
    ).where((d) {
      // keep non-header rows only means remove order '0' row
      if ((d.order ?? "").trim() == "0") {
        return false;
      }
      final f = d.facility;
      if (f == null) {
        return false;
      }

      final ld = f.limitDescription?.toString();
      final pc = (f.productCode ?? "").trim().toUpperCase();
      // exclude: Limit Caps (935) or product code CLT
      return ld != "935" && pc != "CLT";
    }).toList()
      ..sort((a, b) => (a.order ?? "").compareTo(b.order ?? ""));
    final GroupAmounts totals = selectedGroup?.amounts ?? GroupAmounts();
    for (final FacilityDis dis in apiDisList) {
      final FacilitySummaryNew? f = dis.facility;
      final FacilityDis facilityDis = dis;
      if (f == null) {
        continue;
      }

      final List<Reference> selectedSustainability = (() {
        final raw = f.sustainabilityClassification ?? "";
        if (raw.trim().isEmpty) {
          return <Reference>[];
        }
        final ids = raw
            .split(",")
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toSet();
        return widget.viewModel.sustanabilityClassifications
            .where((r) => ids.contains(r.id?.toString()))
            .toList();
      })();

      final bool requireIndex = widget.viewModel
                  .facilityTypeNameById(f.limitDescription)
                  .reference5 !=
              ServerConstants.newProductCode &&
          f.limitCategory?.toUpperCase() == "F";

      final bool isF = (f.limitCategory?.toUpperCase() == "F");
      final bool isProjectStandByMainLimit = (f.controllingLimitNo ?? "")
          .startsWith(ServerConstants.productCodePsbl);
      tableRows.add([
        Text("${dis.order}"),

        Center(
          child: isProjectStandByMainLimit
              // Restricting allocate project for Main Limit (controllingLimitNo.startsWith(PSBL)) and allowing for sublimits (isMainLimit = false)

              ? null
              : CustomIcon(
                  onTap: () {
                    DialogHelper.showCustomDialog(
                      barrierDismissible: false,
                      width: 500.w,
                      title: "facilities.facilitySummary.allocateProject".tr(),
                      content: BlocProvider.value(
                        value: widget.viewModel,
                        child: AllocateProject(
                          viewModel: widget.viewModel,
                          facility: f,
                          customer: widget.customer,
                          limitGroup: ServerConstants.projectStandByLimitID,
                          selectedRim: selectedRim,
                        ),
                      ),
                      context: context,
                    );
                  },
                  icon: Icons.add_circle_outline_sharp,
                  iconColor: AppColors.buttonBackground,
                ),
        ),

        Text(f.projectName ?? ""),

        //limit number link for create facility details
        TextButton(
          onPressed: () {
            router.go(
              Routes.createFacility,
              extra: {
                "facilityArgs": CreateFacilityArgs(
                  facilityId: f.facilityId,
                  facility: Facility(
                    facilitySummaryItem: f,
                    totalProposedLimit: totals.totalProposedLimit?.toInt(),
                    proposedLimit: widget.viewModel.proposedLimitForGroup(
                      ServerConstants.projectStandByLimitID,
                      rimNo: selectedRim!,
                    ),
                    limitGroupName: f.productCode,
                    isStanbySublimitValidation: false,
                    facilityDescription:
                        widget.viewModel.facility.facilityTypeSelectedValue,
                    limitDescription:
                        widget.viewModel.facility.facilityDescription?.name,
                    facilityId: f.facilityId,
                    facilityMasterId: f.facilityMasterId,
                    selectedProductTypeValue:
                        widget.viewModel.facility.selectedProductTypeValue,
                    rimNo: f.rimNo,
                    limitCode:
                        widget.viewModel.facility.facilityDescription?.id,
                    limitGroup: f.limitGroup,
                    isMainLimit: f.isMainLimit,
                  ),
                  showCreateFacilityForm: false,
                ),
                "pageMode": widget.viewModel.amendPagemode,
              },
            );
          },
          child: Text(
            " ${f.limitNo ?? ""}",
            style: const TextStyle(
              fontSize: 13,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.darkBlue,
            ),
          ),
        ),

        Text(f.controllingLimitNo ?? ""),

        //add sublimit icon on summary table
        AddSublimitButton(
          viewModel: widget.viewModel,
          limitGroup: f.limitGroup,
          selectedRim: selectedRim,
          isStanbySublimitValidation: true,
          totalProposedLimit: f.proposedLimit,
          isMainLimit: false,
          limitNumber: f.limitNo,
          projectName: ((f.limitGroup == 11315 || f.limitGroup == 11317)
              ? (f.projectName ?? "").trim()
              : null),
        ),

        Text(
          widget.viewModel.facilityTypeNameById(f.limitDescription).name ?? "",
        ),

        Align(
          alignment: Alignment.centerRight,
          child: Text(
            _kFmt.format((f.presentLimitAED ?? 0).round()),
            style: const TextStyle(color: AppColors.darkBlue),
          ),
        ),

        //proposed limit ---editable
        CurrencyAmountCell(
          currencies: widget.viewModel.currencyCodes,
          selectedCurrencyCode: ServerConstants.aedCurrency,
          initialAmount: f.proposedLimitAED ?? 0,
          originalCurrencyCode: f.currency,
          originalAmount: f.proposedLimit,
          tooltipMessage: facilityDis.facilityInitFields?.proposedLimitAED !=
                      null &&
                  facilityDis.facilityInitFields!.proposedLimitAED!.isNotEmpty
              ? "Initial Value: ${facilityDis.facilityInitFields!.proposedLimitAED?.join(", ")}"
              : "",
          onCurrencySelected: (Reference sel) {
            f
              ..currency = sel.name
              ..isEdited = true;
            widget.viewModel.facility.proposedLimitValue =
                sel; // keep UI binding
          },
          onAmountChanged: (String value) {
            final String raw = value.replaceAll(RegExp("[^0-9]"), "");
            f
              ..proposedLimit = raw.isEmpty ? 0 : int.parse(raw)
              ..proposedLimitAED = raw.isEmpty ? 0 : int.tryParse(raw)
              ..isEdited = true;
          },
        ),

        Align(
          alignment: Alignment.centerRight,
          child: Text(
            _kFmt.format((f.presentOutstandingAED ?? 0).round()),
            style: const TextStyle(color: AppColors.darkBlue),
          ),
        ),

        //sustainability classification -------editable
        CustomMultiSelectDropdown<Reference>(
          selectedItems: selectedSustainability,
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
          itemBuilder: (context, item, {isDisabled, isSelected}) {
            return ListTile(
              dense: true,
              minVerticalPadding: 0,
              minTileHeight: 34,
              title: Text(item.name ?? ""),
            );
          },
          items: widget.viewModel.sustanabilityClassifications,
          onSelected: (value) {
            final ids = value
                .map((r) => r.id?.toString())
                .where((id) => id != null && id.isNotEmpty)
                .cast<String>()
                .toList();
            f
              ..sustainabilityClassification = ids.join(", ")
              ..isEdited = true;
          },
        ),

        //tenor days ---editable
        CustomTooltip(
          message: widget.viewModel.getFormattedInitialValue(
            facilityDis.facilityInitFields?.tenorUnit,
            facilityDis.facilityInitFields?.tenorValue,
          ),
          child: CustomTextField(
            width: 150.w,
            validator: widget.viewModel
                        .facilityTypeNameById(f.limitDescription)
                        .reference5 ==
                    ServerConstants.newProductCode
                ? null
                : (_) {
                    final noUnit =
                        f.tenorUnit == null || f.tenorUnit!.trim().isEmpty;
                    final noValue = (f.tenorValue == null);
                    return (noUnit || noValue)
                        ? "Tenor (unit & value) is required"
                        : null;
                  },
            prefixIcon: CustomDropdown<Reference>(
              showClearIcon: false,
              width: 100.w,
              height: null,
              items: widget.viewModel.period,
              selectedItems: [
                widget.viewModel
                    .matchPeriodByAny(widget.viewModel.period, f.tenorUnit),
              ],
              onSelected: (selectedValue) {
                if (selectedValue.isNotEmpty) {
                  final sel = selectedValue.first;

                  f
                    ..tenorUnit = sel.name
                    ..isEdited = true;
                  widget.viewModel.facility.proposedLimitValue =
                      sel; // keep UI binding
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
            initialValue: (f.tenorValue != null) ? "${f.tenorValue}" : "",
            keyboardType: TextInputType.number,
            onChanged: (String? value) {
              final match = RegExp(r"\d+").firstMatch(value ?? "");

              f
                ..tenorValue =
                    match != null ? int.tryParse(match.group(0)!) : null
                ..isEdited = true;
            },
          ),
        ),

        //benchmark -------editable
        CustomTooltip(
          message: facilityDis.facilityInitFields?.index != null &&
                  facilityDis.facilityInitFields!.index!.isNotEmpty
              ? "Initial Value: ${widget.viewModel.returnListItemsbasedOnID(
                    widget.viewModel.benchmark,
                    facilityDis.facilityInitFields?.index ?? [],
                  ).map((item) => item.name).join(", ")}"
              : "",
          child: CustomDropdown<Reference>(
            showClearIcon: false,
            validationMessage: requireIndex ? "Index is required" : null,
            items: widget.viewModel.benchmark,
            selectedItems: [
              widget.viewModel
                  .matchOrFirstById(widget.viewModel.benchmark, f.index),
            ],
            onSelected: (selectedValue) {
              if (selectedValue.isNotEmpty) {
                final sel = selectedValue.first;

                f
                  ..index = sel.id?.toString() ?? sel.name ?? ""
                  ..isEdited = true;
                widget.viewModel.facility.proposedLimitValue = sel;
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
                style: const TextStyle(fontSize: 13),
              );
            },
          ),
        ),

        //spread -------editable
        CustomTooltip(
          message: widget.viewModel.getFormattedInitialValue(
            isF ? facilityDis.facilityInitFields?.marginSign : [],
            facilityDis.facilityInitFields?.marginValue,
          ),
          child: CustomTextField(
            width: 120.w,
            validator: widget.viewModel
                        .facilityTypeNameById(f.limitDescription)
                        .reference5 ==
                    ServerConstants.newProductCode
                ? null
                : (_) {
                    final signMissing =
                        isF && ((f.marginSign ?? "").trim().isEmpty);
                    final valMissing = (f.marginValue == null);
                    return (signMissing || valMissing)
                        ? "Margin (sign & value) is required"
                        : null;
                  },
            prefixIcon: isF
                ? CustomDropdown<Reference>(
                    showClearIcon: false,
                    width: 60.w,
                    height: null,
                    items: widget.viewModel.marginSign,
                    selectedItems: [
                      widget.viewModel.matchOrFirstByRef1(
                        widget.viewModel.marginSign,
                        f.marginSign,
                      ),
                    ],
                    onSelected: (selectedValue) {
                      if (selectedValue.isNotEmpty) {
                        final sel = selectedValue.first;

                        f
                          ..marginSign = sel.reference1
                          ..isEdited = true;
                        widget.viewModel.facility.proposedLimitValue = sel;
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
                  )
                : null,
            initialValue: f.marginValue != null ? "${f.marginValue ?? ''}" : "",
            keyboardType: TextInputType.number,
            onChanged: (String? value) {
              // extract decimal number from a string: "+ 2.5" -> 2.5
              final match = RegExp(r"[-+]?\d*\.?\d+").firstMatch(value ?? "");

              f
                ..marginValue =
                    match != null ? num.tryParse(match.group(0)!) : null
                ..isEdited = true;
            },
          ),
        ),

        Center(
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              DialogHelper.showCustomDialog(
                width: 700.w,
                title: "facilities.facilitySummary.dialog".tr(),
                content:
                    const SelectFacilitiesDialogView(isSecuritySummary: true),
                context: context,
              );
            },
            icon: const Icon(Icons.link, color: AppColors.buttonBackground),
          ),
        ),

        if (widget.viewModel.canEdit && (f.facilityMasterId ?? 0) == 0)
          DeleteFacilityButton(
            serialNumber: f.facilityId,
            viewModel: widget.viewModel,
          )
        else
          const SizedBox(),
      ]);
    }

    tableRows.add([
      const SizedBox.shrink(),
      const SizedBox.shrink(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          _kFmt.format(totals.totalExistingLimit),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          _kFmt.format(totals.totalProposedLimit),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          _kFmt.format(totals.totalCurrentOutstanding),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
    ]);

    return tableRows;
  }

  List<TableColumn> getTableColumns() {
    return [
      TableColumn(
        label: Text("facilities.facilitySummary.sNo".tr()),
      ),
      const TableColumn(
        label: Text("Allocate Project"),
      ),
      const TableColumn(
        label: Text("Project Name"),
      ),
      TableColumn(label: Text("facilities.facilitySummary.limitNo".tr())),
      const TableColumn(label: Text("Controlling Limit Number")),
      TableColumn(label: Text("facilities.facilitySummary.addSublimit".tr())),
      TableColumn(
        label: Text("facilities.facilitySummary.limitDescription".tr()),
      ),
      TableColumn(
        label: Text("facilities.facilitySummary.existingLimits".tr()),
      ),
      TableColumn(
        forcedWidth: 155.w,
        label: Text("facilities.facilitySummary.proposedLimits".tr()),
      ),
      TableColumn(
        label: Text("facilities.facilitySummary.os".tr()),
      ),
      TableColumn(
        label: Text("facilities.facilitySummary.classification".tr()),
      ),
      TableColumn(label: Text("facilities.facilitySummary.tenorDays".tr())),
      TableColumn(
        label: Text("facilities.facilitySummary.applicablePricing".tr()),
      ),
      const TableColumn(label: Text("Spread/Commision")),
      TableColumn(
        label: Text("facilities.facilitySummary.linkedFacility".tr()),
      ),
      TableColumn(
        label: Text("facilities.facilitySummary.action".tr()),
      ),
    ];
  }

  List<List<Widget>> getProjectTableRows() {
    final List<List<Widget>> tableRows = <List<Widget>>[];
    const String message = "";

    // Find "order == 1" row from this group's limits
    final RimSummary? rim = (widget.customer.rims?.isNotEmpty ?? false)
        ? widget.customer.rims!.first
        : null;
    final List<RimGroup> groups = rim?.groups ?? const <RimGroup>[];
    final RimGroup? selectedGroup = (widget.groupIndex != null &&
            widget.groupIndex! >= 0 &&
            widget.groupIndex! < groups.length)
        ? groups[widget.groupIndex!]
        : null;

    final List<FacilityDis> limits =
        selectedGroup?.facilityLimits ?? const <FacilityDis>[];

    FacilityDis headerDis = FacilityDis();
    final List<FacilityDis> headerRows =
        limits.where((d) => d.order?.trim() == "0").toList();
    for (final h in headerRows) {
      final f = h.facility;
      final ld = f?.limitDescription?.toString();
      final pc = (f?.productCode ?? "").trim().toUpperCase();
      final isExcluded = (ld == "935") || (pc == "CLT");
      if (!isExcluded) {
        headerDis = h;
        break;
      }
    }

    final FacilitySummaryNew? facility = headerDis.facility;

    if (facility == null) {
      final int? rimNo = widget.viewModel.extractRimId(rim?.rimName);
      if (rimNo != null &&
          widget.viewModel.headerCurrencyFor(11317, rimNo) == null) {
        final ref = widget.viewModel
            .matchOrFirstByName(widget.viewModel.currencyCodes, "AED");
        widget.viewModel.setHeaderCurrencyFor(11317, rimNo, ref);
      }
    } else {
      final int? selectedRim = widget.viewModel.extractRimId(rim?.rimName);
      if (selectedRim != null) {
        final nameCtrl = widget.viewModel.standbyNameCtrl(selectedRim);
        final proposedCtrl = widget.viewModel.standbyProposedCtrl(selectedRim);

        // Prefill ONLY if empty (don’t overwrite user edits on rebuild)
        final String apiName = (facility.projectName ?? "").trim();
        if (nameCtrl.text.trim().isEmpty) {
          nameCtrl.text = apiName;
        }

        final existing = (facility.presentLimitAED ?? 0).toInt();

        if (widget.viewModel.proposedLimitForGroup(11317, rimNo: selectedRim) ==
            null) {
          widget.viewModel.setProjectExistingLimitInput(
            existing.toString(),
            groupId: 11317,
            rimNo: selectedRim,
          );
        }

        final proposed = facility.proposedLimitAED ?? 0;
        if (proposedCtrl.text.trim().isEmpty) {
          proposedCtrl.text = _kFmt.format(proposed);
        }
        if (widget.viewModel.proposedLimitForGroup(11317, rimNo: selectedRim) ==
            null) {
          widget.viewModel.setProjectProposedLimitInput(
            proposed.toString(),
            groupId: 11317,
            rimNo: selectedRim,
          );
        }

        final String apiCurrency = (facility.currency ?? "AED").trim();
        final Reference apiCurrencyRef = widget.viewModel
            .matchOrFirstByName(widget.viewModel.currencyCodes, apiCurrency);

        if (widget.viewModel.headerCurrencyFor(11317, selectedRim) == null) {
          widget.viewModel
              .setHeaderCurrencyFor(11317, selectedRim, apiCurrencyRef);
        }
      }
    }

    final int selectedRim = widget.viewModel.extractRimId(rim?.rimName)!;

    // Build the header row
    tableRows.add([
      // Name
      CustomTextField(
        controller: widget.viewModel.standbyNameCtrl(selectedRim),
      ),

      // Existing Limits
      Text(
        (facility?.presentLimitAED != null)
            ? _kFmt.format((facility!.presentLimitAED!).round())
            : "",
        style: const TextStyle(color: AppColors.darkBlue),
      ),
      // Proposed Limit + Currency
      CurrencyAmountCell(
        currencies: widget.viewModel.currencyCodes,
        selectedCurrencyCode: ServerConstants.aedCurrency,
        originalCurrencyCode: facility?.currency,
        originalAmount: facility?.proposedLimit,
        controller: widget.viewModel.standbyProposedCtrl(selectedRim),
        dropdownWidth: 65.w,
        keyboardType: TextInputType.number,
        tooltipMessage: message,
        onCurrencySelected: (Reference sel) =>
            widget.viewModel.setHeaderCurrencyFor(11317, selectedRim, sel),
        onAmountChanged: (String value) {
          final String raw = value.replaceAll(",", "");
          widget.viewModel.setProjectProposedLimitInput(
            raw,
            groupId: 11317,
            rimNo: selectedRim,
          );
        },
      ),

      // Current Outstanding (in AED) — show API value if we have a header
      // facility
      Text(
        (facility?.presentOutstandingAED != null)
            ? _kFmt.format((facility!.presentOutstandingAED!).round())
            : "",
        style: const TextStyle(color: AppColors.darkBlue),
      ),
    ]);

    return tableRows;
  }

  List<TableColumn> getProjectTableColumns() {
    return [
      TableColumn(
        forcedWidth: 50.w,
        label: Text("facilities.facilitySummary.name".tr()),
      ),
      TableColumn(
        forcedWidth: 50.w,
        label: Text("facilities.facilitySummary.existingLimits".tr()),
      ),
      TableColumn(
        forcedWidth: 50.w,
        label: RichText(
          text: TextSpan(
            text: "facilities.facilitySummary.proposedLimits".tr(),
            children: const [
              TextSpan(
                text: " *",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      TableColumn(
        forcedWidth: 50.w,
        label: Text("facilities.facilitySummary.currentOutstanding".tr()),
      ),
    ];
  }
}
