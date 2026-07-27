import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the deferred waived by selection.
class DeferredWaivedBy extends StatelessWidget {
  /// Creates a deferred waived by widget.
  const DeferredWaivedBy({
    required this.viewModel,
    super.key,
  });

  /// View model containing deferred waived by data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "security.createSecurity.deferredWaivedBy".tr(),
      exponent: "#",
      child: CustomDropdown<Reference>(
        ignoreProvider: viewModel.isCmoUpdate(),
        items: viewModel.securityDeferredWaivedItems,
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.security.deferredWaivedBy = selectedValue.first.name;
          }
        },
        selectedItems: [
          if (viewModel.security.deferredWaivedBy == null)
            null
          else
            Reference(name: viewModel.security.deferredWaivedBy),
        ],
        filterFn: (Reference item, String filter) {
          return (item.name ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name),
      ),
    );
  }
}
