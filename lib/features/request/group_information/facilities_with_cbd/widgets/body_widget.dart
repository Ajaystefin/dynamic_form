import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/section_background.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_cbd/model.dart";
import "package:wcas_frontend/models/request/group_information/facilities_with_cbd.dart";
import "package:wcas_frontend/models/request/request.dart";

/// Body widget for the Facilities with CBD section.
class BodyWidget extends StatelessWidget {
  /// Creates a [BodyWidget].
  BodyWidget({required this.viewModel, super.key, this.isMobile = false});

  /// View model used by the widget.
  final FacilitiesWithCbdViewModel viewModel;

  /// Indicates whether the widget is displayed on a mobile device.
  final bool isMobile;

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
                  title: "groupInformation.facilitiesWithCBD.title".tr(),
                ),
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
                            text: "groupInformation.facilitiesWithCBD.aed".tr(),
                            style: AppStyle.tableSuffixHeaderStyle,
                            semanticsLabel:
                                "groupInformation.facilitiesWithCBD.aed".tr(),
                          ),
                        ],
                      ),
                      const Gap(),
                      CustomRawTable(
                        rowsPerPage: 10,
                        key: UniqueKey(),
                        columns: getColumns(),
                        stackedHeaders: stackedHeader,
                        rows: getTableRows(viewModel.groupFacilitiesWithCDB),
                      ),
                      const Gap(size: GapSize.large),
                      LabelWidget(
                        label:
                            "groupInformation.facilitiesWithCBD.comments".tr(),
                        child: CustomTextArea(
                          readOnly: !viewModel.canEdit,
                          semanticLabel:
                              "groupInformation.facilitiesWithCBD.comments"
                                  .tr(),
                          controller: viewModel.commentController,
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
                          if (viewModel.canEdit || viewModel.isCancellationApp)
                            CustomButton(
                              label: "groupInformation."
                                      "facilitiesWithCBD.saveContinue"
                                  .tr(),
                              semanticLabel: "groupInformation."
                                      "facilitiesWithCBD.saveContinue"
                                  .tr(),
                              onPressed: () async {
                                await viewModel.onSaveComment();
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Stacked headers displayed in the facilities table.
  final List<StackedHeader> stackedHeader = [
    StackedHeader(
      startIndex: 4,
      endIndex: 5,
      width: 180.w,
      widget: Text("groupInformation.facilitiesWithCBD.limits".tr()),
    ),
    StackedHeader(
      startIndex: 6,
      endIndex: 7,
      width: 180.w,
      widget: Text("groupInformation.facilitiesWithCBD.outstanding".tr()),
    ),
  ];

  /// Returns the columns displayed in the facilities table.
  List<TableColumn> getColumns() {
    return [
      TableColumn(
        width: 110.w,
        label: Text("groupInformation.facilitiesWithCBD.customerName".tr()),
      ),
      TableColumn(
        width: 100.w,
        label: Text("groupInformation.facilitiesWithCBD.customerRIM".tr()),
      ),
      TableColumn(
        width: 80.w,
        label: Text("groupInformation.facilitiesWithCBD.CRR".tr()),
      ),
      TableColumn(
        width: 120.w,
        label: Text(
          "groupInformation.facilitiesWithCBD.cbdCbrbClassification".tr(),
        ),
      ),
      TableColumn(
        width: 90.w,
        label: Text("groupInformation.facilitiesWithCBD.presentLimit".tr()),
        isStacked: true,
      ),
      TableColumn(
        width: 90.w,
        label: Text("groupInformation.facilitiesWithCBD.proposedLimit".tr()),
        isStacked: true,
      ),
      TableColumn(
        width: 90.w,
        label: Text("groupInformation.facilitiesWithCBD.totalOutstanding".tr()),
        isStacked: true,
      ),
      TableColumn(
        width: 90.w,
        label: Text("groupInformation.facilitiesWithCBD.pastDues".tr()),
        isStacked: true,
      ),
    ];
  }

  /// Returns table rows for the provided [groupFacilities].
  List<List<Widget>> getTableRows(List<FacilitiesWithCbd> groupFacilities) {
    final List<List<Widget>> rows = [];

    for (final FacilitiesWithCbd item in groupFacilities) {
      double fundedPresent;
      double proposedLimit;

      switch (item.category) {
        case ServerConstants.indi:
          fundedPresent = (item.fundedCurrentLimit ?? 0) +
              (item.nonFundedCurrentLimit ?? 0);
          proposedLimit = (item.fundedProposedLimit ?? 0) +
              (item.nonFundedProposedLimit ?? 0);

        case ServerConstants.funded:
          fundedPresent = item.fundedCurrentLimit ?? 0;
          proposedLimit = item.fundedProposedLimit ?? 0;

        case ServerConstants.nonFunded:
          fundedPresent = item.nonFundedCurrentLimit ?? 0;
          proposedLimit = item.nonFundedProposedLimit ?? 0;

        default:
          fundedPresent = (item.fundedCurrentLimit ?? 0) +
              (item.nonFundedCurrentLimit ?? 0);
          proposedLimit = (item.fundedProposedLimit ?? 0) +
              (item.nonFundedProposedLimit ?? 0);
      }

      final double outstanding =
          (item.fundedOutstanding ?? 0) + (item.nonFundedOutstanding ?? 0);
      final double pastDues =
          (item.fundedPastDues ?? 0) + (item.nonFundedPastDues ?? 0);

      rows.add([
        Text(item.customerName ?? ""),
        Text(item.customerRim.toString()),
        Text(
          (item.crr == 0 ||
                  item.crr == null ||
                  item.crr.toString() == "0" ||
                  item.crr.toString() == "")
              ? ""
              : item.crr.toString(),
        ),
        Text(item.cbrbClassification ?? ""),
        Text(
          fundedPresent.toString(),
          style: const TextStyle(color: AppColors.darkBlue),
        ),
        Text(
          proposedLimit.toString(),
          style: const TextStyle(color: AppColors.darkBlue),
        ),
        Text(
          outstanding.toString(),
          style: const TextStyle(color: AppColors.darkBlue),
        ),
        Text(
          pastDues.toString(),
          style: const TextStyle(color: AppColors.darkBlue),
        ),
      ]);
    }

    return rows;
  }
}
