import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/fields/selection_table.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/state.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/selction_actions.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/textfield_with_button.dart";

class SelectDialog extends StatelessWidget {
  const SelectDialog({required this.viewModel, super.key});
  final DigitalEfilingViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DigitalEfilingViewModel, DigitalEfilingState>(
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BoxLayout(
                  child: Column(
                    spacing: AppStyle.spacing,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      viewModel.isGroupNameSelection
                          ? SizedBox(
                              width: context.isMobile ? 200.w : null,
                              child: TextfieldWithButton(
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
                                label:
                                    "requestInformation.createRequest.groupName"
                                        .tr(),
                                onChanged: (value) {
                                  viewModel.groupName = value;
                                },
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                buttonLabel:
                                    "requestInformation.createRequest.search"
                                        .tr(),
                                buttonOnPressed: () {
                                  viewModel.isSearched = false;
                                  viewModel.onGroupNameSearchPressed(
                                    showDialog: false,
                                  );
                                  setState(() {});
                                },
                                onSubmit: (value) {
                                  viewModel.onGroupNameSearchPressed(
                                    showDialog: false,
                                  );
                                  setState(() {});
                                },
                                isFromDialogue: true,
                              ),
                            )
                          : SizedBox(
                              width: context.isMobile ? 400.w : null,
                              child: TextfieldWithButton(
                                isFromDialogue: true,
                                isRequired: true,
                                isLoading:
                                    viewModel.customerNameLoadingStatus ==
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
                                    "requestInformation.createRequest.search"
                                        .tr(),
                                buttonOnPressed: () {
                                  viewModel.isSearched = false;
                                  viewModel.onCustomerNameSearchPressed(
                                    showDialog: false,
                                  );
                                  setState(() {});
                                },
                                onSubmit: (value) {
                                  viewModel.onCustomerNameSearchPressed(
                                    showDialog: false,
                                  );
                                  setState(() {});
                                },
                              ),
                            ),
                      const Gap(
                        size: GapSize.small,
                      ),
                      SelectionTable(
                        loaderStatus: viewModel.isGroupNameSelection
                            ? viewModel.groupNameLoadingStatus
                            : viewModel.customerNameLoadingStatus,
                        viewModel: viewModel,
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
