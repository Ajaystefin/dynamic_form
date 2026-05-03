import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
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
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/view.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/add_facility_button.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/add_sublimit_button.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/allocate_project.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/create_facility_button.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/delete_facility_button.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/filter_table.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";

final NumberFormat _kFmt = NumberFormat("#,###");

// ignore: must_be_immutable
class ProjectSpecificLimitTable extends StatelessWidget {
  ProjectSpecificLimitTable({
    required this.viewModel,
    required this.customer,
    super.key,
    this.groupIndex,
  });
  final FacilitiesSummaryViewModel viewModel;
  final FacilitySummaryList customer;
  final int? groupIndex;
  int totalExistingLimit = 0;
  int totalProposedLimit = 0;
  int totalOutstandingAmount = 0;
  @override
  Widget build(BuildContext context) {
    final rim =
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

    // Show the main table *only* if there's at least one non-header row.
    // final bool hasNonHeaderLimits = limits.any((d) => (d.order?.trim() !=
    // '0'));
    // that is not excluded (not 935 and not CLT).
    final bool hasNonHeaderLimits =
        (selectedGroup?.facilityLimits ?? const <FacilityDis>[]).any((dis) {
      final FacilitySummaryNew? facility = dis.facility;
      if (facility == null) return false;
      final String? limitDescription = facility.limitDescription?.toString();
      final String productCode =
          (facility.productCode ?? "").trim().toUpperCase();
      final bool notExcluded =
          limitDescription != "935" && productCode != "CLT";
      final bool isNonHeader = (dis.order ?? "").trim() != "0";
      return notExcluded && isNonHeader;
    });

    String? headerLimitNoFromGroup;
    final limits = selectedGroup?.facilityLimits ?? const <FacilityDis>[];
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
    final int? selectedRim = viewModel.extractRimId(rim?.rimName);

    return CustomAccordion(
      isSubSection: true,
      title: title,
      children: [
        const Gap(),
        CustomRawTable(
          // key: UniqueKey(),
          key: ValueKey('psl-header-${selectedRim ?? ''}'),
          columns: getProjectTableColumns(),
          rows: getProjectTableRows(),
        ),
        const Gap(),
        hasNonHeaderLimits
            ? CustomRawTable(
                key: UniqueKey(),
                autoFitWidth: true,
                isFilterTable: true,
                rowHeight: 50,
                columns: getTableColumns(),
                rows: getTableRows(context),
              )
            : AddFacilitySubLimitBox(
                label: "facilities.facilitySummary.createFacility".tr(),
                limitGroup: ServerConstants.projectSpecificLimitsID,
                selectedRim: selectedRim,
                proposedLimit: viewModel.proposedLimitForGroup(
                  ServerConstants.projectSpecificLimitsID,
                  rimNo: selectedRim!,
                ),
                isMainLimit: true,
                totalProposedLimit: totalProposedLimit,
                limitNumber: headerLimitNoFromGroup,
              ),
        const Gap(),
        if (hasNonHeaderLimits && viewModel.canEdit)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AddFacilityButton(
                viewModel: viewModel,
                limitGroup: ServerConstants.projectSpecificLimitsID,
                selectedRim: selectedRim,
                isMainLimit: false,
                totalProposedLimit: totalProposedLimit,
                proposedLimit: viewModel.proposedLimitForGroup(
                  ServerConstants.projectSpecificLimitsID,
                  rimNo: selectedRim!,
                ),
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
                  final isValid = viewModel.formKey.currentState?.validate();
                  if (isValid == false) {
                    AlertManager()
                        .showFailureToast("Please fill required fields");
                    return;
                  }
                  viewModel.saveFacilitySummaryList(
                    customer,
                    limitGroup: 11315,
                    selectedRim: selectedRim,
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

    final List<List<Widget>> tableRows = <List<Widget>>[filterRows];

    final RimSummary? rim =
        (customer.rims?.isNotEmpty ?? false) ? customer.rims!.first : null;
    final List<RimGroup> groups = rim?.groups ?? const <RimGroup>[];

    final RimGroup? selectedGroup =
        (groupIndex != null && groupIndex! >= 0 && groupIndex! < groups.length)
            ? groups[groupIndex!]
            : null;

    final List<FacilityDis> apiDisList = List<FacilityDis>.from(
      selectedGroup?.facilityLimits ?? const <FacilityDis>[],
    ).where((d) {
      // keep non-header rows only means remove order '0' row
      if ((d.order ?? "").trim() == "0") return false;
      final FacilitySummaryNew? f = d.facility;
      if (f == null) return false;
      final String? ld = f.limitDescription?.toString();
      final String pc = (f.productCode ?? "").trim().toUpperCase();
      // exclude: Limit Caps (935) or product code CLT
      return ld != "935" && pc != "CLT";
    }).toList()
      ..sort((a, b) => (a.order ?? "").compareTo(b.order ?? ""));

    final int? selectedRim = viewModel.extractRimId(rim?.rimName);

    for (final FacilityDis dis in apiDisList) {
      final FacilitySummaryNew? f = dis.facility;
      if (f == null) continue;
      totalExistingLimit =
          (selectedGroup?.amounts?.totalExistingLimit ?? 0).toInt();
      totalProposedLimit =
          (selectedGroup?.amounts?.totalProposedLimit ?? 0).toInt();
      totalOutstandingAmount =
          (selectedGroup?.amounts?.totalCurrentOutstanding ?? 0).toInt();

      final String message = viewModel.tooltipMessageFor(f);
      final Reference benchRef =
          viewModel.matchOrFirstById(viewModel.benchmark, f.index);

      final List<Reference> selectedSustainability = (() {
        final String raw = f.sustainabilityClassification ?? "";
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
          viewModel.facilityTypeNameById(f.limitDescription).reference5 !=
                  ServerConstants.newProductCode
              ? (f.limitCategory?.toUpperCase() == "F")
              : false;
      final bool isF = (f.limitCategory?.toUpperCase() == "F");

      final String cln = (f.controllingLimitNo ?? "").trim();
      int? parentCap;

      if (cln.isNotEmpty) {
        //Try parent from non-header list (existing behavior)
        final FacilitySummaryNew parent = apiDisList
            .map((d) => d.facility)
            .whereType<FacilitySummaryNew>()
            .firstWhere(
              (p) => (p.limitNo ?? "").trim() == cln,
              orElse: FacilitySummaryNew.new,
            );

        parentCap = parent.limitNo == null ? null : (parent.proposedLimit ?? 0);

        // Fallback ONLY for PSPL parent which is usually header row (order '0')
        if ((parentCap == null || parentCap == 0) &&
            cln.toUpperCase().contains("PSPL")) {
          final FacilitySummaryNew headerParent =
              (selectedGroup?.facilityLimits ?? const <FacilityDis>[])
                  .map((d) => d.facility)
                  .whereType<FacilitySummaryNew>()
                  .firstWhere(
                    (p) => (p.limitNo ?? "").trim() == cln,
                    orElse: FacilitySummaryNew.new,
                  );

          final int? headerCap = headerParent.limitNo == null
              ? null
              : (headerParent.proposedLimit ?? 0);

          if (headerCap != null && headerCap > 0) {
            parentCap = headerCap;
          }
        }
      }

      tableRows.add([
        Text("${dis.order}"),
        Center(
          child: CustomIcon(
            onTap: () {
              DialogHelper.showCustomDialog(
                barrierDismissible: false,
                width: 500.w,
                title: "facilities.facilitySummary.allocateProject".tr(),
                content: BlocProvider.value(
                  value: viewModel,
                  child: AllocateProject(viewModel: viewModel, facility: f),
                ),
                context: context,
              );
            },
            icon: Icons.add_circle_outline_sharp,
            iconColor: AppColors.buttonBackground,
          ),
        ),
        Text("${f.projectName}"),
        TextButton(
          onPressed: () {
            router.go(
              Routes.createFacility,
              extra: CreateFacilityArgs(
                facilityId: f.facilityId,
                facility: Facility(
                  facilitySummaryItem: f,
                  facilityDescription:
                      viewModel.facility.facilityTypeSelectedValue,
                  limitGroupName: f.productCode,
                  limitCode: viewModel.facility.facilityDescription?.id,
                  limitDescription:
                      viewModel.facility.facilityDescription?.name,
                  facilityId: f.facilityId,
                  facilityMasterId: f.facilityMasterId,
                  rimNo: f.rimNo,
                  limitGroup: f.limitGroup,
                  selectedProductTypeValue:
                      viewModel.facility.selectedProductTypeValue,
                  isMainLimit: f.isMainLimit,
                  totalProposedLimit: parentCap,
                  proposedLimit: parentCap,
                ),
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
          totalProposedLimit: f.proposedLimit,
          limitGroup: f.limitGroup,
          selectedRim: selectedRim,
          isMainLimit: false,
          proposedLimit:
              viewModel.proposedLimitForGroup(11315, rimNo: selectedRim!),
          limitNumber: f.limitNo,
          projectName: ((f.limitGroup == 11315 || f.limitGroup == 11317)
              ? (f.projectName ?? "").trim()
              : null),
        ),

        Text(viewModel.facilityTypeNameById(f.limitDescription).name ?? ""),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            _kFmt.format((f.presentLimit ?? 0).toInt()),
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
                  f.currency,
                ),
              ],
              onSelected: (selectedValue) {
                if (selectedValue.isNotEmpty) {
                  final Reference sel = selectedValue.first;
                  f
                    ..currency = sel.name
                    ..isEdited = true;
                  viewModel.facility.proposedLimitValue =
                      sel; // keep your UI bindin
                  viewModel.updateConvertedTooltipFor(f, rebuild: true);
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
            initialValue: _kFmt.format((f.proposedLimit ?? 0).toInt()),
            inputFormatters: [
              LengthLimitingTextInputFormatter(15),
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (String? value) {
              final String raw = (value ?? "").replaceAll(RegExp("[^0-9]"), "");
              f
                ..proposedLimit = raw.isEmpty ? 0 : int.parse(raw)
                ..proposedLimitAED = raw.isEmpty ? 0 : int.tryParse(raw)
                ..isEdited = true;
              viewModel.updateConvertedTooltipFor(f);
            },
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: Text(
            _kFmt.format((f.presentOutstanding ?? 0).toInt()),
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
          items: viewModel.sustanabilityClassifications,
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
          message: (f.tenorValue != null || (f.tenorUnit ?? "").isNotEmpty)
              ? "Initial Value: ${f.tenorValue ?? ""} ${f.tenorUnit ?? ""}"
                  .trim()
              : "",
          child: CustomTextField(
            width: 150.w,
            validator: viewModel
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
              items: viewModel.period,
              selectedItems: [
                viewModel.matchPeriodByAny(viewModel.period, f.tenorUnit),
              ],
              onSelected: (selectedValue) {
                if (selectedValue.isNotEmpty) {
                  final sel = selectedValue.first;
                  f
                    ..tenorUnit = sel.name
                    ..isEdited = true;
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
          message: (benchRef.name ?? "").isNotEmpty
              ? "Initial Value: ${benchRef.name}"
              : "",
          child: CustomDropdown<Reference>(
            showClearIcon: false,
            validationMessage: requireIndex ? "Index is required" : null,
            items: viewModel.benchmark,
            selectedItems: [
              viewModel.matchOrFirstById(viewModel.benchmark, f.index),
            ],
            onSelected: (selectedValue) {
              if (selectedValue.isNotEmpty) {
                final sel = selectedValue.first;
                f
                  ..index = sel.id?.toString() ?? sel.name ?? ""
                  ..isEdited = true;
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

        //spread -------editable
        CustomTooltip(
          message: (f.marginValue != null || (f.marginSign ?? "").isNotEmpty)
              ? "Initial Value: ${(f.marginSign ?? "").trim()} "
                      "${f.marginValue ?? ""}"
                  .trim()
              : "",
          child: CustomTextField(
            width: 120.w,
            validator:
                viewModel.facilityTypeNameById(f.limitDescription).reference5 ==
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
            prefixIcon: CustomDropdown<Reference>(
              showClearIcon: false,
              width: 60.w,
              height: null,
              items: viewModel.marginSign,
              selectedItems: [
                viewModel.matchOrFirstByRef1(
                  viewModel.marginSign,
                  f.marginSign,
                ),
              ],
              onSelected: (selectedValue) {
                if (selectedValue.isNotEmpty) {
                  final sel = selectedValue.first;
                  f
                    ..marginSign = sel.reference1
                    ..isEdited = true;
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
                serialNumber: f.facilityId,
                viewModel: viewModel,
              )
            : const SizedBox(),
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
    final tableRows = <List<Widget>>[];
    const message = "";

    // Find "order == 1" row from this group's limits
    final RimSummary? rim =
        (customer.rims?.isNotEmpty ?? false) ? customer.rims!.first : null;
    final List<RimGroup> groups = rim?.groups ?? const <RimGroup>[];
    final RimGroup? selectedGroup =
        (groupIndex != null && groupIndex! >= 0 && groupIndex! < groups.length)
            ? groups[groupIndex!]
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
      viewModel.projectSpecificNameCtrl.clear();
      viewModel.projectExistingCtrl.clear();
      viewModel.projectProposedCtrl.clear();
      viewModel.facility.proposedLimitValue =
          null; // so dropdown defaults to AED
    } else {
      final int? selectedRim = viewModel.extractRimId(rim?.rimName);

      if (selectedRim != null) {
        final nameCtrl = viewModel.psNameCtrl(selectedRim);
        final proposedCtrl = viewModel.psProposedCtrl(selectedRim);

        // Prefill ONLY if empty / not yet initialized
        final String apiName = (facility.projectName ?? "").trim();
        if (nameCtrl.text.trim().isEmpty) {
          nameCtrl.text = apiName;
        }
        final existing = (facility.presentLimit ?? 0).toInt();
        if (viewModel.proposedLimitForGroup(11315, rimNo: selectedRim) ==
            null) {
          viewModel.setProjectExistingLimitInput(
            existing.toString(),
            groupId: 11315,
            rimNo: selectedRim,
          );
        }
        final proposed = (facility.proposedLimit ?? 0).toInt();
        if (proposedCtrl.text.trim().isEmpty) {
          proposedCtrl.text = _kFmt.format(proposed);
        }
        if (viewModel.proposedLimitForGroup(11315, rimNo: selectedRim) ==
            null) {
          viewModel.setProjectProposedLimitInput(
            proposed.toString(),
            groupId: 11315,
            rimNo: selectedRim,
          );
        }

        final String apiCurrency = (facility.currency ?? "AED").trim();
        final Reference apiCurrencyRef =
            viewModel.matchOrFirstByName(viewModel.currencyCodes, apiCurrency);
        if (viewModel.headerCurrencyFor(11315, selectedRim) == null) {
          viewModel.setHeaderCurrencyFor(11315, selectedRim, apiCurrencyRef);
        }
      }
    }

    final int? selectedRim = viewModel.extractRimId(rim?.rimName);
    final String selectedCode =
        (viewModel.headerCurrencyFor(11315, selectedRim!)?.name ?? "AED")
            .trim();
    tableRows.add([
      // Name
      CustomTextField(
        controller: viewModel.psNameCtrl(selectedRim),
      ),
      // Existing Limits
      Text(
        (facility?.presentLimit != null)
            ? _kFmt.format((facility!.presentLimit!).toInt())
            : "",
        style: const TextStyle(color: AppColors.darkBlue),
      ),

      // Proposed Limit + Currency
      CustomTooltip(
        message: message,
        child: CustomTextField(
          controller: viewModel.psProposedCtrl(selectedRim),
          inputFormatters: [
            LengthLimitingTextInputFormatter(15),
            FilteringTextInputFormatter.digitsOnly,
            ThousandsSeparatorFormatter(),
          ],
          prefixIcon: CustomDropdown<Reference>(
            showClearIcon: false,
            width: 80.w,
            height: null,
            items: viewModel.currencyCodes,
            selectedItems: [
              viewModel.matchOrFirstByName(
                viewModel.currencyCodes,
                selectedCode,
              ),
            ],
            onSelected: (selectedValue) {
              if (selectedValue.isNotEmpty) {
                final Reference sel = selectedValue.first;
                viewModel.setHeaderCurrencyFor(11315, selectedRim, sel);
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
          keyboardType: TextInputType.number,
          onChanged: (String? value) {
            final raw = (value ?? "").replaceAll(",", "");
            viewModel.setProjectProposedLimitInput(
              raw,
              groupId: 11315,
              rimNo: selectedRim,
            );
            // viewModel.setProjectProposedLimitInput(raw,
            //     groupId: 11315, rimNo: selectedRim);
          },
        ),
      ),

      Text(
        (facility?.presentOutstanding != null)
            ? _kFmt.format((facility!.presentOutstanding!).toInt())
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
