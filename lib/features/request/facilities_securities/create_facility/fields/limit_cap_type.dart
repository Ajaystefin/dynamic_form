import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the limit cap type.
class LimitCapType extends StatelessWidget {
  /// Creates a limit cap type widget.
  const LimitCapType({required this.viewModel, super.key});

  /// View model containing limit cap type data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final int? currentGroupId = viewModel.limitGroup;
    final List<Reference> items = viewModel.limitCapsType;

    Reference? preselected;
    final num? apiId = viewModel.facilityDetails.limitCapType;

    if (apiId != null) {
      preselected = items.firstWhere(
        (e) => e.id?.toString() == apiId.toString(),
        orElse: () => items.first,
      );
    } else if (items.isNotEmpty && currentGroupId != null) {
      if (currentGroupId == 11312 ||
          currentGroupId == 11313 ||
          currentGroupId == 11314) {
        preselected = items.first;
      } else if (currentGroupId == 11315 && items.length > 1) {
        preselected = items[1];
      } else if (currentGroupId == 11317) {
        preselected = items.last;
      }
    }

    preselected ??= items.isNotEmpty ? items.first : null;
    // First time: set default and fetch
    if (preselected != null && viewModel.facilityDetails.limitCapType == null) {
      final int? typeId = _toInt(preselected.id);
      viewModel.facilityDetails.limitCapType = preselected.id;
      viewModel.getFacility.limitCapType = preselected.id;
      final int? mappedGroupId = _mapGroupId(typeId);
      if (mappedGroupId != null) {
        viewModel.limitGroup = mappedGroupId;
        viewModel.getFacility.limitGroup = mappedGroupId;
      }
      final int? facilityId = viewModel.getFacility.facilityId; // <-- String?
      final int? rimNo = viewModel.getFacility.rimNo;
      // Call after first frame; VM will emit and rebuild the section
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await viewModel.getFacilityDetails(
          facilityId,
          rimNo,
          groupId: mappedGroupId,
          limitCapType: typeId,
        );

        // - set Group Level = NO and clear proposed cap ----
        if (viewModel.sharedLimits.isNotEmpty) {
          viewModel.getFacility.sharedLimit =
              _pickNoOption(viewModel.sharedLimits);
        }
        viewModel.getFacility.proposedLimit = null; // clear numeric value
        viewModel.getFacility.proposedLimitAED =
            null; // clear AED mirror if any
        viewModel.proposedCapEdited = false; // reset edit flag
        // ---------------------------------------------------------

        viewModel.emitLimitCapsRefresh(); // see next section
      });
    }
    final bool isEnabled = viewModel.existingFacilityId != null;
    return LabelWidget(
      label: "facilities.createFacility.limitCapType".tr(),
      isRequired: true,
      child: CustomDropdown<Reference>(
        isEnabled: !isEnabled,
        semanticLabel: "facilities.createFacility.limitCapType".tr(),
        validationMessage: "validation.emptyField".tr(),
        items: items,
        selectedItems: preselected != null ? [preselected] : null,
        onSelected: (selectedValue) async {
          if (selectedValue.isEmpty) {
            return;
          }

          final Reference picked = selectedValue.first;
          final int? typeId = _toInt(picked.id);

          viewModel.facilityDetails.limitCapType = picked.id;
          viewModel.getFacility.limitCapType = picked.id;
          final int? mappedGroupId = _mapGroupId(typeId);
          if (mappedGroupId != null) {
            viewModel.limitGroup = mappedGroupId;
            viewModel.getFacility.limitGroup = mappedGroupId;
          }

          final int? facilityId =
              viewModel.getFacility.facilityId; // <-- String?
          final int? rimNo = viewModel.getFacility.rimNo;

          await viewModel.getFacilityDetails(
            facilityId,
            rimNo,
            groupId: mappedGroupId,
            limitCapType: typeId,
          );

// ---- NEW: set Group Level = NO and clear proposed cap ----
          if (viewModel.sharedLimits.isNotEmpty) {
            viewModel.getFacility.sharedLimit =
                _pickNoOption(viewModel.sharedLimits);
          }
          viewModel.getFacility.proposedLimit = null;
          viewModel.getFacility.proposedLimitAED = null;
          viewModel.proposedCapEdited = false;

          viewModel.emitLimitCapsRefresh(); // see next section
        },
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownMultiItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        dropdownBuilder: (context, data) {
          return Text(data?.name ?? "", style: const TextStyle(fontSize: 14));
        },
      ),
    );
  }
}

int? _toInt(id) => (id is num) ? id.toInt() : int.tryParse("$id");

int? _mapGroupId(int? typeId) {
  if (typeId == 14492) {
    return 11312; // General
  }
  if (typeId == 14493) {
    return 11317; // Stand-by
  }
  if (typeId == 14494) {
    return 11315; // Specific
  }
  return null;
}

Reference _pickNoOption(List<Reference> options) {
  try {
    return options.firstWhere((r) => r.id == ServerConstants.optionNOid);
  } on Object catch (_) {
    try {
      return options.firstWhere(
        (r) => (r.name ?? "").trim().toLowerCase() == "no",
      );
    } on Object catch (_) {
      return options.isNotEmpty ? options.first : Reference();
    }
  }
}
