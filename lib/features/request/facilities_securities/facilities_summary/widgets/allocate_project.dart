import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";

/// Widget for allocating a project to a facility.
///
/// Displays the project allocation dialog or controls used to
/// assign a project name to the selected facility.
class AllocateProject extends StatelessWidget {
  /// Creates an allocate project widget.
  const AllocateProject({
    required this.viewModel,
    required this.facility,
    required this.customer,
    required this.limitGroup,
    required this.selectedRim,
    super.key,
  });

  /// View model containing facility summary data and actions.
  final FacilitiesSummaryViewModel viewModel;

  /// Facility for which the project allocation is being managed.
  final FacilitySummaryNew facility;
  final FacilitySummaryList customer;
  final int limitGroup;
  final int? selectedRim;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FacilitiesSummaryViewModel, FacilitiesSummaryState>(
      builder: (context, state) {
        final viewModel = context.read<FacilitiesSummaryViewModel>();
        // final List<Reference> items = viewModel.projectNames;
        final List<Reference> items =
            facility.limitGroup == ServerConstants.projectStandByLimitID
                ? viewModel.projectNamesStandBy
                : viewModel.projectNamesSpecific;

        final String projectName = (facility.projectName ?? "").trim();

        final List<Reference> selected = items.where((item) {
          return (item.name ?? "").trim().toLowerCase() ==
              projectName.toLowerCase();
        }).toList();

        return Column(
          children: [
            LabelWidget(
              label: "facilities.createFacility.projectName".tr(),
              child: CustomDropdown<Reference>(
                width: 200.w,
                showClearIcon: false,
                items: items,
                selectedItems: selected,
                onSelected: (selectedValue) {
                  if (selectedValue.isNotEmpty) {
                    viewModel.onProjectNameSelected(selectedValue);
                  }
                },
                itemBuilder: (context, item, {isDisabled, isSelected}) {
                  return dropdownMultiItemBuildWidget(
                    item.name,
                    isSelected: isSelected ?? false,
                  );
                },
                dropdownBuilder: (context, data) {
                  return Text(
                    data?.name ?? "",
                    style: const TextStyle(fontSize: 14),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  label: "Save",
                  onPressed: () {
                    viewModel
                      ..applySelectedProjectTo(facility)
                      ..saveFacilitySummaryList(
                        customer,
                        limitGroup: limitGroup,
                        selectedRim: selectedRim,
                      );

                    context.pop();
                  },
                ),
                const Gap(direction: Axis.horizontal),
                CustomButton(
                  label: "Cancel",
                  onPressed: () {
                    context.pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
