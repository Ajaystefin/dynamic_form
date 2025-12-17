import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/form_row.dart';
// import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:wcas_frontend/features/request/projects/search_project/fields/action.dart';
import 'package:wcas_frontend/features/request/projects/search_project/fields/custom_search_by_field.dart';
import 'package:wcas_frontend/features/request/projects/search_project/fields/project_contract_table.dart';
import 'package:wcas_frontend/features/request/projects/search_project/fields/search_by.dart';
import 'package:wcas_frontend/features/request/projects/search_project/fields/search_criteria.dart';
import 'package:wcas_frontend/features/request/projects/search_project/widgets/create_project_button.dart';
// import 'package:wcas_frontend/features/request/projects/search_project/fields/action.dart';
// import 'package:wcas_frontend/features/request/projects/search_project/fields/custom_search_by_field.dart';
// import 'package:wcas_frontend/features/request/projects/search_project/fields/search_by.dart';
// import 'package:wcas_frontend/features/request/projects/search_project/fields/search_criteria.dart';
// import 'package:wcas_frontend/features/request/projects/search_project/fields/project_contract_table.dart';
// import 'package:wcas_frontend/features/request/projects/search_project/widget/create_project_button.dart';

import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    SearchProjectViewModel viewModel = context.read<SearchProjectViewModel>();
    return BlocBuilder<SearchProjectViewModel, SearchProjectState>(
        builder: (context, state) {
      return Scaffold(body: _body(context, state, viewModel));
    });
  }

  Widget _body(BuildContext context, SearchProjectState state,
      SearchProjectViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text('common.emptyState'.tr()),
        );
      case LoadingStatus.error:
        return Center(
          child: Text('common.errorState'.tr()),
        );
      default:
        return Layout(child: _buildWidgets(context, viewModel, state));
    }
  }

  Widget _buildWidgets(BuildContext context, SearchProjectViewModel viewModel,
      SearchProjectState state) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Form(
          key: viewModel.formKey,
          child: Column(children: [
            Row(
              children: [
                CustomSectionHeader(
                  title: "project.searchProject.title".tr(),
                ),
              ],
            ),
            const Gap(),
            Column(children: [
              // BoxLayout(
              //   child: TopSectionDetails(
              //     request: Globals.request ?? Request(),
              //   ),
              // ),
              // const Gap(),
              BoxLayout(
                extraPadding: true,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SearchBy(
                              viewModel: viewModel,
                              state: state,
                            ),
                          ),
                        ),
                        const Gap(),
                        Expanded(
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: CreateProjectButton(viewModel: viewModel)),
                        )
                      ],
                    ),
                    const Gap(size: GapSize.large),
                    FormRow(children: [
                      SearchCriteria(viewModel: viewModel, state: state),
                      (state.showCustomerTypeField == true)
                          ? CustomSearchByField(viewModel: viewModel)
                          : Container(),
                      Container()
                    ]),
                    const Gap(),
                    (state.showDataTable == true)
                        ? ProjectContractTable(viewModel: viewModel)
                        : Container(),
                    const Gap(
                      size: GapSize.large,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ActionButton(viewModel: viewModel),
                    )
                  ],
                ),
              )
            ]),
          ]),
        ),
      ),
    );
  }
}
