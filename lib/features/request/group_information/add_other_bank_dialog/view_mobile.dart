import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/fields/comments.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/fields/customer_rim.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/fields/funded.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/fields/name_of_banks.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/fields/not_funded.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/fields/security.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/fields/total.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/fields/type_of_facility.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/state.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/widgets/action_button.dart";

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final AddOtherBankDialogViewModel viewModel =
        context.read<AddOtherBankDialogViewModel>();
    return BlocBuilder<AddOtherBankDialogViewModel, AddOtherBankDialogState>(
      builder: (context, state) {
        return _body(context, state, viewModel);
      },
    );
  }

  Widget _body(
    BuildContext context,
    AddOtherBankDialogState state,
    AddOtherBankDialogViewModel viewModel,
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
        return BoxLayout(
          child: SingleChildScrollView(
            child: Form(
              key: viewModel.formKey,
              child: Column(
                children: [
                  CustomerRim(viewModel: viewModel),
                  const Gap(),
                  NameOfBanks(viewModel: viewModel),
                  const Gap(),
                  TypeOfFacility(viewModel: viewModel),
                  const Gap(),
                  SecurityField(viewModel: viewModel),
                  const Gap(),
                  Funded(viewModel: viewModel),
                  const Gap(),
                  NotFunded(viewModel: viewModel),
                  const Gap(),
                  Total(viewModel: viewModel),
                  const Gap(),
                  Comments(viewModel: viewModel),
                  const Gap(),
                  ActionButton(viewModel: viewModel),
                  const Gap(),
                ],
              ),
            ),
          ),
        );
    }
  }
}
