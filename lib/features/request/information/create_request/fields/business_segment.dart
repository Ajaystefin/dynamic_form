import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/features/request/information/create_request/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class BussinessSegmentField extends StatelessWidget {
  const BussinessSegmentField({super.key, required this.viewModel});
  final CreateRequestViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        isRequired: true,
        infoContent: "requestInformation.createRequest.nbfiMessage".tr(),
        label: "requestInformation.createRequest.bussinessSegment".tr(),
        child: CustomRadioButton<Reference>(
          options: viewModel.bussinessSegments,
          selectedValue: viewModel.businessSegmentValue ?? Reference(),
          onChanged: (value)async {
           await  viewModel.onBussinessSegmentSelected(value);
          },
          itemBuilder: (context, item, isSelected, isEnabled) {
            return Text(item.name ?? '');
          },
          isRequired: true,
          scrollDirection: Axis.horizontal,
          textStyle: const TextStyle(fontSize: 12),
        ));
  }
}
