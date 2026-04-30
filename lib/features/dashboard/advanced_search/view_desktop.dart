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
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/action_widget.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/application_ref_no_field.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/customer_rim_no_field.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/group_id_field.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/region_field.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/request_status_field.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/rm_name_field.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/role_id_field.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/search_criteria_field.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/segment_field.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/username_field.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/widgets/worklist_table.dart";
import "package:wcas_frontend/features/layout/view.dart";

class ViewDesktop extends StatefulWidget {
  const ViewDesktop({super.key});

  @override
  State<ViewDesktop> createState() => _ViewDesktopState();
}

class _ViewDesktopState extends State<ViewDesktop> {
  @override
  Widget build(BuildContext context) {
    final AdvancedSearchViewModel viewModel =
        context.read<AdvancedSearchViewModel>();
    return BlocBuilder<AdvancedSearchViewModel, AdvancedSearchState>(
      builder: (context, state) {
        return Layout(
          hideSideMenu: true,
          child: SingleChildScrollView(child: _body(context, state, viewModel)),
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
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              const Gap(direction: Axis.horizontal),
              CustomSectionHeader(
                title: "dashboard.advancedSearch.requestSummary".tr(),
              ),
              const Spacer(),
              AddItemButton(
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
            ],
          ),
          BoxLayout(
            child: Form(
              key: viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(),
                  CustomSelectableText(
                    style: const TextStyle(
                      color: AppColors.loginBackground,
                      fontSize: 17,
                    ),
                    text: "dashboard.advancedSearch.advancedSearch".tr(),
                  ),
                  const Gap(),
                  _buildRowWidgets([
                    SearchCriteriaField(
                      viewModel: viewModel,
                    ),
                    selectedField(viewModel),
                    viewModel.showRegionField()
                        ? RegionField(viewModel: viewModel)
                        : viewModel.showRoleIdField()
                            ? UsernameField(viewModel: viewModel)
                            : const Gap(),
                  ]),
                  _buildRowWidgets([
                    RequestStatusField(viewModel: viewModel),
                    const Gap(
                      size: GapSize.medium,
                    ),
                    const Gap(
                      size: GapSize.medium,
                    ),
                  ]),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ActionWidget(viewModel: viewModel),
                  ),
                ],
              ),
            ),
          ),
          BoxLayout(child: WorklistTable(viewModel, state)),
        ],
      ),
    );
  }

  // function to show two widgets in a row with responsive size
  Widget _buildRowWidgets(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyle.spacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: AppStyle.spacingLarge, // Add spacing between the widgets
        children: List.generate(
          children.length,
          (index) => Expanded(child: children[index]),
        ),
      ),
    );
  }
}

Widget selectedField(AdvancedSearchViewModel viewModel) {
  if (viewModel.showApplicationRefIdField()) {
    return ApplicationRefNoField(viewModel: viewModel);
  } else if (viewModel.showCustomerRimNoField()) {
    return CustomerRimNoField(viewModel: viewModel);
  } else if (viewModel.showGroupIdField()) {
    return GroupIdField(viewModel: viewModel);
  } else if (viewModel.showRegionField()) {
    return SegmentField(viewModel: viewModel);
  } else if (viewModel.showRmNameField()) {
    return RMNameField(viewModel: viewModel);
  } else if (viewModel.showRoleIdField()) {
    return RoleIdField(viewModel: viewModel);
  } else {
    return Container(); // default fallback
  }
}
