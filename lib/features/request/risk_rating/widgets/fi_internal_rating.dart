import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/risk_rating/model.dart";
import "package:wcas_frontend/models/request/risk_rating/internal_rating.dart";

/// FI Internal Rating
///
/// Displays and manages internal ratings for Financial Institution customers.
class FiInternalRating extends StatelessWidget {
  /// Creates an FI internal rating widget.
  const FiInternalRating(this.viewModel, {super.key});

  /// Risk rating view model.
  final RiskRatingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool deleteColumn = viewModel.riskRating.internalRatings
            .any((item) => item.isDeletable ?? false) &&
        viewModel.canEdit &&
        viewModel.isDeletable;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomSectionHeader(title: "riskRating.internalRating".tr()),
          ],
        ),
        const Gap(),
        CustomRawTable(
          key: UniqueKey(),
          rowsPerPage: viewModel.tableRow,
          initialPage: viewModel.initialInternalRatingPage,
          onPageChange: (page) {
            viewModel.initialInternalRatingPage = page;
          },
          columnHeaderHeight: 60,
          stackedHeaders: [
            StackedHeader(
              startIndex: 4,
              endIndex: 5,
              width: 160.w,
              widget: Center(
                child: Text("riskRating.existing".tr()),
              ),
            ),
            StackedHeader(
              startIndex: 6,
              endIndex: 8,
              width: 90.w + 55.w + 70.w,
              widget: Center(
                child: Text("riskRating.proposed".tr()),
              ),
            ),
            StackedHeader(
              startIndex: 9,
              endIndex: deleteColumn ? 11 : 10,
              width: deleteColumn ? 170.w : 130.w,
              widget: const SizedBox(),
            ),
          ],
          columns: _columns(deleteColumn),
          rows: _rows(deleteColumn),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [Text("riskRating.bgNote".tr())],
        ),
        if (!viewModel.isViewOnly && viewModel.canEdit)
          AddItemButton(
            onTap: () async => viewModel.addInternalTableRow(),
            isLeftSided: true,
            child: Text("riskRating.addInternalRating".tr()),
          ),
        const Gap(),
        LabelWidget(
          label: "groupInformation.facilitiesWithCBD.comments".tr(),
          child: UnifiedTextEditor(
            scrollController: viewModel.internalRatingScrollController,
            characterLimit: 5000,
            height: 300,
            editorId: "internalRatingEditor",
            initialText: viewModel.riskRating.comments,
            controller: viewModel.internalRatingControler,
          ),
        ),
      ],
    );
  }

  List<TableColumn> _columns(bool deleteColumn) {
    return [
      TableColumn(width: 70.w, label: Text("riskRating.customerRim".tr())),
      TableColumn(width: 60.w, label: Text("riskRating.customerName".tr())),
      TableColumn(width: 80.w, label: const Text("2nd Best Rating")),
      TableColumn(width: 70.w, label: Text("riskRating.b/g".tr())),
      TableColumn(
        width: 70.w,
        label: Text("riskRating.crr".tr()),
        isStacked: true,
      ),
      TableColumn(
        width: 90.w,
        label: Text("riskRating.basisCrr".tr()),
        isStacked: true,
      ),
      TableColumn(
        width: 90.w,
        label: Text("riskRating.modelOpt".tr()),
        isStacked: true,
      ),
      TableColumn(
        width: 55.w,
        label: Text("riskRating.crrProposed".tr()),
        isStacked: true,
      ),
      TableColumn(
        width: 70.w,
        label: Text("riskRating.basisCrrProposed".tr()),
        isStacked: true,
      ),
      TableColumn(
        width: 70.w,
        isStacked: true,
        label: Text("riskRating.detailsOverride".tr()),
      ),
      TableColumn(
        width: 60.w,
        isStacked: true,
        label: Text("riskRating.proposedByCredit".tr()),
      ),
      TableColumn(forcedWidth: 40.w, label: const SizedBox()),
    ];
  }

  List<List<Widget>> _rows(bool deleteColumn) {
    final List<InternalRating> internalRatings =
        viewModel.riskRating.internalRatings;
    return List.generate(internalRatings.length, (index) {
      final InternalRating internalRating = internalRatings[index];

      final String customerRim =
          "${internalRating.customerRimNo ?? "riskRating.empty".tr()}";
      final String customerName =
          "${internalRating.customerName ?? ""} ${internalRating.ifrs ?? ""}";

      return [
        //Rim no
        _customTextField(
          semanticLabel: "riskRating.customerRim".tr(),
          initialValue: customerRim,
          isEditable: internalRating.isDeletable ?? false,
          maxLength: 15,
          onSubmitted: (String customerRimNo) async {
            internalRating.customerRimNo = int.tryParse(customerRimNo);
            await viewModel.searchByRim(index, customerRimNo);
          },
          onSaved: (String? customerRimNo) {
            internalRating.customerRimNo = int.tryParse(customerRimNo ?? "");
          },
        ),
        // cust name
        CustomTooltip(
          message: customerName,
          child: Text(customerName),
        ),
        // 2nd best rating
        _customTextField(
          semanticLabel: "2nd Best Rating",
          isEditable: true,
          maxLength: 50,
          initialValue: internalRating.secondBestRating,
          onChanged: (String rating) {
            internalRating.secondBestRating = rating;
          },
          onSaved: (String? rating) {
            internalRating.secondBestRating = rating;
          },
        ),

        // B/G
        CustomDropdown(
          items: [
            "riskRating.b".tr(),
            "riskRating.g".tr(),
            "riskRating.na".tr(),
          ],
          showClearIcon: false,
          onSelected: (List<String> selectedValue) =>
              internalRating.borrowerGuarantor = selectedValue[0],
          selectedItems: [internalRating.borrowerGuarantor],
          dropdownBuilder: (context, item) => dropdownBuilderWidget(text: item),
          itemBuilder: (context, item, {isDisabled, isSelected}) =>
              dropdownItemBuildWidget(item, isSelected: isSelected ?? false),
        ),
        // Ex. CRR
        CustomDropdown<int>(
          items: viewModel.fiCRR,
          showClearIcon: false,
          // validationMessage: "common.validation.emptyField".tr(),
          onSelected: (List<int> selectedValue) =>
              internalRating.crr = selectedValue[0],
          selectedItems: [internalRating.crr],
          dropdownBuilder: (context, item) =>
              dropdownBuilderWidget(text: "${item ?? ""}"),
          itemBuilder: (context, item, {isDisabled, isSelected}) =>
              dropdownItemBuildWidget("$item", isSelected: isSelected ?? false),
        ),

        /// Basis crr
        _customTextField(
          initialValue: internalRating.existingBasisOfCrr,
          maxLength: 200,
          semanticLabel: "riskRating.basisCrr".tr(),
          isEditable: true,
          onSaved: (String? basisOfCrrValue) {
            internalRating.existingBasisOfCrr = basisOfCrrValue;
          },
          onChanged: (String basisOfCrrValue) {
            internalRating.existingBasisOfCrr = basisOfCrrValue;
          },
        ),
        //Model OPT
        _customTextField(
          semanticLabel: "riskRating.modelOpt".tr(),
          maxLength: 200,
          isEditable: true,
          onSaved: (String? propModelOpt) {
            internalRating.proposedModel = propModelOpt;
          },
          tooltip: internalRating.proposedModel ?? "riskRating.empty".tr(),
          initialValue: internalRating.proposedModel ?? "riskRating.empty".tr(),
          onChanged: (String? propModelOpt) {
            internalRating.proposedModel = propModelOpt;
          },
        ),

        //CRR Proposed
        CustomDropdown<int>(
          items: viewModel.fiCRR,
          showClearIcon: false,
          // validationMessage: "common.validation.emptyField".tr(),
          onSelected: (List<int> selectedValue) =>
              internalRating.proposedCRR = selectedValue[0],
          selectedItems: [internalRating.proposedCRR],
          dropdownBuilder: (context, item) =>
              dropdownBuilderWidget(text: "${item ?? ""}"),
          itemBuilder: (context, item, {isDisabled, isSelected}) =>
              dropdownItemBuildWidget("$item", isSelected: isSelected ?? false),
        ),

        //Basis of CRR Proposed
        _customTextField(
          semanticLabel: "riskRating.basisCrrProposed".tr(),
          isEditable: true,
          onSaved: (String? propBasisCrr) {
            internalRating.proposedBasisOfCrr = propBasisCrr;
            if (internalRating.isOverrideCRR ?? false) {
              internalRating.overrideReason = propBasisCrr;
            } else if (internalRating.isCascade ?? false) {
              internalRating.cascadeReason = propBasisCrr;
            } else {
              internalRating.proposedRatingSrc = propBasisCrr;
            }
          },
          onChanged: (String propBasisCrr) {
            internalRating.proposedBasisOfCrr = propBasisCrr;
            if (internalRating.isOverrideCRR ?? false) {
              internalRating.overrideReason = propBasisCrr;
            } else if (internalRating.isCascade ?? false) {
              internalRating.cascadeReason = propBasisCrr;
            } else {
              internalRating.proposedRatingSrc = propBasisCrr;
            }
            // viewModel.emitInternalRating();
          },
          maxLength: 200,
          initialValue:
              internalRating.proposedBasisOfCrr ?? "riskRating.empty".tr(),
        ),

        // Details Overriden
        _customTextField(
          semanticLabel: "riskRating.detailsOverride".tr(),
          maxLength: 200,
          isEditable: true,
          onSaved: (String? detailsOverride) {
            internalRating.detailsOverride = detailsOverride;
            if (internalRating.isOverrideCRR ?? false) {
              internalRating.overrideComment = detailsOverride;
            } else if (internalRating.isCascade ?? false) {
              internalRating.cascadeNote = detailsOverride;
            }
          },
          onChanged: (String? detailsOverride) {
            internalRating.detailsOverride = detailsOverride;
            if (internalRating.isOverrideCRR ?? false) {
              internalRating.overrideComment = detailsOverride;
            } else if (internalRating.isCascade ?? false) {
              internalRating.cascadeNote = detailsOverride;
            }
          },
          initialValue: !viewModel.isCreditLensAvailable
              ? null
              : internalRating.detailsOverride ?? "riskRating.empty".tr(),
          onSubmitted: (String detailsOverride) {
            internalRating.detailsOverride = detailsOverride;
            if (internalRating.isOverrideCRR ?? false) {
              internalRating.overrideComment = detailsOverride;
            } else if (internalRating.isCascade ?? false) {
              internalRating.cascadeNote = detailsOverride;
            }
            // viewModel.emitInternalRating();
          },
        ),

        // proposed by credit
        _customTextField(
          semanticLabel: "riskRating.proposedByCredit".tr(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 10,
          onSaved: (String? proposedByCredit) {
            internalRating.proposedByCredit = proposedByCredit;
          },
          onSubmitted: (String? proposedByCredit) {
            internalRating.proposedByCredit = proposedByCredit;
            // viewModel.emitInternalRating();
          },
          onChanged: (String? proposedByCredit) {
            internalRating.proposedByCredit = proposedByCredit;
            // viewModel.emitInternalRating();
          },
          initialValue: internalRating.proposedByCredit,
          // isPBC: true,
          isEditable: viewModel.isProposedbyCreditEditables(),
        ),
        //Delete Column
        if (viewModel.riskRating.internalRatings
            .any((item) => item.isDeletable ?? false))
          (deleteColumn && (internalRating.isDeletable ?? false))
              ? Center(
                  key: UniqueKey(),
                  child: IconButton(
                    onPressed: () => viewModel.removeInternalTableRow(
                      internalRating.customerRiskRatingId,
                    ),
                    icon: const Icon(Icons.delete),
                  ),
                )
              : const SizedBox(),
      ];
    });
  }

  Widget _customTextField({
    String? semanticLabel,
    String? initialValue,
    String? tooltip,
    int? maxLength,
    dynamic Function(String?)? onSaved,
    dynamic Function(String)? onSubmitted,
    dynamic Function(String)? onChanged,
    bool isRequired = false,
    bool isEditable = false,
    // bool isPBC = false,
    Widget? prefixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Center(
      key: UniqueKey(),
      child: CustomTooltip(
        message: tooltip ?? initialValue ?? "",
        child: CustomTextField(
          prefixIcon: prefixIcon,
          inputFormatters: inputFormatters,
          semanticLabel: semanticLabel,
          initialValue: initialValue,
          maxLength: maxLength,
          onSaved: onSaved,
          filled: !isEditable,
          readOnly: !isEditable,
          onChanged: onChanged,
          validator: isRequired ? CustomValidator.requiredField : null,
          onSubmitted: onSubmitted ?? onSaved,
        ),
      ),
    );
  }
}
