import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/information/application_borrowers/fields/actions.dart";
import "package:wcas_frontend/features/request/information/application_borrowers/fields/borrowers_part_of_the_application.dart";
import "package:wcas_frontend/features/request/information/application_borrowers/model.dart";
import "package:wcas_frontend/features/request/information/application_borrowers/state.dart";
import "package:wcas_frontend/models/request/request.dart";

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final ApplicationBorrowersViewModel viewModel =
        context.read<ApplicationBorrowersViewModel>();
    return BlocBuilder<ApplicationBorrowersViewModel,
        ApplicationBorrowersState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    ApplicationBorrowersState state,
    ApplicationBorrowersViewModel viewModel,
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
      case LoadingStatus.error:
        return Center(
          child: Text("common.errorState".tr()),
        );
      default:
        return _buildWidgets(viewModel);
    }
  }

  Widget _buildWidgets(ApplicationBorrowersViewModel viewModel) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                title: "requestInformation.applicationBorrowers."
                        "borrowersPartOfTheApplication"
                    .tr(),
              ),
              const Gap(size: GapSize.medium),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoxLayout(
                    child: TopSectionDetails(
                      request: Globals.request ?? Request(),
                    ),
                  ),
                  BoxLayout(
                    disabled: viewModel.isReadOnly,
                    child: const BorrowersPartOfTheApplication(),
                  ),
                ],
              ),
              const Gap(),
              if (!viewModel.isReadOnly) const ActionWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
