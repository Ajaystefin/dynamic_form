import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/fields/customer_name.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/fields/customer_rim_no.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/model.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/state.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/widgets/action_widgets.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/widgets/select_dialog.dart";

/// Displays the desktop view for the CCSYS create request screen.
class ViewDesktop extends StatefulWidget {
  /// Creates the desktop CCSYS create request view.
  const ViewDesktop({super.key});

  @override
  State<ViewDesktop> createState() => _ViewDesktopState();
}

class _ViewDesktopState extends State<ViewDesktop> {
  @override
  Widget build(BuildContext context) {
    final CcsysCreateRequestViewModel viewModel =
        context.read<CcsysCreateRequestViewModel>();
    return BlocConsumer<CcsysCreateRequestViewModel, CcsysCreateRequestState>(
      listener: (context, state) {
        if (state.showSelectDialog) {
          DialogHelper.showCustomDialog(
            barrierDismissible: false,
            onClosePressed: () {
              Navigator.pop(context);
              viewModel.onSelectionCancelButtonPress();
            },
            context: context,
            // width: context.isDesktop ? 600.w : null,
            content: SelectDialog(
              viewModel: viewModel,
            ),
            title: "requestInformation.createRequest.selectCustomerName".tr(),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Layout(
            hideSideMenu: true,
            child: _body(context, state, viewModel),
          ),
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
        return Center(child: _buildWidgets(viewModel));
    }
  }

  Widget _buildWidgets(CcsysCreateRequestViewModel viewModel) {
    return Focus(
      focusNode: viewModel.formFocusNode,
      child: Form(
        key: viewModel.formKey,
        child: BoxLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                title: "ccsys.createRequest.createNewRequest".tr(),
              ),
              const Gap(),
              Column(
                children: [
                  // Top Customer Namw Request Type.
                  BoxLayout(
                    child: ValueListenableBuilder<Map<ControlFields, bool>>(
                      valueListenable: viewModel.fieldCntrl,
                      builder: (context, contrlValue, _) {
                        return Column(
                          // spacing: AppStyle.spacing,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FormRow(
                              children: [
                                CustomerRimNoField(
                                  viewModel: viewModel,
                                ),
                                CustomerNameField(
                                  viewModel: viewModel,
                                ),
                              ],
                            ),
                            const Gap(
                              size: GapSize.large,
                            ),
                            ActionWidgets(viewModel: viewModel),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //function to show two widgets in a row with responsive size
  // Widget _buildRowWidgets(List<Widget> childrens) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 8),
  //     child: Row(
  //         spacing: AppStyle.spacingLarge, // Add spacing between the widgets
  //         children: List.generate(
  //             childrens.length,
  //             (index) => Expanded(
  //                   child: childrens[index],
  //                 ))),
  //   );
  // }
}
