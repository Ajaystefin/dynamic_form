import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/accordion.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/view.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/add_facility_button.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/add_facility_sublimit.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/add_sublimit_button.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/delete_facility_button.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/filter_table.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary_list.dart';

class LoansTable extends StatelessWidget {
  final FacilitiesSummaryViewModel viewModel;
  final FacilitySummaryList customer;
  final int? groupIndex;

  const LoansTable({
    super.key,
    required this.viewModel,
    required this.customer,
    this.groupIndex,
  });

  @override
  Widget build(BuildContext context) {
    List<FacilityDis>? apiDisList;
    int? selectedRim;
    RimSummary? rim =
        (customer.rims?.isNotEmpty ?? false) ? customer.rims!.first : null;
    final List<RimGroup> groups = rim?.groups ?? const <RimGroup>[];
    String title = "";
    final RimGroup? selectedGroup =
        (groupIndex != null && groupIndex! >= 0 && groupIndex! < groups.length)
            ? groups[groupIndex!]
            : null;
    if (selectedGroup != null) {
      title = selectedGroup.groupName ?? title;
    }

    final bool hasApiLimits =
        (selectedGroup?.facilityLimits?.isNotEmpty ?? false);
    selectedRim = viewModel.extractRimId(rim?.rimName);
    apiDisList = List<FacilityDis>.from(
        selectedGroup?.facilityLimits ?? const <FacilityDis>[])
      ..sort((a, b) => (a.order ?? '').compareTo(b.order ?? ''));

    return CustomAccordion(
      isSubSection: true,
      title: title,
      textColor: AppColors.primary,
      children: [
        const Gap(),
        if (hasApiLimits)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "common.currencyValue".tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        (hasApiLimits)
            ? CustomRawTable(
                autoFitWidth: true,
                key: UniqueKey(),
                rowHeight: 46,
                isFilterTable: true,
                columns: getTableColumns(),
                rows: getTableRows(context, apiDisList, selectedRim),
              )
            : AddFacilitySubLimitBox(
                label: "facilities.facilitySummary.createFacility".tr(),
                limitGroup: 11313,
                selectedRim: selectedRim,
                isMainLimit: true),
        const Gap(),
        if (hasApiLimits)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AddFacilityButton(
                  viewModel: viewModel,
                  limitGroup: 11313,
                  selectedRim: selectedRim,
                  isMainLimit: true),
              CustomButton(
                label: "common.save".tr(),
                onPressed: () {
                  viewModel.saveFacilitySummaryList(customer);
                },
              )
            ],
          ),
      ],
    );
  }

  List<List<Widget>> getTableRows(
      BuildContext context, List<FacilityDis> apiDisList, int? selectedRim) {
    final filterRows = <Widget>[
      const SizedBox.shrink(),
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

    final tableRows = <List<Widget>>[];
    tableRows.add(filterRows);

    int totalExistingLimit = 0;
    int totalProposedLimit = 0;
    int totalOutstandingAmount = 0;

    for (final dis in apiDisList) {
      final f = dis.facility;
      if (f == null) continue;

      final existing = (f.presentLimit ?? 0).toInt();
      final proposed = (f.proposedLimit ?? 0).toInt();
      final outstanding = (f.presentOutstanding ?? 0).toInt();

      totalExistingLimit += existing;
      totalProposedLimit += proposed;
      totalOutstandingAmount += outstanding;
      final message = viewModel.tooltipMessageFor(f);
      final List<Reference> selectedSustainability = (() {
        final raw = (f.sustainabilityClassification ?? "");
        if (raw.trim().isEmpty) return <Reference>[];
        final ids = raw
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toSet();
        return viewModel.sustanabilityClassifications
            .where((r) => ids.contains(r.id?.toString()))
            .toList();
      })();

      tableRows.add([
        Text("${dis.order}"),

        TextButton(
          onPressed: () {
            router.go(
              Routes.createFacility,
              extra: CreateFacilityArgs(
                facilityId: f.facilityId,
                facility: Facility(
                    facilityDescription:
                        viewModel.facility.facilityTypeSelectedValue,
                    limitDescription:
                        viewModel.facility.facilityDescription?.name,
                    facilityId: f.facilityId,
                    rimNo: f.rimNo,
                    limitGroup: f.limitGroup,
                    isMainLimit: f.isMainLimit),
                showCreateFacilityForm: false,
              ),
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

        AddSublimitButton(
            viewModel: viewModel,
            limitGroup: f.limitGroup,
            selectedRim: selectedRim,
            isMainLimit: false,
            proposedLimit: f.proposedLimit,
            limitNumber: f.limitNo),

        Text(f.limitDescription ?? ""),

        Text("${(f.presentLimit ?? 0).toInt()}"),

        //proposed limit ---editable
        CustomTooltip(
          message: message,
          child: CustomTextField(
            prefixIcon: CustomDropdown<Reference>(
              showClearIcon: false,
              width: 80.w,
              height: null,
              items: viewModel.currencyCodes,
              selectedItems: [
                viewModel.matchOrFirstByName(
                    viewModel.currencyCodes, f.currency)
              ],
              onSelected: (selectedValue) {
                if (selectedValue.isNotEmpty) {
                  final sel = selectedValue.first;
                  f.currency = sel.name;
                  f.isEdited = true;
                  viewModel.facility.proposedLimitValue =
                      sel; // keep your UI bindin
                  viewModel.updateConvertedTooltipFor(f);
                }
              },
              itemBuilder: (context, item, isDisabled, isSelected) {
                return dropdownMultiItemBuildWidget(
                  item.name,
                  isSelected: isSelected,
                );
              },
              dropdownBuilder: (context, data) {
                return Text(
                  data?.name ?? "",
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
            initialValue: "${(f.proposedLimit ?? 0).toInt()}",
            keyboardType: TextInputType.number,
            onChanged: (String? value) {
              f.proposedLimit = int.tryParse(value ?? "");
              f.isEdited = true;
              viewModel.updateConvertedTooltipFor(f);
            },
          ),
        ),

        Text("${(f.presentOutstanding ?? 0).toInt()}"),

        //sustainability classification -------editable
        CustomMultiSelectDropdown<Reference>(
          showClear: false,
          isEnabled: true,
          selectedItems: selectedSustainability,
          dropdownBuilder: (context, data) {
            return dropdownMultiItemBuildScrollWidget(
                data,
                (index) => Chip(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelStyle:
                          const TextStyle(fontSize: AppStyle.columnName),
                      label: Text("${data?[index].name}"),
                    ));
          },
          itemBuilder: (context, item, isDisabled, isSelected) {
            return ListTile(
                dense: true,
                minVerticalPadding: 0,
                minTileHeight: 34,
                title: Text(item.name ?? ""));
          },
          items: (viewModel.sustanabilityClassifications),
          onSelected: (value) {
            final ids = value
                .map((r) => r.id?.toString())
                .where((id) => id != null && id.isNotEmpty)
                .cast<String>()
                .toList();
            f.sustainabilityClassification = ids.join(", ");
            f.isEdited = true;
          },
        ),

        //tenor days ---editable
        CustomTextField(
          width: 150.w,
          prefixIcon: CustomDropdown<Reference>(
            showClearIcon: false,
            width: 100.w,
            height: null,
            items: viewModel.period,
            selectedItems: [
              viewModel.matchOrFirstByName(viewModel.period, f.tenorUnit)
            ],
            onSelected: (selectedValue) {
              if (selectedValue.isNotEmpty) {
                final sel = selectedValue.first;
                f.tenorUnit = sel.name;
                f.isEdited = true;
                viewModel.facility.proposedLimitValue = sel; // keep UI binding
              }
            },
            itemBuilder: (context, item, isDisabled, isSelected) {
              return dropdownMultiItemBuildWidget(
                item.name,
                isSelected: isSelected,
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
            final match = RegExp(r'\d+').firstMatch(value ?? "");
            f.tenorValue = match != null ? int.tryParse(match.group(0)!) : null;
            f.isEdited = true;
          },
        ),

        //benchmark -------editable
        CustomDropdown<Reference>(
          showClearIcon: false,
          items: viewModel.benchmark,
          selectedItems: [
            viewModel.matchOrFirstById(viewModel.benchmark, f.index)
          ],
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              final sel = selectedValue.first;
              f.index = sel.id?.toString() ?? sel.name ?? "";
              f.isEdited = true;
              viewModel.facility.proposedLimitValue = sel;
            }
          },
          itemBuilder: (context, item, isDisabled, isSelected) {
            return dropdownItemBuildWidget(
              item.name,
              isSelected: isSelected,
            );
          },
          dropdownBuilder: (context, data) {
            return Text(
              data?.name ?? "",
              style: const TextStyle(fontSize: 13),
            );
          },
        ),

        //spread -------editable
        CustomTextField(
          width: 120.w,
          prefixIcon: CustomDropdown<Reference>(
            showClearIcon: false,
            width: 60.w,
            height: null,
            items: viewModel.marginSign,
            selectedItems: [
              viewModel.matchOrFirstByRef1(viewModel.marginSign, f.marginSign)
            ],
            onSelected: (selectedValue) {
              if (selectedValue.isNotEmpty) {
                final sel = selectedValue.first;
                f.marginSign = sel.reference1;
                f.isEdited = true;
                viewModel.facility.proposedLimitValue = sel;
              }
            },
            itemBuilder: (context, item, isDisabled, isSelected) {
              return dropdownMultiItemBuildWidget(
                item.reference1,
                isSelected: isSelected,
              );
            },
            dropdownBuilder: (context, data) {
              return Text(
                data?.reference1 ?? "",
                style: const TextStyle(fontSize: 20),
              );
            },
          ),
          initialValue: f.marginValue != null ? "${f.marginValue ?? ''}" : "",
          keyboardType: TextInputType.number,
          onChanged: (String? value) {
            // extract decimal number from a string: "+ 2.5" -> 2.5
            final match = RegExp(r'[-+]?\d*\.?\d+').firstMatch(value ?? "");
            f.marginValue =
                match != null ? num.tryParse(match.group(0)!) : null;
            f.isEdited = true;
          },
        ),

        Center(
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              DialogHelper.showCustomDialog(
                width: 700.w,
                barrierDismissible: true,
                title: "facilities.facilitySummary.dialog".tr(),
                content:
                    const SelectFacilitiesDialogView(isSecuritySummary: true),
                context: context,
              );
            },
            icon: const Icon(Icons.link, color: AppColors.buttonBackground),
          ),
        ),

        DeleteFacilityButton(
          serialNumber: f.facilityId,
          viewModel: viewModel,
        ),
      ]);
    }

    tableRows.add([
      const SizedBox.shrink(), // sNo
      const SizedBox.shrink(), // limitNo
      const SizedBox.shrink(), // Controlling Limit Number
      const SizedBox.shrink(), // Add Sub-limit
      const SizedBox.shrink(), // Limit Description
      Text(totalExistingLimit.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(totalProposedLimit.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(totalOutstandingAmount.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox.shrink(), // Classification
      const SizedBox.shrink(), // Tenor Days
      const SizedBox.shrink(), // Applicable Pricing
      const SizedBox.shrink(), // Spread/Commission
      const SizedBox.shrink(), // Linked Facility
      const SizedBox.shrink(), // Action
    ]);

    return tableRows;
  }

  List<TableColumn> getTableColumns() {
    return [
      TableColumn(label: Text('facilities.facilitySummary.sNo'.tr())),
      TableColumn(label: Text('facilities.facilitySummary.limitNo'.tr())),
      const TableColumn(label: Text('Controlling Limit Number')),
      TableColumn(label: Text("facilities.facilitySummary.addSublimit".tr())),
      TableColumn(
          label: Text('facilities.facilitySummary.limitDescription'.tr())),
      TableColumn(
          label: Text('facilities.facilitySummary.existingLimits'.tr())),
      TableColumn(
          label: Text('facilities.facilitySummary.proposedLimits'.tr())),
      TableColumn(label: Text('facilities.facilitySummary.os'.tr())),
      TableColumn(
          label: Text('facilities.facilitySummary.classification'.tr())),
      TableColumn(label: Text('facilities.facilitySummary.tenorDays'.tr())),
      TableColumn(
          label: Text('facilities.facilitySummary.applicablePricing'.tr())),
      const TableColumn(label: Text('Spread/Commision')),
      TableColumn(
          label: Text('facilities.facilitySummary.linkedFacility'.tr())),
      TableColumn(label: Text('facilities.facilitySummary.action'.tr())),
    ];
  }
}
