// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:wcas_frontend/core/components/dropdown_textbox.dart';
// import 'package:wcas_frontend/core/components/dropdown/model.dart';

// void main() {
//   group('CustomDropdownTextbox', () {
//     testWidgets('emits map on text change after selecting option', (tester)
// async {
//       Map<String, dynamic>? emitted;
//       final controller = TextEditingController();

//       await tester.pumpWidget(MaterialApp(
//         home: Scaffold(
//           body: CustomDropdownTextbox(
//             controller: controller,
//             dropdownLabel: 'Field',
//             textFieldLabel: 'Value',
//             options: [
//               CustomDropdownItem(label: 'Key1', value: 'key1'),
//               CustomDropdownItem(label: 'Key2', value: 'key2'),
//             ],
//             onChanged: (m) => emitted = m,
//           ),
//         ),
//       ));

//       // Open dropdown and select Key2
//       await tester.tap(find.byIcon(Icons.arrow_drop_down));
//       await tester.pumpAndSettle();
//       await tester.tap(find.text('Key2').last);
//       await tester.pumpAndSettle();

//       // Type in the text field
//       await tester.enterText(find.byType(TextField), 'hello');
//       await tester.pump();

//       expect(emitted, isNotNull);
//       expect(emitted!['key2'], 'hello');
//     });
//   });
// }
