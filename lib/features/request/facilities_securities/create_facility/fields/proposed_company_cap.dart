import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class ProposedCompanyCap extends StatelessWidget {
  const ProposedCompanyCap({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool hasData =
        viewModel.getFacility.presentOutstandingCCValue?.name?.isNotEmpty ??
            false;

    final bool hasCountryCodes = viewModel.currencyCodes.isNotEmpty;
    final Reference? selectedCurrency =
        viewModel.getFacility.presentOutstandingCCValue;

    // ---enable only for Group Application AND "Yes" selected in
    // LimitCapGroupLevel
    final bool isGroupApp = !Utils.isGroupApplication();
    final int? sharedId = viewModel.getFacility.sharedLimit?.id;
    final String sharedName =
        (viewModel.getFacility.sharedLimit?.name ?? "").trim().toLowerCase();

    // Prefer ID check; fall back to name if IDs are unavailable in some
    // environments
    final bool isYesSelectedById =
        sharedId == ServerConstants.optionYESid; // 1904
    final bool isYesSelectedByName = sharedName == "yes";
    final bool enableProposedCap =
        isGroupApp || (isYesSelectedById || isYesSelectedByName);
    // ---------------------------------------------

    return LabelWidget(
      label: !Utils.isGroupApplication()
          ? "facilities.createFacility.proposedCompanyCap".tr()
          : "facilities.createFacility.proposedGroupCap".tr(),
      isRequired: true,
      child: CustomTextField(
        readOnly: !enableProposedCap,
        filled: !enableProposedCap,
        key: ValueKey(
          "propCap:${enableProposedCap}_"
          '${viewModel.getFacility.proposedLimit ?? ''}_'
          '${selectedCurrency?.name ?? ''}',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(15),
          ThousandsSeparatorFormatter(),
        ],
        prefixIcon: CustomDropdown<Reference>(
          isEnabled: false,
          width: 70.w,
          height: null,
          validationMessage: "validation.emptyField".tr(),
          items: viewModel.currencyCodes,
          selectedItems: (selectedCurrency != null)
              ? [selectedCurrency]
              : (hasCountryCodes ? [viewModel.currencyCodes.first] : []),
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.getFacility.presentOutstandingCCValue =
                  selectedValue.first;
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
        initialValue: (() {
          // If Group app and the Group Level Cap is NO, always render empty.
          if (Utils.isGroupApplication() && !enableProposedCap) {
            return "";
          }
          // existing logic (VM-first)...
          final int? vmVal = viewModel.getFacility.proposedLimit;
          final bool preferVm =
              viewModel.proposedCapEdited || viewModel.showCreateFacilityForm;

          if (preferVm && vmVal != null && vmVal > 0) {
            return vmVal.toString();
          }

          if (!viewModel.showCreateFacilityForm &&
              viewModel.facilityDetail.isNotEmpty) {
            final int? apiVal =
                viewModel.facilityDetail.first.proposedLimit?.toInt();
            return (apiVal != null && apiVal > 0) ? apiVal.toString() : "";
          }

          return "";
        })(),
        fillColor: !enableProposedCap
            ? (!hasData
                ? AppColors.textFieldDisabledFill
                : AppColors.accordionSecondary)
            : null,
        onChanged: (String? value) {
          if (enableProposedCap) {
            final String raw = (value ?? "").replaceAll(",", "").trim();
            viewModel.proposedCapRaw = raw;
            viewModel.proposedCapEdited = true;

            viewModel.getFacility.proposedLimit = int.tryParse(raw) ?? 0;
            viewModel.getFacility.proposedLimitAED =
                viewModel.getFacility.proposedLimit;
          }
        },
      ),
    );
  }
}
