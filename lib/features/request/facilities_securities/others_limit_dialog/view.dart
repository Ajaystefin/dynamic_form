// ignore_for_file: public_member_api_docs, sort_constructors_first
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/view_desktop.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/view_mobile.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";

class OthersLimitDialogView extends StatelessWidget {
  final Reference? reference;
  final ReferenceType? referenceType;
  final bool? isMainLimit;
  final int? rimNo;
  final int? limitGroupId;
  final int? selectedDescriptionId;
  final String? limitNumber;
  final Reference? productTypeValue;
  final bool? isProductTypeEnabled;
  const OthersLimitDialogView({
    super.key,
    this.reference,
    this.referenceType,
    this.limitGroupId,
    this.rimNo,
    this.selectedDescriptionId,
    this.isMainLimit,
    this.limitNumber,
    this.productTypeValue,
    this.isProductTypeEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OthersLimitDialogViewModel>(
      create: (context) => OthersLimitDialogViewModel()
        ..init(
          reference,
          referenceType,
          limitGroupId,
          selectedDescriptionId,
          rimNo,
          isMainLimit,
          limitNumber,
          productTypeValue,
          isProductTypeEnabled,
        ),
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          switch (sizingInformation.deviceScreenType) {
            case DeviceScreenType.desktop:
              return const ViewDesktop();

            case DeviceScreenType.tablet:
              return const ViewDesktop();

            case DeviceScreenType.mobile:
              return const ViewMobile();

            default:
              return const ViewDesktop();
          }
        },
      ),
    );
  }
}
