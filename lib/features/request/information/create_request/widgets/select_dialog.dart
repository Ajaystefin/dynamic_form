import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/selection_table.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/information/create_request/model.dart";
import "package:wcas_frontend/features/request/information/create_request/state.dart";
import "package:wcas_frontend/features/request/information/create_request/widgets/selction_actions.dart";
import "package:wcas_frontend/features/request/information/create_request/widgets/textfield_with_button.dart";

/// Displays a dialog used for selecting request-related data.
///
/// Provides the user interface for searching, viewing, and selecting
/// values that are required during the request creation process.
class SelectDialog extends StatelessWidget {
  /// Creates a [SelectDialog].
  const SelectDialog({
    required this.viewModel,
    super.key,
  });

  /// View model that supplies data and handles selection-related
  /// interactions within the dialog.
  final CreateRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateRequestViewModel, CreateRequestState>(
      bloc: viewModel,
      builder: (context, state) {
        return StatefulBuilder(
          builder: (context, setState) {
            switch (state.loaderStatus) {
              case LoadingStatus.loading:
                setState(() {});
              default:
                setState(() {});
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BoxLayout(
                  child: Column(
                    spacing: AppStyle.spacing,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (viewModel.isGroupNameSelection)
                        SizedBox(
                          width: context.isMobile ? 400.w : null,
                          child: TextfieldWithButton(
                            isFromDialogue: true,
                            isRequired: true,
                            isLoading: viewModel.groupNameLoadingStatus ==
                                LoadingStatus.loading,
                            validator: (value) {
                              return CustomValidator.requiredFieldCustomMsg(
                                value,
                                "common.validation.pleaseEnter".tr() +
                                    "requestInformation."
                                            "createRequest.groupName"
                                        .tr(),
                              );
                            },
                            value: viewModel.groupName,
                            viewModel: viewModel,
                            label: "requestInformation.createRequest.groupName"
                                .tr(),
                            onChanged: (value) {
                              viewModel.groupName = value;
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            buttonLabel:
                                "requestInformation.createRequest.search".tr(),
                            buttonOnPressed: () {
                              viewModel.filterCustomers();
                              setState(() {});
                            },
                            onSubmit: (value) {
                              viewModel.filterCustomers();
                              setState(() {});
                            },
                          ),
                        )
                      else
                        SizedBox(
                          width: context.isMobile ? 400.w : null,
                          child: TextfieldWithButton(
                            isFromDialogue: true,
                            isRequired: true,
                            isLoading: viewModel.customerNameLoadingStatus ==
                                LoadingStatus.loading,
                            validator: (value) {
                              return CustomValidator.requiredFieldCustomMsg(
                                value,
                                "common.validation.pleaseEnter".tr() +
                                    "requestInformation."
                                            "createRequest.customerName"
                                        .tr(),
                              );
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            value: viewModel.customerName,
                            viewModel: viewModel,
                            label: "requestInformation."
                                    "createRequest.customerName"
                                .tr(),
                            onChanged: (value) {
                              viewModel.customerName = value;
                            },
                            buttonLabel:
                                "requestInformation.createRequest.search".tr(),
                            buttonOnPressed: () {
                              viewModel.filterCustomers();
                              setState(() {});
                            },
                            onSubmit: (value) {
                              viewModel.filterCustomers();
                              setState(() {});
                            },
                          ),
                        ),
                      const Gap(
                        size: GapSize.small,
                      ),
                      SelectionTable(
                        customers: viewModel.isGroupNameSelection
                            ? viewModel.uniqueGroups
                            : viewModel.dailogCustomers,
                        selectedCustomer: viewModel.selectedCustomer,
                        isGroupNameSelection: viewModel.isGroupNameSelection,
                        loaderStatus: viewModel.isGroupNameSelection
                            ? viewModel.groupNameLoadingStatus
                            : viewModel.customerNameLoadingStatus,
                      ),
                    ],
                  ),
                ),
                const Gap(),
                SelectionActionWidgets(
                  viewModel: viewModel,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
