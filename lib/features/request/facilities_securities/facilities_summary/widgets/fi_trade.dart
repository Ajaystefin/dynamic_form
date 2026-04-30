import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/view.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/add_facility_button.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/add_sublimit_button.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/create_facility_button.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/delete_facility_button.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/filter_table.dart"
    show FilterTableWidget;
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";

// Shared number formatter for this table.
final NumberFormat _kFmt = NumberFormat("#,###");

class FiTradeTable extends StatelessWidget {
  const FiTradeTable({
    required this.viewModel,
    required this.customer,
    super.key,
    this.groupIndex,
    this.limitGroup,
  });
  final FacilitiesSummaryViewModel viewModel;
  final FacilitySummaryList customer;
  final int? groupIndex;
  final int? limitGroup;

  @override
  Widget build(BuildContext context) {
    final rim =
        (customer.rims?.isNotEmpty ?? false) ? customer.rims?.first : null;
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
        (selectedGroup?.facilityLimits ?? const <FacilityDis>[]).any((dis) {
      final facilityList = dis.facility;
      if (facilityList == null) return false;
      final ld = facilityList.limitDescription?.toString();
      final pc = (facilityList.productCode ?? "").trim().toUpperCase();
      return ld != "935" &&
          pc != "CLT"; // true if any row remains after filtering
    });

    final int? selectedRim = viewModel.extractRimId(rim?.rimName);

    return CustomAccordion(
      title: title,
      isSubSection: true,
      children: [
        const Gap(),
        (hasApiLimits)
            ? CustomRawTable(
                key: UniqueKey(),
                rowHeight: 46,
                isFilterTable: true,
                columns: getTableColumns(),
                rows: getTableRows(context, selectedGroup),
              )
            : AddFacilitySubLimitBox(
                //create button
                label: "facilities.facilitySummary.createFacility".tr(),
                limitGroup: limitGroup,
                selectedRim: selectedRim,
                isMainLimit: true,
              ),
        const Gap(),
        if (hasApiLimits && viewModel.canEdit)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //add button when table having list rows
              AddFacilityButton(
                viewModel: viewModel,
                limitGroup: limitGroup,
                selectedRim: selectedRim,
                isMainLimit: true,
              ),
              CustomButton(
                label: "common.save".tr(),
                onPressed: () {
                  if (!(viewModel.formKey.currentState?.validate() ?? true)) {
                    return;
                  }
                  viewModel.saveFacilitySummaryList(
                    customer,
                    limitGroup: limitGroup!,
                    selectedRim: selectedRim ?? 0,
                  );
                },
              ),
            ],
          ),
      ],
    );
  }

  List<TableColumn> getTableColumns() {
    return [
      TableColumn(label: Text("facilities.facilitySummary.sNo".tr())),
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
      TableColumn(label: Text("facilities.facilitySummary.os".tr())),
      TableColumn(
        label: Text("facilities.facilitySummary.classification".tr()),
      ),
      TableColumn(
        forcedWidth: 155.w,
        label: Text("facilities.facilitySummary.tenorDays".tr()),
      ),
      TableColumn(
        label: Text("facilities.facilitySummary.applicablePricing".tr()),
      ),
      const TableColumn(label: Text("Spread/Commision")),
      TableColumn(
        label: Text("facilities.facilitySummary.linkedFacility".tr()),
      ),
      TableColumn(label: Text("facilities.facilitySummary.action".tr())),
    ];
  }

  List<List<Widget>> getTableRows(
    BuildContext context,
    RimGroup? selectedGroup,
  ) {
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

    final List<List<Widget>> tableRows = <List<Widget>>[];
    tableRows.add(filterRows);

    int totalExistingLimit = 0;
    int totalProposedLimit = 0;
    int totalOutstandingAmount = 0;

    final RimSummary? rim =
        (customer.rims?.isNotEmpty ?? false) ? customer.rims?.first : null;

    final int? selectedRim = viewModel.extractRimId(rim?.rimName);

    /// Exclude: Limit Caps (id 935) OR product code CLT
    final List<FacilityDis> apiDisList = List<FacilityDis>.from(
      selectedGroup?.facilityLimits ?? const <FacilityDis>[],
    ).where((dis) {
      final f = dis.facility;
      if (f == null) return false;
      final ld = f.limitDescription?.toString(); // numeric/string safe
      final pc = (f.productCode ?? "").trim().toUpperCase();
      return ld != "935" && pc != "CLT"; // keep everything else
    }).toList()
      ..sort((a, b) => (a.order ?? "").compareTo(b.order ?? ""));

    for (final FacilityDis dis in apiDisList) {
      final FacilitySummaryNew? facilitySummaryDataItem = dis.facility;
      if (facilitySummaryDataItem == null) continue;
      if (facilitySummaryDataItem.isMainLimit ?? false) {
        final int existing =
            (facilitySummaryDataItem.presentLimit ?? 0).toInt();
        final int proposed =
            (facilitySummaryDataItem.proposedLimit ?? 0).toInt();
        final int outstanding =
            (facilitySummaryDataItem.presentOutstanding ?? 0).toInt();

        totalExistingLimit += existing;
        totalProposedLimit += proposed;
        totalOutstandingAmount += outstanding;
      }

      final String message = viewModel
          .tooltipMessageFor(facilitySummaryDataItem); // read from VM cache

      final Reference benchRef = viewModel.matchOrFirstById(
        viewModel.benchmark,
        facilitySummaryDataItem.index,
      );

      final List<Reference> selectedSustainability = (() {
        final String raw =
            (facilitySummaryDataItem.sustainabilityClassification ?? "");
        if (raw.trim().isEmpty) return <Reference>[];
        final Set<String> ids = raw
            .split(",")
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toSet();
        return viewModel.sustanabilityClassifications
            .where((r) => ids.contains(r.id?.toString()))
            .toList();
      })();
      final bool requireIndex =
          (facilitySummaryDataItem.limitCategory?.toUpperCase() == "F");
      final bool isF =
          (facilitySummaryDataItem.limitCategory?.toUpperCase() == "F");
      tableRows.add([
        Text("${dis.order}"),

        TextButton(
          onPressed: () {
            router.go(
              Routes.createFacility,
              extra: CreateFacilityArgs(
                facilityId: facilitySummaryDataItem.facilityId,
                facility: Facility(
                  facilitySummaryItem: facilitySummaryDataItem,
                  limitGroupName: facilitySummaryDataItem.productCode,
                  facilityDescription: viewModel.facility.facilityDescription,
                  limitDescription:
                      viewModel.facility.facilityDescription?.name,
                  facilityId: facilitySummaryDataItem.facilityId,
                  limitCode: viewModel.facility.facilityDescription?.id,
                  facilityMasterId: facilitySummaryDataItem.facilityMasterId,
                  rimNo: facilitySummaryDataItem.rimNo,
                  selectedProductTypeValue:
                      viewModel.facility.selectedProductTypeValue,
                  limitGroup: facilitySummaryDataItem.limitGroup,
                  isMainLimit: facilitySummaryDataItem.isMainLimit,
                ),
                showCreateFacilityForm: false,
              ),
            );
          },
          child: Text(
            " ${facilitySummaryDataItem.limitNo ?? ""}",
            style: const TextStyle(
              fontSize: 13,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.darkBlue,
            ),
          ),
        ),

        Text(facilitySummaryDataItem.controllingLimitNo ?? ""),

        AddSublimitButton(
          viewModel: viewModel,
          limitGroup: facilitySummaryDataItem.limitGroup,
          selectedRim: selectedRim,
          isMainLimit: false,
          proposedLimit: facilitySummaryDataItem.proposedLimit,
          limitNumber: facilitySummaryDataItem.limitNo,
        ),

        Text(
          viewModel
                  .facilityTypeNameById(
                    facilitySummaryDataItem.limitDescription,
                  )
                  .name ??
              "",
        ),

        Align(
          alignment: Alignment.centerRight,
          child: Text(
            _kFmt.format((facilitySummaryDataItem.presentLimit ?? 0).toInt()),
            style: const TextStyle(color: AppColors.darkBlue),
          ),
        ),

        //proposed limit ---editable
        CustomTooltip(
          message: message,
          child: CustomTextField(
            textAlign: TextAlign.end,
            prefixIcon: CustomDropdown<Reference>(
              showClearIcon: false,
              width: 75.w,
              height: null,
              items: viewModel.currencyCodes,
              selectedItems: [
                viewModel.matchOrFirstByName(
                  viewModel.currencyCodes,
                  facilitySummaryDataItem.currency,
                ),
              ],
              onSelected: (selectedValue) {
                if (selectedValue.isNotEmpty) {
                  final sel = selectedValue.first;
                  facilitySummaryDataItem.currency = sel.name;
                  facilitySummaryDataItem.isEdited = true;
                  viewModel.facility.proposedLimitValue =
                      sel; // keep your UI bindin
                  viewModel.updateConvertedTooltipFor(
                    facilitySummaryDataItem,
                    rebuild: true,
                  );
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
            initialValue: _kFmt
                .format((facilitySummaryDataItem.proposedLimit ?? 0).toInt()),
            inputFormatters: [
              LengthLimitingTextInputFormatter(15),
              FilteringTextInputFormatter.digitsOnly,
              ThousandsSeparatorFormatter(),
            ],
            onChanged: (String? value) {
              final String raw = (value ?? "").replaceAll(RegExp("[^0-9]"), "");
              facilitySummaryDataItem.proposedLimit =
                  raw.isEmpty ? 0 : int.parse(raw);
              facilitySummaryDataItem.isEdited = true;
              viewModel.updateConvertedTooltipFor(facilitySummaryDataItem);
            },
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: Text(
            _kFmt.format(
              (facilitySummaryDataItem.presentOutstanding ?? 0).toInt(),
            ),
            style: const TextStyle(color: AppColors.darkBlue),
          ),
        ),

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
                labelStyle: const TextStyle(fontSize: AppStyle.columnName),
                label: Text("${data?[index].name}"),
              ),
            );
          },
          itemBuilder: (context, item, isDisabled, isSelected) {
            return ListTile(
              dense: true,
              minVerticalPadding: 0,
              minTileHeight: 34,
              title: Text(item.name ?? ""),
            );
          },
          items: (viewModel.sustanabilityClassifications),
          onSelected: (value) {
            final ids = value
                .map((r) => r.id?.toString())
                .where((id) => id != null && id.isNotEmpty)
                .cast<String>()
                .toList();
            facilitySummaryDataItem.sustainabilityClassification =
                ids.join(", ");
            facilitySummaryDataItem.isEdited = true;
          },
        ),

        //tenor days ---editable
        CustomTooltip(
          message: (facilitySummaryDataItem.tenorValue != null ||
                  (facilitySummaryDataItem.tenorUnit ?? "").isNotEmpty)
              ? "Initial Value: ${facilitySummaryDataItem.tenorValue ?? ""} "
                      "${facilitySummaryDataItem.tenorUnit ?? ""}"
                  .trim()
              : "",
          child: CustomTextField(
            width: 150.w,
            validator: (_) {
              final noUnit = (facilitySummaryDataItem.tenorUnit == null ||
                  facilitySummaryDataItem.tenorUnit!.trim().isEmpty);
              final noValue = (facilitySummaryDataItem.tenorValue == null);
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
                viewModel.matchOrFirstByName(
                  viewModel.period,
                  facilitySummaryDataItem.tenorUnit,
                ),
              ],
              onSelected: (selectedValue) {
                if (selectedValue.isNotEmpty) {
                  final sel = selectedValue.first;
                  facilitySummaryDataItem.tenorUnit = sel.name;
                  facilitySummaryDataItem.isEdited = true;
                  viewModel.facility.proposedLimitValue =
                      sel; // keep UI binding
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
            initialValue: (facilitySummaryDataItem.tenorValue != null)
                ? "${facilitySummaryDataItem.tenorValue}"
                : "",
            keyboardType: TextInputType.number,
            onChanged: (String? value) {
              final match = RegExp(r"\d+").firstMatch(value ?? "");
              facilitySummaryDataItem.tenorValue =
                  match != null ? int.tryParse(match.group(0)!) : null;

              facilitySummaryDataItem.isEdited = true;
            },
          ),
        ),

        //index -------editable
        CustomTooltip(
          message: (benchRef.name ?? "").isNotEmpty
              ? "Initial Value: ${benchRef.name}"
              : "",
          child: CustomDropdown<Reference>(
            showClearIcon: false,
            validationMessage: requireIndex ? "Index is required" : null,
            items: viewModel.benchmark,
            selectedItems: [
              viewModel.matchOrFirstById(
                viewModel.benchmark,
                facilitySummaryDataItem.index,
              ),
            ],
            onSelected: (selectedValue) {
              if (selectedValue.isNotEmpty) {
                final sel = selectedValue.first;
                facilitySummaryDataItem.index =
                    sel.id?.toString() ?? sel.name ?? "";
                facilitySummaryDataItem.isEdited = true;
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
        ),

        //margin -------editable
        CustomTooltip(
          message: (facilitySummaryDataItem.marginValue != null ||
                  (facilitySummaryDataItem.marginSign ?? "").isNotEmpty)
              ? "Initial Value: "
                  "${(facilitySummaryDataItem.marginSign ?? "").trim()} "
                      "${facilitySummaryDataItem.marginValue ?? ""}"
                  .trim()
              : "",
          child: CustomTextField(
            validator: (_) {
              final signMissing = isF &&
                  ((facilitySummaryDataItem.marginSign ?? "").trim().isEmpty);
              final valMissing = (facilitySummaryDataItem.marginValue == null);
              return (signMissing || valMissing)
                  ? "Margin (sign & value) is required"
                  : null;
            },
            width: 120.w,
            prefixIcon: facilitySummaryDataItem.limitCategory != "F"
                ? null
                : CustomDropdown<Reference>(
                    showClearIcon: false,
                    width: 60.w,
                    height: null,
                    items: viewModel.marginSign,
                    selectedItems: [
                      viewModel.matchOrFirstByRef1(
                        viewModel.marginSign,
                        facilitySummaryDataItem.marginSign,
                      ),
                    ],
                    onSelected: (selectedValue) {
                      if (selectedValue.isNotEmpty) {
                        final sel = selectedValue.first;
                        facilitySummaryDataItem.marginSign = sel.reference1;
                        facilitySummaryDataItem.isEdited = true;
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
            initialValue: facilitySummaryDataItem.marginValue != null
                ? "${facilitySummaryDataItem.marginValue ?? ''}"
                : "",
            keyboardType: TextInputType.number,
            onChanged: (String? value) {
              final match = RegExp(r"[-+]?\d*\.?\d+").firstMatch(value ?? "");
              facilitySummaryDataItem.marginValue =
                  match != null ? num.tryParse(match.group(0)!) : null;
              facilitySummaryDataItem.isEdited = true;
            },
          ),
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

        viewModel.canEdit
            ? DeleteFacilityButton(
                serialNumber: facilitySummaryDataItem.facilityId,
                viewModel: viewModel,
              )
            : const SizedBox(),
      ]);
    }
    tableRows.add([
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      Text(
        _kFmt.format(totalExistingLimit),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        _kFmt.format(totalProposedLimit),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        _kFmt.format(totalOutstandingAmount),
        style: const TextStyle(fontWeight: FontWeight.bold),
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
}
