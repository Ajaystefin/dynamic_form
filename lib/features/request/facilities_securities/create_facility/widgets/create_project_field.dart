import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/icon.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/project_name.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

/// Widget for displaying and managing the facility project name with actions.
class FacilityProjectNameWithAction extends StatelessWidget {
  /// Creates a facility project name with action widget.
  const FacilityProjectNameWithAction({
    required this.viewModel,
    super.key,
  });

  /// View model containing facility project name data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool isProjectStandByMainLimit =
        (viewModel.getFacility.controllingLimitNumber ??
                viewModel.parentControlliingNumber ??
                "")
            .startsWith(ServerConstants.productCodePsbl);
    return ConstrainedBox(
      constraints: const BoxConstraints(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: FacilityProjectName(
              viewModel: viewModel,
              isEnabled: !isProjectStandByMainLimit,
            ),
          ),
          const SizedBox(width: 8),
          CustomTooltip(
            message: "Create New Project/Contract",
            child: CustomIcon(
              onTap: isProjectStandByMainLimit
                  ? null
                  : () {
                      router.push(
                        Routes.createProject, // ← push instead of go
                        extra: {
                          "backTo": (Globals.request?.applicationRefNo ?? "")
                                  .isNotEmpty
                              ? Routes.facilitySummaryView
                              : null, // you can omit the key if null
                        },
                      );
                    },
              icon: Icons.add_circle_outline_sharp,
              iconColor: isProjectStandByMainLimit
                  ? AppColors.tableCellColorGroupedRow
                  : AppColors.buttonBackground,
            ),
          ),
        ],
      ),
    );
  }
}
