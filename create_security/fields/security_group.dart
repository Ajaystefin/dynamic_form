import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class SecurityGroup extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const SecurityGroup({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'security.createSecurity.securityGroup'.tr(),
      isRequired: true,
      showLabel: true,
      child: CustomDropdown<Reference>(
        isSearchable: true,
        validationMessage: "validation.emptyField".tr(),
        items: viewModel.securityReferenceData
            .where((e) => (e.reference4 ?? "").trim().isNotEmpty)
            .distinctBy((e) => e.reference4?.trim())
            .toList(),
        // selectedItems: [viewModel.security?.securityGroup],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.securityGroupSelected(selectedValue.first);
          }
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return ListTile(
            title: Text(item.reference4 ?? ""),
          );
        },

        filterFn: (item, search) {
          return (item.reference4 ?? "")
              .toLowerCase()
              .contains(search.toLowerCase());
        },

        dropdownBuilder: (context, data) {
          return Text(
            data?.reference4 ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }
}

extension DistinctBy<T> on Iterable<T> {
  Iterable<T> distinctBy(String? Function(T) keySelector) {
    final seen = <String?>{};
    return where((element) => seen.add(keySelector(element)));
  }
}
