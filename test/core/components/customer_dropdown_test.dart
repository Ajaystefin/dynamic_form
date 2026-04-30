import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/customer_dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";

extension MockTranslationExtension on String {
  String tr() => this;
}

final navigatorKey = GlobalKey<NavigatorState>();

class TestApp extends StatelessWidget {
  const TestApp({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      locale: const Locale("en"),
      home: MediaQuery(
        data: const MediaQueryData(size: Size(1400, 900)),
        child: Scaffold(body: child),
      ),
    );
  }
}

void main() {
  group("CustomCustomerDropdown – extended coverage", () {
    late List<Customer> customers;
    Customer? changedCustomer;

    setUp(() {
      customers = [
        Customer(customerRimNo: 12345, customerName: "Customer A"),
        Customer(customerRimNo: 67890, customerName: "Customer B"),
      ];
      changedCustomer = null;
    });

    /// ------------------------------------------------------
    /// GROUP APPLICATION PATH
    /// ------------------------------------------------------
    testWidgets("shows CustomDropdown when group application", (tester) async {
      Globals.request = Request(groupId: 1, customers: customers);

      await tester.pumpWidget(
        TestApp(
          child: CustomCustomerDropdown(
            customerList: customers,
            selectedCustomer: customers.first,
            onCustomerChange: (c) => changedCustomer = c,
            onRefresh: () {},
          ),
        ),
      );

      expect(find.byType(CustomDropdown<Customer>), findsOneWidget);
      expect(find.byType(CustomTextField), findsNothing);
    });

    /// ✅ COVER itemBuilder
    testWidgets("dropdown itemBuilder renders customerRimNo", (tester) async {
      Globals.request = Request(groupId: 1, customers: customers);

      await tester.pumpWidget(
        TestApp(
          child: CustomCustomerDropdown(
            customerList: customers,
            selectedCustomer: customers.first,
            onCustomerChange: (c) => changedCustomer = c,
            onRefresh: () {},
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.text("12345"));
      await tester.pumpAndSettle();

      // ✅ itemBuilder executed
      expect(find.text("67890"), findsOneWidget);

      // ✅ Safely close popup
      navigatorKey.currentState?.pop();
      await tester.pumpAndSettle();
    });

    /// ✅ COVER onCustomerChange
    testWidgets("selecting customer triggers callback", (tester) async {
      Globals.request = Request(groupId: 1, customers: customers);

      await tester.pumpWidget(
        TestApp(
          child: CustomCustomerDropdown(
            customerList: customers,
            selectedCustomer: customers.first,
            onCustomerChange: (c) => changedCustomer = c,
            onRefresh: () {},
          ),
        ),
      );

      await tester.tap(find.text("12345"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("67890"));
      await tester.pumpAndSettle();

      navigatorKey.currentState?.pop();

      expect(changedCustomer?.customerRimNo, 67890);
    });

    /// ------------------------------------------------------
    /// NON‑GROUP APPLICATION PATH
    /// ------------------------------------------------------
    testWidgets("shows readonly text field when not group application",
        (tester) async {
      Globals.request = Request(groupId: null, customers: customers);

      await tester.pumpWidget(
        TestApp(
          child: CustomCustomerDropdown(
            selectedCustomer: customers.first,
            onCustomerChange: (_) {},
            onRefresh: () {},
          ),
        ),
      );

      final field =
          tester.widget<CustomTextField>(find.byType(CustomTextField));

      expect(field.readOnly, true);
      expect(field.filled, true);
    });

    /// ------------------------------------------------------
    /// EDGE CASES
    /// ------------------------------------------------------
    testWidgets("handles null selectedCustomer gracefully", (tester) async {
      Globals.request = Request(groupId: 1, customers: customers);

      await tester.pumpWidget(
        TestApp(
          child: CustomCustomerDropdown(
            selectedCustomer: null,
            onCustomerChange: (_) {},
            onRefresh: () {},
          ),
        ),
      );

      expect(find.byType(CustomDropdown<Customer>), findsOneWidget);
    });

    testWidgets("handles empty customer list", (tester) async {
      Globals.request = Request(groupId: 1, customers: []);

      await tester.pumpWidget(
        TestApp(
          child: CustomCustomerDropdown(
            selectedCustomer: null,
            onCustomerChange: (_) {},
            onRefresh: () {},
          ),
        ),
      );

      expect(find.byType(CustomDropdown<Customer>), findsOneWidget);
    });

    testWidgets("handles null Globals.request", (tester) async {
      Globals.request = null;

      await tester.pumpWidget(
        TestApp(
          child: CustomCustomerDropdown(
            selectedCustomer: null,
            onCustomerChange: (_) {},
            onRefresh: () {},
          ),
        ),
      );

      expect(find.byType(CustomTextField), findsOneWidget);
      expect(find.byType(CustomDropdown<Customer>), findsNothing);
    });
  });
}
