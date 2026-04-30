import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/fields/cbrb_classification.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/fields/customer_name.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/fields/customer_rim.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/fields/direct_limits.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/fields/direct_os.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/fields/indirect_limits.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/fields/indirect_os.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/fields/no_of_banks.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/state.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/widgets/action_button.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final AddCbrbDialogViewModel viewModel =
        context.read<AddCbrbDialogViewModel>();
    return BlocBuilder<AddCbrbDialogViewModel, AddCbrbDialogState>(
      builder: (context, state) {
        return _body(context, state, viewModel);
      },
    );
  }

  Widget _body(
    BuildContext context,
    AddCbrbDialogState state,
    AddCbrbDialogViewModel viewModel,
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
          child: Form(
            key: viewModel.formKey,
            child: Column(
              children: [
                FormRow(
                  children: [
                    CustomerRim(viewModel: viewModel),
                    CustomerName(
                      viewModel: viewModel,
                      state: state,
                    ),
                  ],
                ),
                const Gap(),
                FormRow(
                  children: [
                    DirectLimits(viewModel: viewModel),
                    DirectOs(viewModel: viewModel),
                  ],
                ),
                const Gap(),
                FormRow(
                  children: [
                    IndirectLimits(viewModel: viewModel),
                    IndirectOs(viewModel: viewModel),
                  ],
                ),
                const Gap(),
                FormRow(
                  children: [
                    NoOfBanks(viewModel: viewModel),
                    CbrbClassification(viewModel: viewModel),
                  ],
                ),
                const Gap(),
                ActionButton(viewModel: viewModel),
                const Gap(),
              ],
            ),
          ),
        );
    }
  }
}
