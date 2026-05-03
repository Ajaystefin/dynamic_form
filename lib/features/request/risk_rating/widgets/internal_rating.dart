import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/risk_rating/model.dart";
import "package:wcas_frontend/features/request/risk_rating/widgets/refresh_button.dart";
import "package:wcas_frontend/features/request/risk_rating/widgets/search_entity.dart";
import "package:wcas_frontend/models/request/risk_rating/internal_rating.dart";

class InternalRatingTable extends StatelessWidget {
  const InternalRatingTable(
    this.viewModel, {
    super.key,
  });
  final RiskRatingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool deleteColumn = viewModel.riskRating.internalRatings
        .any((item) => item.isDeletable == true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomSectionHeader(title: "riskRating.internalRating".tr()),
            if (!viewModel.isViewOnly) RefreshButton(viewModel: viewModel),
          ],
        ),
        const Gap(),
        DecoratedBox(
          decoration: BoxDecoration(
            border: viewModel.isCreditLensAvailable
                ? null
                : Border.all(color: AppColors.failure),
          ),
          child: CustomRawTable(
            key: UniqueKey(),
            rowsPerPage: viewModel.tableRow,
            initialPage: viewModel.initialInternalRatingPage,
            onPageChange: (page) {
              viewModel.initialInternalRatingPage = page;
            },
            showPagination: true,
            columnHeaderHeight: 60,
            stackedHeaders: [
              StackedHeader(
                startIndex: 4,
                endIndex: 5,
                width: 140.w,
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
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [Text("riskRating.bgNote".tr())],
        ),
        // if (!viewModel.isProposedbyCreditEditables())
        if (!viewModel.isViewOnly && viewModel.canEdit)
          AddItemButton(
            onTap: () async => viewModel.addInternalTableRow(),
            isLeftSided: true,
            child: Text("riskRating.addInternalRating".tr()),
          ),
        if (!viewModel.isCreditLensAvailable)
          Text(
            "riskRating.creditLensErrorMsg".tr(),
            style: const TextStyle(
              color: AppColors.failure,
            ),
          ),
        const Gap(),
        LabelWidget(
          label: "groupInformation.facilitiesWithCBD.comments".tr(),
          isRequired: !viewModel.isViewOnly,
          child: CustomTextArea(
            controller: viewModel.internalRatingTextController,
            initialValue: viewModel.riskRating.comments,
            semanticLabel: "groupInformation.facilitiesWithCBD.comments".tr(),
            maxLines: 10,
            alphanumericOnly: true,
            minLines: 4,
            filled: viewModel.isViewOnly,
            readOnly: viewModel.isViewOnly,
            validator: CustomValidator.requiredField,
            maxLength: 5000,
            onSaved: (String? value) {
              viewModel.riskRating.comments = value;
            },
          ),
        ),
        const Gap(),
        if (viewModel.rimWithNoEntity.isNotEmpty &&
            viewModel.isCreditLensAvailable) ...[
          Text(
            "riskRating.warning".tr(),
            style: AppStyle.boldLabel,
          ),
          const Gap(),
          ...List.generate(
            viewModel.rimWithNoEntity.length,
            (i) => _multiRim(rimNo: viewModel.rimWithNoEntity[i]!),
          ),
        ],
      ],
    );
  }

  Widget _multiRim({required int rimNo}) {
    return CustomAccordion(
      title: "$rimNo",
      children: [
        SearchEntity(
          viewModel,
          rimNo: rimNo,
        ),
      ],
    );
  }

  List<TableColumn> _columns(bool deleteColumn) {
    return [
      TableColumn(width: 70.w, label: Text("riskRating.customerRim".tr())),
      TableColumn(width: 60.w, label: Text("riskRating.customerName".tr())),
      TableColumn(width: 80.w, label: Text("riskRating.entityId".tr())),
      TableColumn(width: 70.w, label: Text("riskRating.b/g".tr())),
      TableColumn(
        width: 50.w,
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
      if (deleteColumn) TableColumn(forcedWidth: 40.w, label: const SizedBox()),
    ];
  }

  List<List<Widget>> _rows(bool deleteColumn) {
    final List<InternalRating> internalRatings = viewModel
        .riskRating.internalRatings
        .where((rating) => rating.isDeleted != true)
        .toList();

    return List.generate(internalRatings.length, (index) {
      final InternalRating internalRating = internalRatings[index];
      // final isFromWcas = internalRating.fromWcasDB ?? false;
      final bool isBasisOfCrrEditable =
          internalRating.internalRatingType == InternalRatingtype.override ||
              internalRating.internalRatingType == InternalRatingtype.cascade;

      final String basisofCrrPrefix =
          internalRating.internalRatingType == InternalRatingtype.override
              ? "riskRating.override".tr()
              : internalRating.internalRatingType == InternalRatingtype.cascade
                  ? "riskRating.cascase".tr()
                  : "";

      final String? basisOfCrr =
          internalRating.existingBasisOfCrr?.replaceFirst(basisofCrrPrefix, "");

      final String customerRim =
          "${internalRating.customerRimNo ?? "riskRating.empty".tr()}";
      final String customerName =
          "${internalRating.customerName ?? ""} ${internalRating.ifrs ?? ""}";

      final String? entityIdValue = internalRating.entityId != null
          ? "${internalRating.entityId}"
          : (internalRating.entities?.isEmpty ?? true)
              ? null
              : "${internalRating.entities?.first ?? "riskRating.empty".tr()}";

      final bool hasEntityId = internalRating.entityId != null &&
          internalRating.entityId.toString().isNotEmpty;

      final bool isEditable = hasEntityId
          ? true
          : (internalRating.rimWithNoEntity == true)
              ? false
              : (!viewModel.isCreditLensAvailable ||
                  internalRating.fromWcasDB == false);

      final String? detailOverride = viewModel.isCreditLensAvailable
          ? internalRating.detailsOverride ??
              internalRating.overrideComment ??
              valueOrNA(internalRating.detailsOverride)
          : "";

      return [
        //Rim no
        _customTextField(
          semanticLabel: "riskRating.customerRim".tr(),
          initialValue: customerRim,
          isEditable: internalRating.isDeletable ?? false,
          maxLength: 15,
          isRequired: true,
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
        // Entity ID
        (internalRating.entities ?? []).length > 1
            ? CustomDropdown<int?>(
                isEnabled:
                    !viewModel.isCreditLensAvailable, // new condition added
                key: UniqueKey(),
                semanticLabel: "riskRating.entityId".tr(),
                showClearIcon: false,
                items: internalRating.entities,
                validationMessage: "Required Field",
                selectedItems: [internalRating.entityId],
                onSelected: (value) async => viewModel.onSelectedEntities(
                  index: index,
                  rim: internalRating.customerRimNo,
                  entity: value[0],
                ),
              )
            : _customTextField(
                semanticLabel: "riskRating.entityId".tr(),
                isEditable: isEditable
                    ? true
                    : internalRating.rimWithNoEntity == true
                        ? false
                        : (!viewModel.isCreditLensAvailable ||
                            (internalRating.fromWcasDB == false)),
                // || internalRating.entityId == null,
                maxLength: 15,
                onSaved: (String? value) {
                  internalRating.entityId = int.tryParse(value ?? "");
                },
                onChanged: (String? value) {
                  internalRating.entityId = int.tryParse(value ?? "");
                },
                onSubmitted: (String entities) async =>
                    viewModel.onSelectedEntities(
                  index: index,
                  rim: internalRating.customerRimNo,
                  entity: int.tryParse(entities),
                ),
                initialValue: entityIdValue == "0" ? null : entityIdValue,
              ),
        // B/G
        CustomDropdown(
          isEnabled: !viewModel.isCreditLensAvailable ||
              Utils.checkRoles([
                UserRole.relationshipOfficer,
                UserRole.relationshipManager,
              ]), // new condition added
          items: [
            "riskRating.b".tr(),
            "riskRating.g".tr(),
            "riskRating.na".tr(),
          ],
          validationMessage: "common.validation.requiredField".tr(),
          showClearIcon: false,
          onSelected: (List<String> selectedValue) =>
              internalRating.borrowerGuarantor = selectedValue[0],
          selectedItems: [internalRating.borrowerGuarantor],
          dropdownBuilder: (context, item) => dropdownBuilderWidget(text: item),
          itemBuilder: (context, item, isDisabled, isSelected) =>
              dropdownItemBuildWidget(item, isSelected: isSelected),
        ),
        // Ex. CRR
        _customTextField(
          initialValue: "${internalRating.crr ?? ""}",
          semanticLabel: "riskRating.crr".tr(),
          maxLength: 18,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          isEditable: !viewModel.isCreditLensAvailable,
          onSaved: (String? existingCrr) {
            internalRating.crr = int.tryParse(existingCrr ?? "");
          },
          onChanged: (String existingCrr) {
            internalRating.crr = int.tryParse(existingCrr);
            // viewModel.emitInternalRating();
          },
        ),

        /// Basis crr
        _customTextField(
          initialValue: internalRating.existingBasisOfCrr,
          maxLength: 200,
          prefixIcon: internalRating.internalRatingType ==
                      InternalRatingtype.override ||
                  internalRating.internalRatingType ==
                      InternalRatingtype.cascade
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        basisofCrrPrefix,
                        style: const TextStyle(color: AppColors.black),
                      ),
                    ),
                  ],
                )
              : null,
          semanticLabel: "riskRating.basisCrr".tr(),
          isEditable: !viewModel.isCreditLensAvailable || isBasisOfCrrEditable,
          onSaved: (String? basisOfCrrValue) {
            internalRating.existingBasisOfCrr = basisOfCrrValue;
          },
          tooltip: "$basisofCrrPrefix ${basisOfCrr ?? ""}",
          onChanged: (String basisOfCrrValue) {
            internalRating.existingBasisOfCrr = basisOfCrrValue;
            // viewModel.emitInternalRating();
          },
        ),
        //Model OPT
        _customTextField(
          semanticLabel: "riskRating.modelOpt".tr(),
          maxLength: 200,
          isEditable: !viewModel.isCreditLensAvailable,
          onSaved: (String? propModelOpt) {
            internalRating.proposedModel = propModelOpt;
          },
          tooltip: internalRating.proposedModel ?? "riskRating.empty".tr(),
          initialValue: internalRating.proposedModel ?? "riskRating.empty".tr(),
          onChanged: (String? propModelOpt) {
            internalRating.proposedModel = propModelOpt;
            // viewModel.emitInternalRating();
          },
        ),

        //CRR Proposed
        _customTextField(
          semanticLabel: "riskRating.crrProposed".tr(),
          isEditable: !viewModel.isCreditLensAvailable,
          onSaved: (String? propCrr) {
            internalRating.proposedCRR = int.tryParse(propCrr ?? "");
          },
          maxLength: 18,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (String propCrr) {
            internalRating.proposedCRR = int.tryParse(propCrr);
            // viewModel.emitInternalRating();
          },
          initialValue:
              "${internalRating.proposedCRR ?? "riskRating.empty".tr()}",
        ),

        //Basis of CRR Proposed
        _customTextField(
          semanticLabel: "riskRating.basisCrrProposed".tr(),
          isEditable: !viewModel.isCreditLensAvailable,
          onSaved: (String? propBasisCrr) {
            internalRating.proposedBasisOfCrr = propBasisCrr;
            if (internalRating.isOverrideCRR == true) {
              internalRating.overrideReason = propBasisCrr;
            } else if (internalRating.isCascade == true) {
              internalRating.cascadeReason = propBasisCrr;
            } else {
              internalRating.proposedRatingSrc = propBasisCrr;
            }
          },
          onChanged: (String propBasisCrr) {
            internalRating.proposedBasisOfCrr = propBasisCrr;
            if (internalRating.isOverrideCRR == true) {
              internalRating.overrideReason = propBasisCrr;
            } else if (internalRating.isCascade == true) {
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
          isEditable: !viewModel.isCreditLensAvailable,
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
          initialValue: detailOverride,
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
          isRequired: viewModel.isProposedFieldEditable,
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
          isPBC: true,
          isEditable: viewModel.isProposedbyCreditEditables(),
        ),
        //Delete Column
        if (viewModel.riskRating.internalRatings
            .any((item) => item.isDeletable == true))
          internalRating.isDeletable == true && viewModel.canEdit
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
    bool isRequired = true,
    bool isEditable = false,
    bool isPBC = false,
    Widget? prefixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final Widget child = CustomTextField(
      showToolTip: true,
      prefixIcon: prefixIcon,
      inputFormatters: inputFormatters,
      semanticLabel: semanticLabel,
      showTooltipIRL: false,
      initialValue: initialValue,
      maxLength: maxLength,
      onSaved: onSaved,
      filled: !isEditable,
      readOnly: !isEditable,
      onChanged: onChanged,
      validator: isRequired ? CustomValidator.requiredField : null,
      onSubmitted: onSubmitted ?? onSaved,
    );
    return Center(
      key: UniqueKey(),
      child: CustomTooltip(
        message: tooltip ?? initialValue ?? "",
        child: isPBC
            ? child
            : viewModel.isViewOnly
                ? CustomTextField(
                    filled: true,
                    readOnly: true,
                    initialValue: initialValue,
                  )
                : child,
      ),
    );
  }

  String? valueOrNA(String? value) =>
      (value?.trim().isNotEmpty ?? false) ? value : "NA";
}
