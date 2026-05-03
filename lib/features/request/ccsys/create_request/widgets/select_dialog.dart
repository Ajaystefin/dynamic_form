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
import "package:wcas_frontend/features/request/ccsys/create_request/fields/selection_table.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/model.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/state.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/widgets/select_actions.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/widgets/textfield_with_button.dart";

class SelectDialog extends StatelessWidget {
  const SelectDialog({required this.viewModel, super.key});
  final CcsysCreateRequestViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CcsysCreateRequestViewModel, CcsysCreateRequestState>(
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
                          label: "requestInformation.createRequest.customerName"
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
                        loaderStatus: viewModel.customerNameLoadingStatus,
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
