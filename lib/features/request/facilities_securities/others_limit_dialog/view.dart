import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/view_desktop.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/view_mobile.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";

/// Entry view for creating and managing other limit records.
///
/// Accepts optional reference and facility context information used
/// to initialize the dialog when creating or editing a limit.
class OthersLimitDialogView extends StatelessWidget {
  /// Creates an others limit dialog view.
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

  /// Reference record being created or edited.
  final Reference? reference;

  /// Reference type associated with the record.
  final ReferenceType? referenceType;

  /// Indicates whether the selected limit is a main limit.
  final bool? isMainLimit;

  /// RIM number associated with the selected limit.
  final int? rimNo;

  /// Limit group identifier associated with the selected limit.
  final int? limitGroupId;

  /// Selected limit description identifier.
  final int? selectedDescriptionId;

  /// Limit number associated with the selected facility.
  final String? limitNumber;

  /// Product type value associated with the selected limit.
  final Reference? productTypeValue;

  /// Indicates whether product type selection is enabled.
  final bool? isProductTypeEnabled;

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
          isMainLimit: isMainLimit,
          limitNumber,
          productTypeValue,
          isProductTypeEnabled: isProductTypeEnabled,
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
