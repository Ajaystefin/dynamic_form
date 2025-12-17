import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/state.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary_list.dart';

//title allocate project , filed name;project name
class AllocateProject extends StatelessWidget {
  final FacilitiesSummaryViewModel viewModel;
  final FacilitySummaryNew facility;
  const AllocateProject({
    super.key,
    required this.viewModel,
    required this.facility,
  });

  @override
  Widget build(BuildContext context) {
    final List<Reference> items = viewModel.projectNames;
    return BlocBuilder<FacilitiesSummaryViewModel, FacilitiesSummaryState>(
      builder: (context, state) {
        final viewModel = context.read<FacilitiesSummaryViewModel>();
        return Column(
          children: [
            LabelWidget(
              label: 'facilities.createFacility.projectName'.tr(),
              isRequired: false,
              showLabel: true,
              child: CustomDropdown<Reference>(
                width: 200.w,
                showClearIcon: false,
                isEnabled: true,
                items: items,
                selectedItems: [
                  viewModel.matchOrFirstByName(items, facility.projectName)
                ],
                onSelected: (selectedValue) {
                  if (selectedValue.isNotEmpty) {
                    viewModel.onProjectNameSelected(selectedValue);
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
                       viewModel.applySelectedProjectTo(facility);
                      context.pop();
                    }),
                const Gap(direction: Axis.horizontal),
                CustomButton(
                    label: "Cancel",
                    onPressed: () {
                      context.pop();
                    })
              ],
            )
          ],
        );
      },
    );
  }
}
