// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:wcas_frontend/core/components/label.dart';
// import 'package:wcas_frontend/core/components/textfield.dart';
// import 'package:wcas_frontend/core/utils/validators.dart';
// import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';

// class Partner extends StatelessWidget {
//   final CustomerInformationViewModel viewModel;

//   const Partner({
//     super.key,
//     required this.viewModel,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return LabelWidget(
//       label: 'ccsys.customerInformation.Partner'.tr(),
//       child: CustomTextField(
//         semanticLabel: 'ccsys.customerInformation.Partner'.tr(),
//         validator: CustomValidator.requiredField,
//         onSaved: (String? value) {
//           // viewModel.customerInformation.industryDescription = value;
//         },
//       ),
//     );
//   }
// }
