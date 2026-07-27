import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/model.dart";

/// Input field for entering the group ID.
class GroupIdField extends StatelessWidget {
  /// Creates a [GroupIdField].
  const GroupIdField({
    required this.viewModel,
    super.key,
  });

  /// View model used to manage advanced search values.
  final AdvancedSearchViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      label: "dashboard.advancedSearch.groupId".tr(),
      child: CustomTextField(
        initialValue: viewModel.groupId,
        semanticLabel: "dashboard.advancedSearch.groupId".tr(),
        inputFormatters: [
          LengthLimitingTextInputFormatter(15),
          FilteringTextInputFormatter.digitsOnly,
        ],
        validator: (value) {
          return CustomValidator.requiredCustomField(
            value,
            "dashboard.advancedSearch.groupId".tr(),
          );
        },
        onChanged: (value) {
          viewModel.groupId = value;
        },
      ),
    );
  }
}
