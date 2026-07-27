import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/fields/customer_name.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/fields/customer_rim_no.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/model.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/state.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/widgets/action_widgets.dart";

/// Displays the mobile view for the CCSYS create request screen.
class ViewMobile extends StatefulWidget {
  /// Creates the mobile CCSYS create request view.
  const ViewMobile({super.key});

  @override
  State<ViewMobile> createState() => _ViewMobileState();
}

class _ViewMobileState extends State<ViewMobile> {
  @override
  Widget build(BuildContext context) {
    final CcsysCreateRequestViewModel viewModel =
        context.read<CcsysCreateRequestViewModel>();
    return BlocConsumer<CcsysCreateRequestViewModel, CcsysCreateRequestState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(child: _body(context, state, viewModel)),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    CcsysCreateRequestState state,
    CcsysCreateRequestViewModel viewModel,
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

  final FocusNode formFocusNode = FocusNode();

  @override
  void dispose() {
    formFocusNode.dispose();
    super.dispose();
  }

  Widget _buildWidgets(CcsysCreateRequestViewModel viewModel) {
    return BoxLayout(
      child: Focus(
        focusNode: formFocusNode,
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                title: "ccsys.createRequest.createNewRequest".tr(),
              ),
              const Gap(),
              BoxLayout(
                child: ValueListenableBuilder<Map<ControlFields, bool>>(
                  valueListenable: viewModel.fieldCntrl,
                  builder: (context, contrlValue, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomerRimNoField(viewModel: viewModel),
                        CustomerNameField(viewModel: viewModel),
                        const Gap(),
                        ActionWidgets(viewModel: viewModel),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
