import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/manage_reference/model.dart";
import "package:wcas_frontend/features/admin/manage_reference/state.dart";
import "package:wcas_frontend/features/admin/manage_reference/widgets/reference_table.dart";
import "package:wcas_frontend/features/admin/manage_reference/widgets/reference_type_field.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/view.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";

/// Desktop view for managing reference data.
class ViewDesktop extends StatefulWidget {
  /// Creates a [ViewDesktop].
  const ViewDesktop({
    super.key,
  });

  @override
  State<ViewDesktop> createState() => _ViewDesktopState();
}

class _ViewDesktopState extends State<ViewDesktop> {
  @override
  Widget build(BuildContext context) {
    final ManageReferenceViewModel viewModel =
        context.read<ManageReferenceViewModel>();
    return BlocBuilder<ManageReferenceViewModel, ManageReferenceState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            child: BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "admin.referenceDataManagement.sideMenu".tr(),
                  ),
                  const Gap(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BoxLayout(
                        child: _body(context, state, viewModel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    ManageReferenceState state,
    ManageReferenceViewModel viewModel,
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
        return _buildView(context, state, viewModel);
    }
  }

  Widget _buildTable(
    BuildContext context,
    ManageReferenceState state,
    ManageReferenceViewModel viewModel,
  ) {
    switch (state.referencesLoaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Container();
      default:
        return ReferenceTableField(
          viewModel: viewModel,
        );
    }
  }

  Widget _buildView(
    BuildContext context,
    ManageReferenceState state,
    ManageReferenceViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(),
        FormRow(
          children: [
            ReferenceTypeField(
              viewModel: viewModel,
            ),
          ],
        ),
        const Gap(size: GapSize.large),
        _buildTable(context, state, viewModel),
        const Gap(),
        if (viewModel.selectedReferenceType != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // LEFT SIDE
              if (viewModel.selectedReferenceType?.id !=
                  ServerConstants.subSegmentValidationReftType)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onPressed: () async {
                        await DialogHelper.showCustomDialog(
                          barrierDismissible: false,
                          title: "admin.referenceDataManagement."
                                  "referencedatainformationTitle"
                              .tr(),
                          content: UpdateReferenceDialogView(
                            reference: Reference(),
                            referenceType: viewModel.selectedReferenceType ??
                                ReferenceType(),
                          ),
                          context: context,
                        );
                        await viewModel.onReferenceDataSelected(
                          viewModel.selectedReferenceType ?? ReferenceType(),
                        );
                      },
                    ),
                  ],
                )
              else
                const SizedBox(), // keeps spaceBetween layout stable

              // RIGHT SIDE
              CustomButton(
                onPressed: () {
                  viewModel.onSave();
                },
                label: "common.continue".tr(),
                semanticLabel: "common.continue".tr(),
              ),
            ],
          ),
        const Gap(),
      ],
    );
  }
}
