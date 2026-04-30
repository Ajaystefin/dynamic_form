import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

class BorrowingRelationshipFromField extends StatelessWidget {
  const BorrowingRelationshipFromField({required this.viewModel, super.key});
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    String initialValue = "";
    final rawDate = viewModel.customerInformation?.borrowRelationShipDate;
    initialValue = safeParseDate(
      rawDate,
      viewModel.customerInformation?.borrowRelationShipDate,
    );

    return LabelWidget(
      label: "customerInformation.customerInformation.borrowingRelationshipFrom"
          .tr(),
      isRequired: (viewModel.isFI) ? false : true,
      child: CustomTextField(
        key: const ValueKey("borrowingRelationshipFrom"),
        maxLength: 20,
        semanticLabel:
            "customerInformation.customerInformation.borrowingRelationshipFrom"
                .tr(),
        initialValue: initialValue,
        filled: viewModel.canEdit ? viewModel.hasLastApprovedApp : true,
        readOnly: viewModel.canEdit ? viewModel.hasLastApprovedApp : true,
        onSaved: (value) {
          final String? result = normalizeDateToIso(value);
          if (result != null &&
              RegExp(r"^\d{4}-\d{2}-\d{2}$").hasMatch(result)) {
            viewModel.customerInformation?.isBorrowerRelationshipDate = true;
            viewModel.customerInformation?.borrowRelationShipDate = result;
          } else {
            viewModel.customerInformation?.isBorrowerRelationshipDate = false;
            viewModel.customerInformation?.borrowRelationShipDate = result;
          }
        },
        validator: (viewModel.isFI) ? null : CustomValidator.requiredField,
      ),
    );
  }
}

String? normalizeDateToIso(dynamic value) {
  if (value == null) return null;

  // Case 1: Already a DateTime
  if (value is DateTime) {
    return DateFormat("yyyy-MM-dd").format(value);
  }

  // Case 2: String
  if (value is String) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    // dd/MM/yyyy
    try {
      final DateTime parsed = DateFormat("dd/MM/yyyy").parseStrict(trimmed);
      return DateFormat("yyyy-MM-dd").format(parsed);
    } catch (_) {}

    // yyyy-MM-dd
    try {
      final DateTime parsed = DateFormat("yyyy-MM-dd").parseStrict(trimmed);
      return DateFormat("yyyy-MM-dd").format(parsed);
    } catch (_) {}

    // ISO / DateTime string
    try {
      final DateTime parsed = DateTime.parse(trimmed);
      return DateFormat("yyyy-MM-dd").format(parsed);
    } catch (_) {}

    // Not a date
    return trimmed;
  }

  return value.toString();
}

String safeParseDate(String? rawDate, String? fallback) {
  if (rawDate == null || rawDate.trim().isEmpty) {
    return fallback ?? "";
  }

  final trimmed = rawDate.trim();

  //Filter out invalid patterns like "123", "12345"
  if (trimmed.startsWith("123") || trimmed.length < 6) {
    return fallback ?? "";
  }

  //Try ISO 8601 parsing safely
  final iso = DateTime.tryParse(trimmed);
  if (iso != null) {
    return DateFormat("dd/MM/yyyy").format(iso);
  }

  //Try timestamp (seconds or milliseconds)
  final ts = int.tryParse(trimmed);
  if (ts != null) {
    try {
      final date = trimmed.length == 10
          ? DateTime.fromMillisecondsSinceEpoch(ts * 1000) // seconds
          : DateTime.fromMillisecondsSinceEpoch(ts); // milliseconds

      return DateFormat("dd/MM/yyyy").format(date);
    } catch (_) {
      return fallback ?? "";
    }
  }

  //Last fallback
  return fallback ?? "";
}
