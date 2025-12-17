// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:wcas_frontend/core/components/label.dart';
// import 'package:wcas_frontend/core/components/textfield.dart';
// import 'package:wcas_frontend/core/utils/validators.dart';
// import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';

// class LegalStatus extends StatelessWidget {
//   final CustomerInformationViewModel viewModel;

//   const LegalStatus({
//     super.key,
//     required this.viewModel,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return LabelWidget(
//       label: 'ccsys.customerInformation.legalStatus'.tr(),
//       child: CustomTextField(
//         semanticLabel: 'ccsys.customerInformation.legalStatus'.tr(),
//         initialValue: viewModel.customerInformation.legalStatus,
//         validator: CustomValidator.requiredField,
//         inputFormatters: [
//           FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
//         ],
//         onSaved: (String? legalStatus) {
//           viewModel.customerInformation.legalStatus = legalStatus;
//         },
//       ),
//     );
//   }
// }
