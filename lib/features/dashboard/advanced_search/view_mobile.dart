import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/model.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/state.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/view_desktop.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/action_widget.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/region_field.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/request_status_field.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/search_criteria_field.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/username_field.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/worklist_table.dart";
import "package:wcas_frontend/features/layout/view.dart";

/// Mobile view for the Advanced Search screen.
class ViewMobile extends StatefulWidget {
  /// Creates a [ViewMobile].
  const ViewMobile({super.key});

  @override
  State<ViewMobile> createState() => _ViewMobileState();
}

class _ViewMobileState extends State<ViewMobile> {
  @override
  Widget build(BuildContext context) {
    final AdvancedSearchViewModel viewModel =
        context.read<AdvancedSearchViewModel>();
    return BlocBuilder<AdvancedSearchViewModel, AdvancedSearchState>(
      builder: (context, state) {
        return Layout(
          hideSideMenu: true,
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    AdvancedSearchState state,
    AdvancedSearchViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text("common.emptyState".tr()),
        );
      default:
        return Center(child: buildView(viewModel, state));
    }
  }

  final FocusNode formFocusNode = FocusNode();

  @override
  void dispose() {
    formFocusNode.dispose();
    super.dispose();
  }

  Widget buildView(
    AdvancedSearchViewModel viewModel,
    AdvancedSearchState state,
  ) {
    return BoxLayout(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppStyle.spacing),
              child: CustomSectionHeader(
                title: "dashboard.advancedSearch.requestSummary".tr(),
              ),
            ),
            const Gap(),
            Align(
              alignment: Alignment.centerRight,
              child: AddItemButton(
                child: Text(
                  "dashboard.advancedSearch.createNewRequest".tr(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: AppStyle.fontSizeSmall,
                  ),
                ),
                onTap: () {
                  router.go(Routes.requestCreate);
                },
              ),
            ),
            const Gap(),
            BoxLayout(
              child: Form(
                key: viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppStyle.spacing,
                  children: [
                    CustomSelectableText(
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      text: "dashboard.advancedSearch.advancedSearch".tr(),
                    ),
                    SearchCriteriaField(
                      viewModel: viewModel,
                    ),
                    selectedField(viewModel),
                    if (viewModel.showRoleIdField())
                      UsernameField(viewModel: viewModel),
                    if (viewModel.showRegionField())
                      RegionField(viewModel: viewModel),
                    RequestStatusField(viewModel: viewModel),
                    ActionWidget(viewModel: viewModel),
                  ],
                ),
              ),
            ),
            BoxLayout(child: WorklistTable(viewModel, state)),
          ],
        ),
      ),
    );
  }
}
