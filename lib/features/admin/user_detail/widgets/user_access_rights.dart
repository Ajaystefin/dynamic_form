import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/features/admin/user_detail/model.dart";
import "package:wcas_frontend/features/admin/user_detail/state.dart";

class UserAccessRights extends StatefulWidget {
  const UserAccessRights({required this.viewModel, super.key});
  final UserDetailViewModel viewModel;

  @override
  State<UserAccessRights> createState() => _UserAccessRightsState();
}

class _UserAccessRightsState extends State<UserAccessRights> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserDetailViewModel, UserDetailState>(
      builder: (context, state) {
        return CustomRawTable(
          key: UniqueKey(), // UniqueKey() to force rebuild credits to AJKP
          columns: [
            TableColumn(
              label: CustomSelectableText(
                text: "admin.userManagementDetail.accessRights".tr(),
              ),
            ),
            const TableColumn(label: CustomSelectableText(text: "")),
          ],
          rows: [
            _buildRow(
              label: "admin.userManagementDetail.approveOnBehalfOf".tr(),
              value: state.approveOnBehalfOf,
              onChanged: (val) {
                context
                    .read<UserDetailViewModel>()
                    .onApproveOnBehalfOfSelected(val);
              },
            ),
            _buildRow(
              label: "admin.userManagementDetail.approvalAccess".tr(),
              value: state.approvalAccess,
              onChanged: (val) {
                context
                    .read<UserDetailViewModel>()
                    .onApprovalAccessSelected(val);
              },
            ),
            _buildRow(
              label:
                  "admin.userManagementDetail.transactionApprovalAccess".tr(),
              value: state.tranApprovalAccess,
              onChanged: (val) {
                context
                    .read<UserDetailViewModel>()
                    .onTranApprovalAccessSelected(val);
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildRow({
    required String label,
    required bool? value,
    required void Function(bool?) onChanged,
  }) {
    return [
      CustomSelectableText(
        text: label,
      ),
      CustomCheckbox(
        value: value ?? false,
        onChange: onChanged,
        onSaved: onChanged,
      ),
    ];
  }
}
