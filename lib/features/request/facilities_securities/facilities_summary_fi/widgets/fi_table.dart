import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/accordion.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/fields/applicable_pricing.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/fields/existing_limits.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/fields/margin.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/fields/outstanding.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/fields/proposed_limits.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/fields/sustanability_classification.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/fields/tenor_days.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/model.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/widgets/add_sublimit_button.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/widgets/add_sublimit_dialog_box.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/widgets/delete_facility_button.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';

import 'package:wcas_frontend/core/services/route_service.dart';

class FinancialInstitutionTable extends StatelessWidget {
  final FacilitiesSummaryFiViewModel viewModel;
  final FacilityGroup? facilityGroup;
  final String tableTitle;
  final CustomerFacility customer;

  const FinancialInstitutionTable({
    super.key,
    required this.tableTitle,
    required this.viewModel,
    required this.facilityGroup,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAccordion(
      title: tableTitle,
      children: [
        const SizedBox(height: 20),
        CustomRawTable(
          key: UniqueKey(),
          columns: getTableColumns(),
          rows: getTableRows(context),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 14.0),
          child: CustomButton(
            label: ("facilities.facilitySummary.addFacility".tr()),
            onPressed: () {
              DialogHelper.showCustomDialog(
                barrierDismissible: false,
                title: "facilities.facilitySummary.addFacility".tr(),
                content: BlocProvider.value(
                  value: viewModel,
                  child: const AddSubLimitDialogBoxFi(),
                ),
                context: context,
              );
            },
          ),
        )
      ],
    );
  }

  List<TableColumn> getTableColumns() {
    return [
      TableColumn(label: Text('facilities.facilitySummary.sNo'.tr())),
      TableColumn(label: Text("facilities.facilitySummary.addSublimit".tr())),
      TableColumn(label: Text('facilities.facilitySummary.limitNo'.tr())),
      TableColumn(label: Text('facilities.facilitySummary.details'.tr())),
      TableColumn(
          label: Text('facilities.facilitySummary.classification'.tr())),
      TableColumn(
          label: Text('facilities.facilitySummary.existingLimits'.tr())),
      TableColumn(
          label: Text('facilities.facilitySummary.proposedLimits'.tr())),
      TableColumn(label: Text('facilities.facilitySummary.os'.tr())),
      TableColumn(label: Text('facilities.facilitySummary.tenorDays'.tr())),
      TableColumn(
          label: Text('facilities.facilitySummary.applicablePricing'.tr())),
      TableColumn(label: Text('facilities.facilitySummary.margin'.tr())),
      TableColumn(
          label: Text('facilities.facilitySummary.linkedFacility'.tr())),
      TableColumn(label: Text('facilities.facilitySummary.action'.tr())),
    ];
  }

  List<List<Widget>> getTableRows(BuildContext context) {
    List<Facility> facilities = facilityGroup?.facilities ?? [];
    List<List<Widget>> tableRows = [];
    int totalExistingLimit = 0;
    int totalProposedLimit = 0;
    int totalOutstandingAmount = 0;

    for (int index = 0; index < facilities.length; index++) {
      Facility facility = facilities[index];

      totalExistingLimit += facility.existingLimits ?? 0;
      totalProposedLimit += facility.proposedLimits ?? 0;
      totalOutstandingAmount += facility.outstanding ?? 0;

      tableRows.add([
        Text("${facility.sNo}"),
        AddSublimitButton(
            viewModel: viewModel //  remove statically passing viewModel
            ),
        TextButton(
          onPressed: () {
            router.go(Routes.createFacility,
                extra: Facility(
                    facilityDescription: Reference(
                        name:
                            "test"))); //  after API integration pass the facility from this class instead of new object
          },
          child: Text(
            facility.limitNumber.toString(),
            style: const TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: AppColors.darkBlue,
            ),
          ),
        ),
        Text(facility.facilityDetails ?? ""),
        SustanabilityClassificationField(
          viewModel: viewModel,
          sustanabilityClassification:
              facility.sustainabilityClassification ?? [],
          facility: facility,
        ),
        ExistingLimits(
          viewModel: viewModel,
          customer: customer,
          facility: facility,
        ),
        ProposedLimits(
          viewModel: viewModel,
          customer: customer,
          facility: facility,
        ),
        OutstandingAmount(
          customer: customer,
          facility: facility,
        ),
        TenorDays(
          facility: facility,
          customer: customer,
        ),
        ApplicablePricing(
          facility: facility,
          customer: customer,
        ),
        Margin(
          customer: customer,
          facility: facility,
        ),
        Center(
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              viewModel.openLinkedFacilityDialog(context);
            },
            icon: const Icon(
              Icons.link,
              color: AppColors.buttonBackground,
            ),
          ),
        ),
        DeleteFacilityButton(
          serialNumber: facility.sNo,
          typeID: facilityGroup?.typeId,
          viewModel: viewModel,
        ),
      ]);
    }

    tableRows.add([
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      Text("facilities.facilitySummary.total".tr()),
      Text((facilityGroup?.total).toString()),
      Text(totalExistingLimit.toString()),
      Text(totalProposedLimit.toString()),
      Text(totalOutstandingAmount.toString()),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
    ]);

    return tableRows;
  }
}
