import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_group.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class LimitType extends StatelessWidget {
  const LimitType({required this.viewModel, super.key});
  final OthersLimitDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool isIslamic = viewModel.selectedProductTypeOption?.id ==
        ServerConstants.productTypeIslamicID;

    final List<Reference> limitTypeItems = (viewModel.limitTypes)
        .where(
          (e) =>
              (e.name ?? "").trim().toLowerCase() ==
              (isIslamic ? "islamic" : "conventional"),
        )
        .where((e) {
          final int? id =
              e.id is num ? (e.id! as num).toInt() : int.tryParse("${e.id}");
          final String label = (e.reference1 ?? "").trim().toLowerCase();
          final bool isLimitCaps = label.contains("limit caps");
          final bool isExcludedCaps =
              (id == 11330 || id == 11337) && isLimitCaps;
          return (id != 935) && !isExcludedCaps;
        })
        .distinctBy((e) => (e.reference1 ?? "").trim().toUpperCase())
        .toList();

    return LabelWidget(
      label: "facilities.facilitySummary.limit".tr(),
      isRequired: true,
      child: CustomDropdown<Reference>(
        showEditIcon: true,
        items: limitTypeItems,
        selectedItems: viewModel.facility.facilityTypeSelectedValue == null
            ? null
            : [viewModel.facility.facilityTypeSelectedValue],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            final Reference ref = selectedValue.first;
            // keep the facility mirror for downstream screens
            viewModel.facility.facilityTypeSelectedValue = ref;
            // ersist visible label of limit type into reference4
            viewModel.reference.reference4 =
                (ref.reference1 ?? ref.name ?? "").trim();
          }
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.reference1,
            isSelected: isSelected,
            isListTile: false,
          );
        },
        validationMessage: "validation.emptyField".tr(),
        dropdownBuilder: (context, data) {
          return Text(
            data?.reference1 ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }
}
