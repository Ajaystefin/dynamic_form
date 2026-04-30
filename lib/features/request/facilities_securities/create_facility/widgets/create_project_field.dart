import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/icon.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/project_name.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

class FacilityProjectNameWithAction extends StatelessWidget {
  const FacilityProjectNameWithAction({
    required this.viewModel,
    super.key,
  });
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 0, maxWidth: double.infinity),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: FacilityProjectName(viewModel: viewModel),
          ),
          const SizedBox(width: 8),
          CustomTooltip(
            message: "Create New Project/Contract",
            child: CustomIcon(
              onTap: () {
                router.push(
                  Routes.createProject, // ← push instead of go
                  extra: {
                    "backTo":
                        (Globals.request?.applicationRefNo ?? "").isNotEmpty
                            ? Routes.facilitySummaryView
                            : null, // you can omit the key if null
                  },
                );
              },
              icon: Icons.add_circle_outline_sharp,
              iconColor: AppColors.buttonBackground,
            ),
          ),
        ],
      ),
    );
  }
}
