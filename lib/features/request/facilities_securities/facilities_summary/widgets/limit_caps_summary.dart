import "package:easy_localization/easy_localization.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/state.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/delete_facility_button.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/filter_table.dart"
    show FilterTableWidget;
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";

/// Number formatter used to display limit cap amounts with
/// thousands separators.
final NumberFormat _kFmt = NumberFormat("#,###");

/// Widget for displaying the limit caps summary table.
///
/// Presents limit cap information and allocation details for the
/// selected customer and limit group.
class LimitCapsSummary extends StatelessWidget {
  /// Creates a limit caps summary widget.
  const LimitCapsSummary({
    required this.viewModel,
    required this.customer,
    super.key,
    this.groupIndex,
  });

  /// View model containing facility summary data and actions.
  final FacilitiesSummaryViewModel viewModel;

  /// Customer whose limit cap information is displayed.
  final FacilitySummaryList customer;

  /// Index used to retrieve the corresponding limit group data.
  final int? groupIndex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FacilitiesSummaryViewModel, FacilitiesSummaryState>(
      // You can add buildWhen if you want to narrow rebuilds; simplest is to
      // rebuild on any state change.
      builder: (context, state) {
        // 1) Locate the *fresh* customer by matching the same rim name as when
        // dialog opened
        final String? rimNameAtOpen = (customer.rims?.isNotEmpty ?? false)
            ? customer.rims!.first.rimName
            : null;

        final List<FacilitySummaryList> all =
            viewModel.customerFacilities ?? const <FacilitySummaryList>[];
        final FacilitySummaryList effectiveCustomer = (rimNameAtOpen == null)
            ? customer
            : (all.firstWhere(
                (c) => c.rims?.any((r) => r.rimName == rimNameAtOpen) ?? false,
                orElse: () => customer,
              ));

        // 2) Work from the refreshed customer/rim/groups
        final RimSummary? rim = (effectiveCustomer.rims?.isNotEmpty ?? false)
            ? effectiveCustomer.rims!.first
            : null;
        final List<RimGroup> groups = rim?.groups ?? const <RimGroup>[];

        String title = "";
        final RimGroup? selectedGroup = (groupIndex != null &&
                groupIndex! >= 0 &&
                groupIndex! < groups.length)
            ? groups[groupIndex!]
            : null;
        if (selectedGroup != null) {
          title = selectedGroup.groupName ?? title;
        }

        final bool hasApiLimits = groups
            .expand((g) => g.facilityLimits ?? const <FacilityDis>[])
            .any((dis) {
          final f = dis.facility;
          if (f == null) {
            return false;
          }
          final bool matchesCap = (f.limitDescription?.toString() == "935") ||
              ((f.productCode ?? "").trim().toUpperCase() == "CLT");
          return matchesCap;
        });

        // Required cap types, and what’s present now
        final Set<int> requiredCapTypes = {14492, 14493, 14494};
        final Set<int> presentCapTypes = groups
            .expand((g) => g.facilityLimits ?? const <FacilityDis>[])
            .where((dis) {
              final f = dis.facility;
              if (f == null) {
                return false;
              }
              final bool matchesCap =
                  (f.limitDescription?.toString() == "935") ||
                      ((f.productCode ?? "").trim().toUpperCase() == "CLT");
              return matchesCap && (f.limitCapType != null);
            })
            .map((dis) => int.tryParse(dis.facility!.limitCapType.toString()))
            .whereType<int>()
            .toSet();

        final bool allLimitCapTypesPresent =
            requiredCapTypes.difference(presentCapTypes).isEmpty;

        return Column(
          children: [
            const Gap(),
            // OPTION: show a row-level spinner when only the table is in-flight
            if (state.tableLoaderStatus == LoadingStatus.loading)
              const Center(child: CupertinoActivityIndicator())
            else
              CustomRawTable(
                key: UniqueKey(),
                rowHeight: 46,
                isFilterTable: true,
                columns: getTableColumns(),
                // IMPORTANT: pass the *fresh* customer’s selectedGroup to build
                // rows from updated data
                rows: getTableRows(context, selectedGroup, effectiveCustomer),
              ),
            if (!hasApiLimits) const Center(child: Text("No Data Found")),
            const Gap(),
            if (hasApiLimits)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    label: "Add Limit Caps".tr(),
                    onPressed: allLimitCapTypesPresent
                        ? null
                        : () async {
                            final Reference limitCapsRef =
                                viewModel.matchOrFirstById(
                              viewModel.facilityTypes,
                              935.toString(),
                            );
                            final int? selectedRimNo =
                                viewModel.extractRimId(rim?.rimName);
                            router.go(
                              Routes.createFacility,
                              extra: {
                                "facilityArgs": CreateFacilityArgs(
                                  facility: Facility(
                                    facilityDescription: limitCapsRef,
                                    limitDescription: limitCapsRef.name,
                                    limitCode: limitCapsRef.id,
                                    limitGroup: 11312,
                                    rimNo: selectedRimNo,
                                    selectedProductTypeValue: viewModel
                                        .facility.selectedProductTypeValue,
                                    isMainLimit: true,
                                  ),
                                  showCreateFacilityForm: true,
                                ),
                              },
                            );
                          },
                  ),
                  CustomButton(
                    label: "common.save".tr(),
                    onPressed: () async {
                      await viewModel
                          .saveLimitCapsSummaryList(effectiveCustomer);
                    },
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  /// Returns the column definitions for the limit caps summary table.
  ///
  /// Configures the columns displayed for limit cap type, limit details,
  /// limit amounts, and available actions.
  List<TableColumn> getTableColumns() {
    return [
      TableColumn(label: Text("facilities.facilitySummary.sNo".tr())),
      TableColumn(label: Text("facilities.facilitySummary.limitNo".tr())),
      TableColumn(label: Text("facilities.createFacility.limitCapType".tr())),
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
      TableColumn(label: Text("facilities.facilitySummary.action".tr())),
    ];
  }

  /// Builds the table rows for the limit caps summary.
  ///
  /// Uses the latest customer and RIM group data to generate facility
  /// rows, editable limit cap values, and summary totals.
  List<List<Widget>> getTableRows(
    BuildContext context,
    RimGroup? selectedGroup,
    FacilitySummaryList effectiveCustomer,
  ) {
    final filterRows = <Widget>[
      const SizedBox.shrink(),
      const FilterTableWidget(),
      const FilterTableWidget(),
      const FilterTableWidget(),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
    ];

    final List<List<Widget>> tableRows = <List<Widget>>[filterRows];

    int totalExistingLimit = 0;
    int totalProposedLimit = 0;

    // Work from refreshed rim/groups
    final RimSummary? rim = (effectiveCustomer.rims?.isNotEmpty ?? false)
        ? effectiveCustomer.rims!.first
        : null;
    final List<RimGroup> groups = rim?.groups ?? const <RimGroup>[];

    // Filter (935 OR CLT)
    final List<FacilityDis> apiDisList = (groups
            .expand((g) => g.facilityLimits ?? const <FacilityDis>[])
            .where((dis) {
      final f = dis.facility;
      if (f == null) {
        return false;
      }
      final bool matchesCap = (f.limitDescription?.toString() == "935") ||
          ((f.productCode ?? "").trim().toUpperCase() == "CLT");
      return matchesCap;
    }).toList() // <-- call toList() on the iterable
        )
          ..sort(
            (a, b) => (a.order ?? "").compareTo(b.order ?? ""),
          );

    for (int i = 0; i < apiDisList.length; i++) {
      final FacilityDis dis = apiDisList[i];
      final FacilitySummaryNew? f = dis.facility;
      if (f == null) {
        continue;
      }

      final int existing = (f.presentLimit ?? 0).toInt();
      final int proposed = f.proposedLimit ?? 0;

      totalExistingLimit += existing;
      totalProposedLimit += proposed;

      final int sNo = i + 1;

      tableRows.add([
        Text("$sNo"),
        TextButton(
          onPressed: () {
            router.go(
              Routes.createFacility,
              extra: {
                "facilityArgs": CreateFacilityArgs(
                  facilityId: f.facilityId,
                  facility: Facility(
                    facilityDescription: viewModel.facility.facilityDescription,
                    limitDescription:
                        viewModel.facility.facilityDescription?.name,
                    facilityId: f.facilityId,
                    facilityMasterId: f.facilityMasterId,
                    limitCode: viewModel.facility.facilityDescription?.id,
                    rimNo: f.rimNo,
                    selectedProductTypeValue:
                        viewModel.facility.selectedProductTypeValue,
                    limitGroup: f.limitGroup,
                    isMainLimit: f.isMainLimit,
                  ),
                  showCreateFacilityForm: false,
                ),
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
        Text(viewModel.limitCapsTypeNameById(f.limitCapType)),
        Text(viewModel.facilityTypeNameById(f.limitDescription).name ?? ""),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            _kFmt.format((f.presentLimit ?? 0).toInt()),
            style: const TextStyle(color: AppColors.darkBlue),
          ),
        ),
        if (!f.isSharedLimit! && Utils.isGroupApplication())
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              textAlign: TextAlign.end,
              _kFmt.format(f.proposedLimit ?? 0),
            ),
          )
        else
          CustomTextField(
            textAlign: TextAlign.end,
            initialValue: _kFmt.format(f.proposedLimit ?? 0),
            inputFormatters: [
              LengthLimitingTextInputFormatter(21),
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (String? value) {
              f
                ..proposedLimit = int.tryParse(value ?? "")
                ..proposedLimitAED = int.tryParse(value ?? "")
                ..isEdited = true;
            },
          ),
        DeleteFacilityButton(
          serialNumber: f.facilityId,
          viewModel: viewModel,
        ),
      ]);
    }

    tableRows.add([
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          _kFmt.format(totalExistingLimit),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          _kFmt.format(totalProposedLimit),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(),
    ]);

    return tableRows;
  }
}
