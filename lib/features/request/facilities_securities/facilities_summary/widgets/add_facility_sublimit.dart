import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/fields/limit_type.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/fields/limit_description.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/state.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class AddFacilitySubLimitBox extends StatelessWidget {
  final FacilityGroup? facilityGroup;
  final Facility? facility;
  final String? label;
  final int? limitGroup;
  final bool? limitType;
  final int? selectedRim;
  final bool? isMainLimit;
  final String? limitNumber;
  final int? proposedLimit;
  const AddFacilitySubLimitBox({
    super.key,
    this.facilityGroup,
    this.facility,
    this.label,
    this.limitGroup,
    this.limitType,
    this.selectedRim,
    this.isMainLimit,
    this.limitNumber, 
    this.proposedLimit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FacilitiesSummaryViewModel, FacilitiesSummaryState>(
      builder: (context, state) {
        final viewModel = context.read<FacilitiesSummaryViewModel>();
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              LabelWidget(
                label: 'facilities.createFacility.productType'.tr(),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CustomRadioButton<Reference>(
                    options: viewModel.productTypeOptions,
                    selectedValue: viewModel.selectedProductTypeOption ??
                        viewModel.productTypeOptions.first,
                    onChanged: viewModel.changeProductTypeOptions,
                    itemBuilder: (context, item, isSelected, isEnabled) =>
                        Text(item.name ?? ''),
                    validator: (value) =>
                        CustomValidator.requiredField(value?.name ?? ""),
                    isRequired: true,
                    scrollDirection: Axis.horizontal,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
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
                      child: LimitTypes(
                        viewModel: viewModel,
                      )),
                  Expanded(
                      flex: 2,
                      child: LimitDescriptions(
                        viewModel: viewModel,
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 14.0),
                    child: CustomButton(
                      label: label ??
                          "facilities.facilitySummary.addFacility".tr(),
                      onPressed:
                          (viewModel.facility.facilityDescription != null)
                              ? () {
                                  router.go(
                                    Routes.createFacility,
                                    extra: CreateFacilityArgs(
                                      facility: Facility(
                                          facilityDescription: viewModel
                                              .facility.facilityDescription,
                                          limitDescription: viewModel.facility
                                              .facilityDescription?.name,
                                          limitGroup: limitGroup ?? 11312,
                                          limitType: limitType ?? false,
                                          rimNo: selectedRim,
                                          proposedLimit: proposedLimit,
                                          limitNumber: limitNumber,
                                          isMainLimit: isMainLimit),
                                      showCreateFacilityForm: true,
                                    ),
                                  ); //  after API integration pass the facility from this class instead of new object
                                }
                              : null,
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
