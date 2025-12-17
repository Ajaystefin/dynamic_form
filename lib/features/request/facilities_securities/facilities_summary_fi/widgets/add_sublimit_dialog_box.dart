import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/fields/limit_description.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/fields/limits.dart';

import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/model.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/state.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class AddSubLimitDialogBoxFi extends StatelessWidget {
  final FacilityGroup? facilityGroup;
  final Facility? facility;
  const AddSubLimitDialogBoxFi({
    super.key,
    this.facilityGroup,
    this.facility,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FacilitiesSummaryFiViewModel, FacilitiesSummaryFiState>(
      builder: (context, state) {
        final viewModel = context.read<FacilitiesSummaryFiViewModel>();
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: CustomRadioButton<Reference>(
                  options: viewModel.facilityTypeOptions,
                  selectedValue: viewModel.selectedFacilityOption ??
                      viewModel.facilityTypeOptions.first,
                  onChanged: viewModel.changeFacilityTypeOptions,
                  itemBuilder: (context, item, isSelected, isEnabled) =>
                      Text(item.name ?? ''),
                  validator: (value) =>
                      CustomValidator.requiredField(value?.name ?? ""),
                  isRequired: true,
                  scrollDirection: Axis.horizontal,
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
              Row(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Spacer(),
                  Expanded(
                      flex: 2,
                      child: LimitsDropDownField(
                        viewModel: viewModel,
                      )),
                  Expanded(
                      flex: 2,
                      child: LimitDescription(
                        viewModel: viewModel,
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 14.0),
                    child: CustomButton(
                      label: ("facilities.facilitySummary.addFacility".tr()),
                      onPressed: () {
                        Navigator.of(context).pop();
                        router.go(Routes.createFacility,
                            extra: Facility(
                                facilityDescription: Reference(name: "test")));
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
