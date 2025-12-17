import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/text_utils.dart';
import 'package:wcas_frontend/models/request/request.dart';

class BusinessSegment extends StatelessWidget {
  final Request request;
  const BusinessSegment({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'common.components.applicationHeader.businessSegment'.tr(),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      child: CustomSelectableText(
        text: (request.businessSegment?.name ?? '').capitalizeFirstLetter(),
        style: const TextStyle(color: AppColors.black),
      ),
    );
  }
}
