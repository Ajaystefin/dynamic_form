import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/section_background.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/group_information/facilities_with_cbd/model.dart';
import 'package:wcas_frontend/models/request/group_information/facilities_with_cbd.dart';

import 'package:wcas_frontend/models/request/request.dart';

class BodyWidget extends StatelessWidget {
  final FacilitiesWithCbdViewModel viewModel;
  final bool isMobile;
  BodyWidget({super.key, required this.viewModel, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Form(
          key: viewModel.formKey,
          child: SectionBackground(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSectionHeader(
                    title: "groupInformation.facilitiesWithCBD.title".tr()),
                const Gap(),
                BoxLayout(
                  child: TopSectionDetails(
                    request: Globals.request ?? Request(),
                  ),
                ),
                BoxLayout(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomSelectableText(
                              text:
                                  "groupInformation.facilitiesWithCBD.aed".tr(),
                              style: AppStyle.tableSuffixHeaderStyle,
                              semanticsLabel: "groupInformation.facilitiesWithCBD.aed".tr(),
                            ),
                          ],
                        ),
                        const Gap(),
                        CustomRawTable(
                          key: UniqueKey(),
                          columns: getColumns(),
                          stackedHeaders: stackedHeader,
                          rows: getTableRows(viewModel.groupFacilitiesWithCDB),
                        ),
                        const Gap(size: GapSize.large),
                        LabelWidget(
                          label: "groupInformation.facilitiesWithCBD.comments"
                              .tr(),
                              
                          child: CustomTextArea(
                            semanticLabel: "groupInformation.facilitiesWithCBD.comments"
                              .tr(),
                            initialValue: viewModel.comment?.comment,
                            maxLength: 5000,
                            onSaved: (String? value) {
                              viewModel.comment?.comment = value;
                            },
                          ),
                        ),
                        const Gap(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomButton(
                                label:
                                    'groupInformation.facilitiesWithCBD.saveContinue'
                                        .tr(),
                                        semanticLabel:  'groupInformation.facilitiesWithCBD.saveContinue'
                                        .tr(),
                                onPressed: () async {
                                  await viewModel.onSaveButtonPressed();
                                }),
                          ],
                        )
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final List<StackedHeader> stackedHeader = [
    StackedHeader(
        startIndex: 4,
        endIndex: 5,
        width: 180.w,
        widget: Text("groupInformation.facilitiesWithCBD.limits".tr())),
    StackedHeader(
        startIndex: 6,
        endIndex: 7,
        width: 180.w,
        widget: Text("groupInformation.facilitiesWithCBD.outstanding".tr())),
  ];

  List<TableColumn> getColumns() {
    return [
      TableColumn(
          width: 110.w,
          label: Text("groupInformation.facilitiesWithCBD.customerName".tr())),
      TableColumn(
          width: 100.w,
          label: Text("groupInformation.facilitiesWithCBD.customerRIM".tr())),
      TableColumn(
          width: 80.w,
          label: Text("groupInformation.facilitiesWithCBD.CRR".tr())),
      TableColumn(
          width: 120.w,
          label: Text(
              "groupInformation.facilitiesWithCBD.cbdCbrbClassification".tr())),
      TableColumn(
          width: 90.w,
          label: Text("groupInformation.facilitiesWithCBD.presentLimit".tr()),
          isStacked: true),
      TableColumn(
          width: 90.w,
          label: Text("groupInformation.facilitiesWithCBD.proposedLimit".tr()),
          isStacked: true),
      TableColumn(
          width: 90.w,
          label:
              Text("groupInformation.facilitiesWithCBD.totalOutstanding".tr()),
          isStacked: true),
      TableColumn(
          width: 90.w,
          label: Text("groupInformation.facilitiesWithCBD.pastDues".tr()),
          isStacked: true),
    ];
  }

  List<List<Widget>> getTableRows(List<FacilitiesWithCbd> groupFacilities) {
    List<List<Widget>> rows = [];

    for (FacilitiesWithCbd item in groupFacilities) {
      int fundedPresent = item.fundedCurrentLimit ?? 0;
      int proposedLimit = item.fundedProposedLimit ?? 0;
      int outstanding =
          (item.fundedOutstanding ?? 0) + (item.nonFundedOutstanding ?? 0);
      int pastDues = (item.fundedPastDues ?? 0) + (item.nonFundedPastDues ?? 0);

      rows.add([
        Text(item.customerName ?? ""),
        Text(item.customerRim.toString()),
        Text(item.crr.toString()),
        Text(item.cbrbClassification ?? ""),
        Text(
          fundedPresent.toString(),
          style: const TextStyle(color: AppColors.highlightedTextColor),
        ),
        Text(
          proposedLimit.toString(),
          style: const TextStyle(color: AppColors.highlightedTextColor),
        ),
        Text(
          outstanding.toString(),
          style: const TextStyle(color: AppColors.highlightedTextColor),
        ),
        Text(
          pastDues.toString(),
          style: const TextStyle(color: AppColors.highlightedTextColor),
        ),
      ]);
    }

    return rows;
  }
}
