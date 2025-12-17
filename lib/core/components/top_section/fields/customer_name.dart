import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

import 'package:wcas_frontend/models/request/request.dart';

class CustomerName extends StatelessWidget {
  final Request request;
  const CustomerName({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'common.components.applicationHeader.customerName'.tr(),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      child: CustomSelectableText(
        text:
            '${(request.customerName ?? '').isNotEmpty ? (request.customerName ?? '') : ''}'
            '${(request.customerRimNo?.toString() ?? '').isNotEmpty ? ' (${(request.customerRimNo?.toString() ?? '')})' : ''}',
        style: const TextStyle(color: AppColors.black),
      ),
    );
  }
}
