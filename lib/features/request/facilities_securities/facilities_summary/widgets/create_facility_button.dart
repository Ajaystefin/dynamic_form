import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/fields/limit_description.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/fields/limit_type.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/state.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/view.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";

class AddFacilitySubLimitBox extends StatelessWidget {
  const AddFacilitySubLimitBox({
    super.key,
    this.facility,
    this.label,
    this.limitGroup,
    this.limitType,
    this.selectedRim,
    this.isMainLimit,
    this.limitNumber,
    this.proposedLimit,
    this.projectName,
    this.totalProposedLimit,
    this.isStanbySublimitValidation,
  });
  final Facility? facility;
  final String? label;
  final int? limitGroup;
  final int? totalProposedLimit;
  final bool? limitType;
  final int? selectedRim;
  final bool? isMainLimit;
  final String? limitNumber;
  final int? proposedLimit;
  final String? projectName;
  final bool? isStanbySublimitValidation;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FacilitiesSummaryViewModel, FacilitiesSummaryState>(
      builder: (context, state) {
        final FacilitiesSummaryViewModel viewModel =
            context.read<FacilitiesSummaryViewModel>();

        // SNAPSHOT arguments to avoid rebuild/race changing them
        final int? groupIdSnapshot = limitGroup; // 11315 or 11317 as passed
        final int? rimSnapshot = selectedRim;
        final Reference? descSnapshot = viewModel.facility.facilityDescription;
        final int? capType = viewModel.limitCapTypeForGroup(groupIdSnapshot);

        return SingleChildScrollView(
          child: Opacity(
            opacity: viewModel.canEdit ? 1 : 0.6,
            child: IgnorePointer(
              ignoring: !viewModel.canEdit,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  LabelWidget(
                    label: "facilities.createFacility.productType".tr(),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CustomRadioButton<Reference>(
                        isEnabled:
                            viewModel.isProductTypeEnabled, // <-- was: false
                        options: viewModel.productTypeOptions,
                        selectedValue: viewModel.selectedProductTypeOption ??
                            (viewModel.isFIFlow
                                ? Reference()
                                : viewModel.productTypeOptions.first),
                        onChanged: (selectedvalue) {
                          viewModel.changeProductTypeOptions(selectedvalue);
                        },
                        itemBuilder: (context, item, isSelected, isEnabled) =>
                            Text(item.name ?? ""),
                        validator: (value) =>
                            CustomValidator.requiredField(value?.name ?? ""),
                        isRequired: true,
                        scrollDirection: Axis.horizontal,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  Row(
                    spacing: 20,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Spacer(),
                      Expanded(
                        flex: 2,
                        child: LimitTypes(
                          viewModel: viewModel,
                        ),
                      ),
                      //limit caps not shown here
                      Expanded(
                        flex: 2,
                        child: LimitDescriptions(
                          viewModel: viewModel,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: CustomButton(
                          label: label ??
                              "facilities.facilitySummary.addFacility".tr(),
                          onPressed: (viewModel.facility.facilityDescription !=
                                  null)
                              ? () async {
                                  final int? gid =
                                      groupIdSnapshot; // 11315 or 11317
                                  final bool isProjGroup =
                                      gid == 11315 || gid == 11317;

                                  // ---------- (robust "Others" option from
                                  // limit description detection by ID)
                                  // ----------
                                  // Stable IDs for the "Others" facility
                                  // description in
                                  // FACILITY_TYPE (15771) and FI_FACILITY_TYPE
                                  // (15705).
                                  final Set<int> othersFacilityTypeIds = {
                                    ServerConstants.facilityTypeOthersID,
                                    // FACILITY_TYPE -> Others
                                    ServerConstants.fiFacilityTypeOthersID,
                                    // FI_FACILITY_TYPE -> Others
                                  };

                                  final int? rimNo = rimSnapshot;
                                  final int? headerProposedNow = (isProjGroup &&
                                          rimNo != null &&
                                          gid != null)
                                      ? viewModel.proposedLimitForGroup(
                                          gid,
                                          rimNo: rimNo,
                                        )
                                      : proposedLimit;

                                  // Look at current API data for this group:
                                  String? headerLimitNo =
                                      viewModel.headerLimitNumberForGroupAtRim(
                                            gid,
                                            rimNo,
                                          ) ??
                                          limitNumber; // from order '0'
                                  bool detailExists = viewModel
                                      .hasDetailRowsForGroupAtRim(gid, rimNo);

                                  final int? selectedDescId = () {
                                    final dynamic raw = viewModel
                                        .facility.facilityDescription?.id;
                                    if (raw is num) return raw.toInt();
                                    return int.tryParse("$raw");
                                  }();
                                  final bool isOthersSelected =
                                      selectedDescId != null &&
                                          othersFacilityTypeIds
                                              .contains(selectedDescId);

                                  if (isOthersSelected) {
                                    await DialogHelper.showCustomDialog(
                                      barrierDismissible: true,
                                      title: "Add new Product",
                                      content: BlocProvider.value(
                                        value: viewModel,
                                        child: OthersLimitDialogView(
                                          limitGroupId: groupIdSnapshot,
                                          selectedDescriptionId: selectedDescId,
                                          rimNo: rimSnapshot,
                                          isMainLimit: isMainLimit,
                                          productTypeValue: viewModel.facility
                                              .selectedProductTypeValue,
                                          isProductTypeEnabled:
                                              viewModel.isProductTypeEnabled,
                                          limitNumber:
                                              // this is for Sublimt case
                                              // , - Controlling parent limit
                                              limitNumber,
                                        ),
                                      ),
                                      context: context,
                                    );
                                    return; // prevent routing in "Others" flow
                                  }

                                  final bool headerRequired = viewModel
                                      .shouldRequireHeaderLimitsFor(gid);

                                  final bool headerMissing = !viewModel
                                      .isProjectHeaderLimitsEnteredForAtRim(
                                    gid,
                                    rimSnapshot,
                                  );
                                  if (isProjGroup &&
                                      headerRequired &&
                                      headerMissing) {
                                    AlertManager().showFailureToast(
                                      "facilities.facilitySummary"
                                              ".proposedMandatory"
                                          .tr(),
                                    );
                                    return;
                                  }

                                  /// Case A: header exists but no detail rows
                                  /// yet -> create FIRST sublimit under header
                                  //// controlling limit from header
                                  if (headerLimitNo != null && !detailExists) {
                                    // limitNumberForArgs = headerLimitNo;

                                    // if header exists and user updated proposed/name/currency -> update header via API
                                    if (isProjGroup &&
                                        rimNo != null &&
                                        viewModel.isProjectHeaderDirtyAtRim(
                                          gid!,
                                          rimNo,
                                        )) {
                                      final int? headerFacilityId = viewModel
                                          .headerFacilityIdForGroupAtRim(
                                        gid,
                                        rimNo,
                                      );

                                      final bool saveHeaderLimitData =
                                          await viewModel
                                              .saveOrUpdateProjectHeader(
                                        rimNo: rimSnapshot,
                                        groupId: groupIdSnapshot,
                                        descSnapshot: descSnapshot,
                                        facilityId: headerFacilityId,
                                        limitCaptype: capType,
                                      );

                                      if (!saveHeaderLimitData) return;
                                    }

                                    /// Case B: no header & no details -> create
                                    /// header ONCE, then pass new limit number
                                  } else if (headerLimitNo == null &&
                                      !detailExists) {
                                    if (isProjGroup) {
                                      final bool saveHeaderLimitData =
                                          await viewModel
                                              .saveOrUpdateProjectHeader(
                                        rimNo: rimSnapshot,
                                        groupId: groupIdSnapshot,
                                        descSnapshot: descSnapshot,
                                        limitCaptype: capType,
                                      );

                                      if (!saveHeaderLimitData) return;

                                      headerLimitNo = viewModel
                                              .headerLimitNumberForGroupAtRim(
                                            gid,
                                            rimNo,
                                          ) ??
                                          viewModel.facility.limitNumber ??
                                          limitNumber;

                                      // optional but safe: detail rows still
                                      // won't exist after creating header
                                      detailExists =
                                          viewModel.hasDetailRowsForGroupAtRim(
                                        gid,
                                        rimNo,
                                      );
                                    } else {}
                                  }

                                  Reference? projectRefForArgs;
                                  if (isProjGroup) {
                                    final String name =
                                        (projectName ?? "").trim();
                                    if (name.isNotEmpty) {
                                      projectRefForArgs = Reference(name: name);
                                    }
                                  }
                                  final bool isFirstSubLimitUnderHeader =
                                      isProjGroup &&
                                          headerLimitNo != null &&
                                          !detailExists;

                                  final bool isMainLimitForArgs =
                                      isFirstSubLimitUnderHeader
                                          ? false
                                          : (isMainLimit ?? true);

                                  final String? parentLimitNoForOthers =
                                      (isProjGroup &&
                                              headerLimitNo != null &&
                                              !detailExists)
                                          ? headerLimitNo
                                          : limitNumber;

                                  // CAP for ProposedLimit screen:
                                  // - in first sublimit under header: cap must
                                  // be
                                  // header proposed limit (passed as
                                  // `proposedLimit`)
                                  // - otherwise keep the passed
                                  // totalProposedLimit
                                  final int? capForArgs =
                                      isFirstSubLimitUnderHeader
                                          ? headerProposedNow
                                          : totalProposedLimit;

                                  router.go(
                                    Routes.createFacility,
                                    extra: CreateFacilityArgs(
                                      facility: Facility(
                                        facilityDescription: viewModel
                                            .facility.facilityDescription,
                                        limitDescription: viewModel
                                            .facility.facilityDescription?.name,
                                        limitCode: viewModel
                                            .facility.facilityDescription?.id,
                                        limitGroup: limitGroup,
                                        limitType: limitType ?? false,
                                        rimNo: selectedRim,
                                        proposedLimit: headerProposedNow,
                                        facilityTypeSelectedValue: viewModel
                                            .facility.facilityTypeSelectedValue,
                                        selectedProductTypeValue: viewModel
                                            .facility.selectedProductTypeValue,
                                        limitNumber: parentLimitNoForOthers,
                                        isMainLimit: isMainLimitForArgs,
                                        projectName: projectRefForArgs,
                                        productCodeProject:
                                            descSnapshot?.reference3,
                                        limitCapType: capType,
                                        totalProposedLimit: capForArgs,
                                        proposedLimits: headerProposedNow,
                                        isStanbySublimitValidation:
                                            isStanbySublimitValidation,
                                      ),
                                      showCreateFacilityForm: true,
                                    ),
                                  );
                                }
                              // If not ok: remain on the same screen; toast is
                              // already shown in the VM.
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
