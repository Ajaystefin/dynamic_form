import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/model.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/raroc_info.dart";

class RoracInformation extends StatelessWidget {
  const RoracInformation({required this.viewModel, super.key});
  final RelationshipProfitabilitySummaryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final rarocList =
        viewModel.relationshipProfitabilitySummaryData?.rarocInformation ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomRawTable(
          topStackedHeaders: _topStackedHeaders(),
          stackedHeaders: _stackedHeaders(),
          columns: _tableColumns(),
          autoFitWidth: true,
          columnHeaderHeight: 45.w,
          rows: _tableRows(rarocList),
        ),
        if (rarocList.isEmpty)
          Center(
            child: Text(
              "common.emptyState".tr(),
            ),
          ),
      ],
    );
  }

  List<StackedHeader> _topStackedHeaders() {
    return [
      StackedHeader(
        startIndex: 2,
        endIndex: 3,
        widget: Center(
          child: Text(
            "profitabilityAccountConduct."
                    "relationshipProfitabilitySummary.existing"
                .tr(),
          ),
        ),
        width: 190.w,
      ),
      StackedHeader(
        startIndex: 4,
        endIndex: 5,
        widget: Center(
          child: Text(
            "profitabilityAccountConduct."
                    "relationshipProfitabilitySummary.proposed"
                .tr(),
          ),
        ),
        width: 190.w,
      ),
    ];
  }

  List<StackedHeader> _stackedHeaders() {
    return [
      StackedHeader(
        startIndex: 4,
        endIndex: 4,
        widget: Center(
          child: Text(
            "profitabilityAccountConduct."
                    "relationshipProfitabilitySummary.proposedByCoverage"
                .tr(),
          ),
        ),
        width: 95.w,
      ),
      StackedHeader(
        startIndex: 5,
        endIndex: 5,
        widget: Center(
          child: Text(
            "profitabilityAccountConduct."
                    "relationshipProfitabilitySummary.exAnteRaroc"
                .tr(),
          ),
        ),
        width: 95.w,
      ),
    ];
  }

  List<TableColumn> _tableColumns() {
    return [
      TableColumn(
        label: Text(
          "profitabilityAccountConduct."
                  "relationshipProfitabilitySummary.customerRim"
              .tr(),
        ),
        width: 105.w,
      ),
      TableColumn(
        label: Text(
          "profitabilityAccountConduct."
                  "relationshipProfitabilitySummary.customerName"
              .tr(),
        ),
        width: 95.w,
      ),
      TableColumn(
        label: RichText(
          text: TextSpan(
            text: "profitabilityAccountConduct."
                    "relationshipProfitabilitySummary.realizedRaroc"
                .tr(),
            children: [
              (!viewModel.isFIApplication &&
                      Utils.checkRequestType(RequestType.fullCA))
                  ? const TextSpan(
                      text: "*",
                      style: TextStyle(color: AppColors.failure),
                    )
                  : const TextSpan(text: ""),
            ],
          ),
        ),
        width: 95.w,
      ),
      TableColumn(
        label: Text(
          "profitabilityAccountConduct."
                  "relationshipProfitabilitySummary.lastApprovedRaroc"
              .tr(),
        ),
        width: 95.w,
      ),
      TableColumn(
        label: RichText(
          text: TextSpan(
            text: "profitabilityAccountConduct."
                    "relationshipProfitabilitySummary.rarocpercnt"
                .tr(),
            children: [
              (!viewModel.isFIApplication &&
                      Utils.checkRequestType(RequestType.fullCA))
                  ? const TextSpan(
                      text: "*",
                      style: TextStyle(color: AppColors.failure),
                    )
                  : const TextSpan(text: ""),
            ],
          ),
        ),
        width: 95.w,
        isStacked: true,
      ),
      TableColumn(
        label: RichText(
          text: TextSpan(
            text: "profitabilityAccountConduct."
                    "relationshipProfitabilitySummary.finalRaroc"
                .tr(),
            children: [
              (!viewModel.isFIApplication &&
                      Utils.checkRequestType(RequestType.fullCA))
                  ? const TextSpan(
                      text: "*",
                      style: TextStyle(color: AppColors.failure),
                    )
                  : const TextSpan(text: ""),
            ],
          ),
        ),
        width: 95.w,
        isStacked: true,
      ),
      TableColumn(
        label: Text(
          "profitabilityAccountConduct."
                  "relationshipProfitabilitySummary.comments"
              .tr(),
        ),
        width: 180.w,
      ),
    ];
  }

  List<List<Widget>> _tableRows(List<RarocInformation> rarocList) {
    return rarocList.isNotEmpty
        ? List.generate(rarocList.length, (index) {
            final RarocInformation data = rarocList[index];

            final String realizedRarocStr =
                data.existingRealizedRarocPercent ?? "";
            final String lastApprovedRarocStr =
                data.existingLastApprovedRarocPercent ?? "";
            final String finalRarocStrCoverage =
                data.proposedRarocPercentProposedByCoverage ?? "";
            final String finalRarocStr =
                data.proposedFinalRarocPercentExAnteRaroc ?? "";

            // Controller availability flags (typed)
            final bool hasRealizedCtrl =
                viewModel.realizedRarocControllers != null &&
                    index < viewModel.realizedRarocControllers!.length;

            final bool hasProposedCtrl =
                viewModel.proposedRarocControllers != null &&
                    index < viewModel.proposedRarocControllers!.length;

            final bool hasFinalCtrl =
                viewModel.finalRarocControllers != null &&
                    index < viewModel.finalRarocControllers!.length;

            final bool hasCommentsCtrl =
                viewModel.commentsControllers != null &&
                    index < viewModel.commentsControllers!.length;

            // Build a full 7-cell row (never vary the count)
            return [
              Center(child: Text("${data.customerRim}")),
              Center(child: Text("${data.customerName}")),

              // Existing Realized RAROC (editable if controller present)
              Center(
                child: hasRealizedCtrl && !viewModel.canEditFinalRAROC
                    ? CustomTextField(
                        key: ValueKey("realizedRaroc_$index"),
                        width: 118,
                        inputFormatters: [
                          DecimalInputFormatter(
                            regEx: RegExp(r"^[0-9,]{0,15}(\.\d{0,6})?$"),
                          ),
                        ],
                        validator: !viewModel.isFIApplication
                            ? CustomValidator.requiredField
                            : null,
                        initialValue: realizedRarocStr,
                        controller: viewModel.realizedRarocControllers![index],
                        onChanged: (newValue) => viewModel.updateRoracField(
                          index,
                          newValue,
                          RoracFieldType.realizedRaroc,
                        ),
                      )
                    : Text(
                        realizedRarocStr,
                        style: const TextStyle(color: AppColors.primary),
                      ),
              ),

              // Existing Last Approved RAROC (read-only)
              Center(
                child: Text(
                  lastApprovedRarocStr,
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),

              // Proposed RAROC % (editable if controller present)
              Center(
                child: hasProposedCtrl && !viewModel.canEditFinalRAROC
                    ? CustomTextField(
                        key: ValueKey("proposedRaroc_$index"),
                        width: 118,
                        inputFormatters: [
                          DecimalInputFormatter(
                            regEx: RegExp(r"^[0-9,]{0,15}(\.\d{0,6})?$"),
                          ),
                        ],
                        validator: !viewModel.isFIApplication
                            ? CustomValidator.requiredField
                            : null,
                        initialValue: finalRarocStrCoverage,
                        controller: viewModel.proposedRarocControllers![index],
                        onChanged: (newValue) => viewModel.updateRoracField(
                          index,
                          newValue,
                          RoracFieldType.proposedRaroc,
                        ),
                      )
                    : Text(
                        finalRarocStrCoverage,
                        style: const TextStyle(color: AppColors.primary),
                      ),
              ),

              // Final RAROC (editable if controller present)
              Center(
                child: hasFinalCtrl && viewModel.canEditFinalRAROC
                    ? CustomTextField(
                        key: ValueKey("finalRaroc_$index"),
                        width: 118,
                        inputFormatters: [
                          DecimalInputFormatter(
                            regEx: RegExp(r"^[0-9,]{0,15}(\.\d{0,6})?$"),
                          ),
                        ],
                        validator: !viewModel.isFIApplication ||
                                Utils.checkRole(UserRole.creditAnalyst)
                            ? CustomValidator.requiredField
                            : null,
                        initialValue: finalRarocStr,
                        controller: viewModel.finalRarocControllers![index],
                        onChanged: (newValue) => viewModel.updateRoracField(
                          index,
                          newValue,
                          RoracFieldType.finalRaroc,
                        ),
                      )
                    : Text(
                        finalRarocStr,
                        style: const TextStyle(color: AppColors.primary),
                      ),
              ),

              // Comments (editable if controller present)
              Center(
                child: hasCommentsCtrl && !viewModel.canEditFinalRAROC
                    ? CustomTextField(
                        key: ValueKey("comments_$index"),
                        width: 160.w,
                        initialValue: data.comments ?? "",
                        controller: viewModel.commentsControllers![index],
                        maxLength: 5000,
                        // validator: !viewModel.isFIApplication
                        //     ? CustomValidator.requiredField
                        //     : null,
                        onChanged: (newValue) => viewModel.updateRoracField(
                          index,
                          newValue,
                          RoracFieldType.comments,
                        ),
                      )
                    : Text(data.comments ?? ""),
              ),
            ];
          })
        : [];
  }
}
