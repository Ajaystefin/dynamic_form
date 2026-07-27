import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/components/selection_table.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/customer.dart";

class MockCustomer extends Mock implements Customer {}

class TestAssetLoader extends AssetLoader {
  const TestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "requestInformation": {
        "createRequest": {
          "customerRim": "RIM",
          "customerName": "Name",
          "groupId": "Group ID",
          "groupName": "Group",
        },
      },
      "common": {
        "currencyValue": "Value",
      },
    };
  }
}

void main() {
  late ValueNotifier<Customer?> selectedCustomer;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/shared_preferences"),
      (MethodCall methodCall) async {
        if (methodCall.method == "getAll") {
          return <String, Object>{};
        }
        return null;
      },
    );

    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    selectedCustomer = ValueNotifier<Customer?>(null);
  });

  tearDown(() {
    selectedCustomer.dispose();
  });

  Future<void> setLargeScreen(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1200));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
  }

  Widget buildWidget({
    required List<Customer?> customers,
    required bool isGroupNameSelection,
    required LoadingStatus loaderStatus,
    ValueNotifier<Customer?>? notifier,
  }) {
    return EasyLocalization(
      supportedLocales: const [Locale("en")],
      fallbackLocale: const Locale("en"),
      startLocale: const Locale("en"),
      path: "test/translations",
      assetLoader: const TestAssetLoader(),
      child: MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(1600, 1200),
            textScaler: TextScaler.linear(0.75),
          ),
          child: Scaffold(
            body: SizedBox(
              width: 1600,
              height: 1200,
              child: SelectionTable(
                customers: customers,
                selectedCustomer: notifier ?? selectedCustomer,
                isGroupNameSelection: isGroupNameSelection,
                loaderStatus: loaderStatus,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Customer createCustomer({
    int customerRimNo = 1001,
    String preferredName = "John Customer",
    String firstName = "Azeem",
     String middleName = "",
    String lastName = "Customer",
  }) {
    final customer = MockCustomer();

    when(() => customer.customerRimNo).thenReturn(customerRimNo);
    when(() => customer.preferredName).thenReturn(preferredName);
     when(() => customer.firstName).thenReturn(firstName);
      when(() => customer.middleName).thenReturn(middleName);
       when(() => customer.lastName).thenReturn(lastName);
       
 when(() => customer.concatCustomerFullName).thenReturn(
    [firstName, middleName, lastName]
        .where((e) => e.trim().isNotEmpty)
        .join(" "),
  );
  when(() => customer.displayRIMName).thenReturn(preferredName);
    when(() => customer.groups).thenReturn(null);

    return customer;
  }

  group("SelectionTable", () {
    testWidgets("shows loading indicator when loaderStatus is loading",
        (tester) async {
      await setLargeScreen(tester);

      await tester.pumpWidget(
        buildWidget(
          customers: const [],
          isGroupNameSelection: false,
          loaderStatus: LoadingStatus.loading,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(SelectionTable), findsOneWidget);
    });

    testWidgets("renders loaded table for empty customer list", (tester) async {
      await setLargeScreen(tester);

      await tester.pumpWidget(
        buildWidget(
          customers: const [],
          isGroupNameSelection: false,
          loaderStatus: LoadingStatus.loaded,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SelectionTable), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets("renders customer rim and customer name values",
        (tester) async {
      await setLargeScreen(tester);

     
final customer = createCustomer(
  firstName: " Azeem",
  middleName:  " ",
  lastName: " Customer",
);
 

      await tester.pumpWidget(
        buildWidget(
          customers: [customer],
          isGroupNameSelection: false,
          loaderStatus: LoadingStatus.loaded,
        ),
      );
      await tester.pumpAndSettle();
 debugDumpApp();
      expect(find.text("1001"), findsOneWidget);
      expect(find.textContaining(customer.concatCustomerFullName), findsOneWidget);
    });

    testWidgets("selects customer when radio button is tapped", (tester) async {
      await setLargeScreen(tester);

      final customer = createCustomer(
        customerRimNo: 2001,
        firstName: " Selected",
        lastName: " Customer",
     
      );

      await tester.pumpWidget(
        buildWidget(
          customers: [customer],
          isGroupNameSelection: false,
          loaderStatus: LoadingStatus.loaded,
        ),
      );
      await tester.pumpAndSettle();

      expect(selectedCustomer.value, isNull);

      final radioFinder = find.byWidgetPredicate(
        (widget) => widget is Radio<Customer?>,
      );

      expect(radioFinder, findsOneWidget);

      await tester.tap(radioFinder);
      await tester.pumpAndSettle();

      expect(selectedCustomer.value, same(customer));
    });

    testWidgets("radio button is checked when selectedCustomer has value",
        (tester) async {
      await setLargeScreen(tester);

      final customer = createCustomer(
        customerRimNo: 3001,
        firstName: "Already",
        lastName: "Selected",
      );

      final notifier = ValueNotifier<Customer?>(customer);

      await tester.pumpWidget(
        buildWidget(
          customers: [customer],
          isGroupNameSelection: false,
          loaderStatus: LoadingStatus.loaded,
          notifier: notifier,
        ),
      );
      await tester.pumpAndSettle();

      final radio = tester.widget<Radio<Customer?>>(
        find.byWidgetPredicate(
          (widget) => widget is Radio<Customer?>,
        ),
      );

      expect(radio.groupValue, same(customer));
      expect(radio.value, same(customer));

      notifier.dispose();
    });

    testWidgets("updates table when selectedCustomer notifier changes",
        (tester) async {
      await setLargeScreen(tester);

      final customerOne = createCustomer(
        customerRimNo: 4001,
        firstName: "Customer",
        lastName: "One",
      );

      final customerTwo = createCustomer(
        customerRimNo: 4002,
        firstName: "Customer",
        lastName: "Two",
      );

      await tester.pumpWidget(
        buildWidget(
          customers: [customerOne, customerTwo],
          isGroupNameSelection: false,
          loaderStatus: LoadingStatus.loaded,
        ),
      );
      await tester.pumpAndSettle();

      expect(selectedCustomer.value, isNull);

      selectedCustomer.value = customerTwo;
      await tester.pumpAndSettle();

      final radios = tester.widgetList<Radio<Customer?>>(
        find.byWidgetPredicate(
          (widget) => widget is Radio<Customer?>,
        ),
      );

      expect(radios.length, 2);
      expect(radios.last.groupValue, same(customerTwo));
    });

    testWidgets("renders multiple customers", (tester) async {
      await setLargeScreen(tester);

      final customerOne = createCustomer(
        customerRimNo: 5001,
        firstName: "First",
        lastName: " Customer",
     
      );

      final customerTwo = createCustomer(
        customerRimNo: 5002,
        firstName: "Second",
        lastName: " Customer",
      );

      await tester.pumpWidget(
        buildWidget(
          customers: [customerOne, customerTwo],
          isGroupNameSelection: false,
          loaderStatus: LoadingStatus.loaded,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("5001"), findsWidgets);
      expect(find.text(customerOne.concatCustomerFullName), findsOneWidget);
      expect(find.text("5002"), findsWidgets);
      expect(find.text(customerTwo.concatCustomerFullName), findsOneWidget);

      expect(
        find.byWidgetPredicate((widget) => widget is Radio<Customer?>),
        findsNWidgets(2),
      );
    });

    testWidgets("renders safely when customer item is null", (tester) async {
      await setLargeScreen(tester);

      await tester.pumpWidget(
        buildWidget(
          customers: const [null],
          isGroupNameSelection: false,
          loaderStatus: LoadingStatus.loaded,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SelectionTable), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) => widget is Radio<Customer?>),
        findsOneWidget,
      );
    });

    testWidgets("does not update selectedCustomer when null radio value tapped",
        (tester) async {
      await setLargeScreen(tester);

      await tester.pumpWidget(
        buildWidget(
          customers: const [null],
          isGroupNameSelection: false,
          loaderStatus: LoadingStatus.loaded,
        ),
      );
      await tester.pumpAndSettle();

      final radioFinder = find.byWidgetPredicate(
        (widget) => widget is Radio<Customer?>,
      );

      expect(radioFinder, findsOneWidget);

      await tester.tap(radioFinder);
      await tester.pumpAndSettle();

      expect(selectedCustomer.value, isNull);
    });

    testWidgets("renders group selection mode safely with null group",
        (tester) async {
      await setLargeScreen(tester);

      final customer = createCustomer(
        customerRimNo: 6001,
        preferredName: "Group Mode Customer",
      );

      await tester.pumpWidget(
        buildWidget(
          customers: [customer],
          isGroupNameSelection: true,
          loaderStatus: LoadingStatus.loaded,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SelectionTable), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) => widget is Radio<Customer?>),
        findsOneWidget,
      );
    });

    testWidgets("renders group selection mode with null customer",
        (tester) async {
      await setLargeScreen(tester);

      await tester.pumpWidget(
        buildWidget(
          customers: const [null],
          isGroupNameSelection: true,
          loaderStatus: LoadingStatus.loaded,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SelectionTable), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) => widget is Radio<Customer?>),
        findsOneWidget,
      );
    });

    testWidgets("can select customer in group selection mode", (tester) async {
      await setLargeScreen(tester);

      final customer = createCustomer(
        customerRimNo: 7001,
        preferredName: "Group Select Customer",
      );

      await tester.pumpWidget(
        buildWidget(
          customers: [customer],
          isGroupNameSelection: true,
          loaderStatus: LoadingStatus.loaded,
        ),
      );
      await tester.pumpAndSettle();

      final radioFinder = find.byWidgetPredicate(
        (widget) => widget is Radio<Customer?>,
      );

      await tester.tap(radioFinder);
      await tester.pumpAndSettle();

      expect(selectedCustomer.value, same(customer));
    });

    testWidgets("loading state does not render radios", (tester) async {
      await setLargeScreen(tester);

      final customer = createCustomer();

      await tester.pumpWidget(
        buildWidget(
          customers: [customer],
          isGroupNameSelection: false,
          loaderStatus: LoadingStatus.loading,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) => widget is Radio<Customer?>),
        findsNothing,
      );
    });
  });
}
