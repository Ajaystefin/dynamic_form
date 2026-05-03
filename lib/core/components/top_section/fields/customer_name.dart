import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/models/request/request.dart";

class CustomerName extends StatelessWidget {
  const CustomerName({required this.request, super.key});
  final Request request;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "common.components.applicationHeader.customerName".tr(),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      child: CustomSelectableText(
        text: () {
          // Build display text: "Customer Name (RIM)"
          final String name = request.customerName ?? "";
          final String rim = request.customerRimNo?.toString() ?? "";
          final String rimPart = rim.isNotEmpty ? " ($rim)" : "";
          return "$name$rimPart";
        }(),
        style: const TextStyle(color: AppColors.black),
      ),
    );
  }
}
