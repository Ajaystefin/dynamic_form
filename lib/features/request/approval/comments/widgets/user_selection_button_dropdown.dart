import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wcas_frontend/core/components/button_dropdown.dart';

import '../../../../../core/components/dropdown/model.dart';

class RecommendationDropdown extends StatelessWidget {
  final List<CustomDropdownItem> options;
  final String label;

  const RecommendationDropdown({
    super.key,
    required this.options,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDropdownButton(
      label: label.tr(),
      initialOption: CustomDropdownItem(
        value: label.tr(),
        onPressed: () {
          // Define your action here
        },
      ),
      options: options,
    );
  }
}
