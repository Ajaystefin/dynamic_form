// // Flutter & test packages
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// // - Adjust these imports to match your project structure.
// import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/draft_handler.dart';
// import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/model.dart';
// // The file under test:

// void main() {
//   group('RelationshipUtilizationDraftHandler', () {
//     late RelationshipUtilizationDraftHandler handler;

//     setUp(() {
//       handler = RelationshipUtilizationDraftHandler();
//     });

//     testWidgets(
//       'buildDraftData() flushes Form.onSaved and returns latest comments',
//       (tester) async {
//         // --- Arrange ---
//         // Create the VM with a Form GlobalKey.
//         // TODO: Adjust to your real VM constructor/signature.
//         final vm = RelationshipUtilizationViewModel(
//           // Ensure the VM exposes a GlobalKey<FormState> called formKey.
//           //formKey: GlobalKey<FormState>(),
//         );

//         // Start with an initial comments value
//         //vm.comments = 'Initial comments';

//         // Build a minimal widget tree that hosts a Form with that key.
//         // The onSaved writes back to vm.comments (this is what the handler expects).
//         final testApp = MaterialApp(
//           home: Scaffold(
//             body: Form(
//               key: vm.formKey,
//               child: Builder(
//                 builder: (context) {
//                   return Column(
//                     children: [
//                       TextFormField(
//                         initialValue: 'User typed text',
//                         onSaved: (value) {
//                           // Simulate how the real screen writes back into the model.
//                          // vm.comments = value ?? '';
//                         },
//                       ),
//                       // A button we won't tap; handler will call form.save() directly.
//                       ElevatedButton(
//                         onPressed: () => Form.of(context).save(),
//                         child: const Text('Save'),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//         );

//         await tester.pumpWidget(testApp);
//         await tester.pumpAndSettle();

//         // --- Act ---
//         // Calling buildDraftData must trigger vm.formKey.currentState?.save(),
//         // which should fire the TextFormField.onSaved and update vm.comments.
//         final draft = handler.buildDraftData(vm);

//         // --- Assert ---
//        // expect(vm.comments, equals('User typed text'));
//         expect(draft, containsPair('comments', 'User typed text'));
//       },
//     );

//     test('applyDraft() writes comments from data map', () {
//       // --- Arrange ---
//       // TODO: Adjust VM construction to your real API.
//       //final vm = RelationshipUtilizationViewModel(formKey: GlobalKey<FormState>());
//       //vm.comments = 'Before applyDraft';

//       // final data = <String, dynamic>{
//       //   'comments': 'Restored from draft',
//       // };

//       // --- Act ---
//       //handler.applyDraft(vm, data);

//       // --- Assert ---
//       //expect(vm.comments, equals('Restored from draft'));
//     });

//     test('applyDraft() keeps existing comments if data["comments"] is null',
// () {
//       // --- Arrange ---
//       // TODO: Adjust VM construction to your real API.
//       //final vm = RelationshipUtilizationViewModel(formKey: GlobalKey<FormState>());
//       //vm.comments = 'Stay as-is';

//       // final data = <String, dynamic>{
//       //   'comments': null,
//       // };

//       // --- Act ---
//       //handler.applyDraft(vm, data);

//       // --- Assert ---
//       //expect(vm.comments, equals('Stay as-is'));
//     });
//   });
// }
void main() {}
