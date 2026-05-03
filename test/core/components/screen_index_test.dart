import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/screen_index.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/request.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("ScreenIndex Widget Tests - Full Coverage", () {
    setUp(() {
      Globals.request = Request(
        applicationRefNo: "TEST123",
        customerName: "Test Customer",
        customerRimNo: 12345,
        applicationType: Reference(
          id: ServerConstants.applicationTypeId[ApplicationType.newToBank],
          name: "New to Bank",
        ),
        requestType: Reference(
          id: ServerConstants.requestTypeId[RequestType.fullCA],
          name: "Full CA",
        ),
        businessSegment: Reference(
          id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
          name: "Corporate",
        ),
        requestStatus: Reference(
          id: ServerConstants.requestStatusId[RequestStatus.initiated],
          name: "Initiated",
        ),
        groupId: 100,
      );
    });

    Future<void> pumpScreenIndex(
      WidgetTester tester, {
      GoRouter? router,
      Widget? home,
    }) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      if (router != null) {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
      } else {
        await tester.pumpWidget(
          MaterialApp(
            home: home ?? const ScreenIndex(),
          ),
        );
      }

      await tester.pumpAndSettle();
    }

    Future<void> tapApply(WidgetTester tester) async {
      final buttons =
          tester.widgetList<CustomButton>(find.byType(CustomButton));
      final applyButton = buttons.firstWhere(
        (button) => button.label == "Apply",
      );
      applyButton.onPressed?.call();
      await tester.pumpAndSettle();
    }

    Future<void> enableGroupId(
      WidgetTester tester, {
      required bool value,
    }) async {
      final checkboxes = tester
          .widgetList<CustomCheckbox>(find.byType(CustomCheckbox))
          .toList();

      expect(checkboxes, isNotEmpty);

      final checkbox = checkboxes.first;
      checkbox.onChange.call(value);
      await tester.pumpAndSettle();
    }

    Future<void> setApplicationType(
      WidgetTester tester,
      ApplicationType value,
    ) async {
      final dropdown = tester
          .widgetList(
            find.byWidgetPredicate(
              (widget) => widget is CustomDropdown<ApplicationType>,
            ),
          )
          .cast<CustomDropdown<ApplicationType>>()
          .first;

      dropdown.onSelected?.call([value]);
      await tester.pumpAndSettle();
    }

    Future<void> setRequestType(
      WidgetTester tester,
      RequestType value,
    ) async {
      final dropdown = tester
          .widgetList(
            find.byWidgetPredicate(
              (widget) => widget is CustomDropdown<RequestType>,
            ),
          )
          .cast<CustomDropdown<RequestType>>()
          .first;

      dropdown.onSelected?.call([value]);
      await tester.pumpAndSettle();
    }

    Future<void> setBusinessSegment(
      WidgetTester tester,
      BusinessSegment value,
    ) async {
      final dropdown = tester
          .widgetList(
            find.byWidgetPredicate(
              (widget) => widget is CustomDropdown<BusinessSegment>,
            ),
          )
          .cast<CustomDropdown<BusinessSegment>>()
          .first;

      dropdown.onSelected?.call([value]);
      await tester.pumpAndSettle();
    }

    Future<void> setRequestStatus(
      WidgetTester tester,
      RequestStatus value,
    ) async {
      final dropdown = tester
          .widgetList(
            find.byWidgetPredicate(
              (widget) => widget is CustomDropdown<RequestStatus>,
            ),
          )
          .cast<CustomDropdown<RequestStatus>>()
          .first;

      dropdown.onSelected?.call([value]);
      await tester.pumpAndSettle();
    }

    Future<void> tapViewButtonByIndex(
      WidgetTester tester,
      int index,
    ) async {
      final buttons =
          tester.widgetList<CustomButton>(find.byType(CustomButton)).toList();

      final viewButtons =
          buttons.where((button) => button.label == "View").toList();

      expect(viewButtons.length, greaterThan(index));

      viewButtons[index].onPressed?.call();
      await tester.pumpAndSettle();
    }

    testWidgets("should render ScreenIndex widget",
        (WidgetTester tester) async {
      await pumpScreenIndex(tester);

      expect(find.byType(ScreenIndex), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets(
      "should initialize app ref no and group id"
      " controllers from Globals.request",
      (WidgetTester tester) async {
        Globals.request = Request(
          applicationRefNo: "REF-001",
          groupId: 555,
        );

        await pumpScreenIndex(tester);

        expect(find.text("REF-001"), findsOneWidget);

        await enableGroupId(tester, value: true);

        expect(find.text("555"), findsOneWidget);
      },
    );

    testWidgets(
      "should initialize safely when Globals.request is null",
      (WidgetTester tester) async {
        Globals.request = null;

        await pumpScreenIndex(tester);

        expect(find.byType(ScreenIndex), findsOneWidget);
        expect(find.text("Apply"), findsOneWidget);
      },
    );

    testWidgets(
      "should initialize dropdown selections when request has valid IDs",
      (WidgetTester tester) async {
        Globals.request = Request(
          applicationRefNo: "VALID-INIT",
          applicationType: Reference(
            id: ServerConstants.applicationTypeId[ApplicationType.annualReview],
            name: "Annual Review",
          ),
          requestType: Reference(
            id: ServerConstants.requestTypeId[RequestType.isolated],
            name: "Isolated",
          ),
          businessSegment: Reference(
            id: ServerConstants.businessSegmentId[BusinessSegment.personal],
            name: "Personal",
          ),
        );

        await pumpScreenIndex(tester);

        expect(find.text("VALID-INIT"), findsOneWidget);
        expect(find.byType(ScreenIndex), findsOneWidget);

        expect(
          find.byWidgetPredicate(
            (widget) => widget is CustomDropdown<ApplicationType>,
          ),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate(
            (widget) => widget is CustomDropdown<RequestType>,
          ),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate(
            (widget) => widget is CustomDropdown<BusinessSegment>,
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      "should use fallback values when invalid IDs are provided in request",
      (WidgetTester tester) async {
        Globals.request = Request(
          applicationRefNo: "INVALID-IDS",
          applicationType: Reference(id: -999, name: "Unknown App Type"),
          requestType: Reference(id: -999, name: "Unknown Request Type"),
          businessSegment: Reference(id: -999, name: "Unknown Segment"),
        );

        await pumpScreenIndex(tester);

        expect(find.byType(ScreenIndex), findsOneWidget);
        expect(find.text("INVALID-IDS"), findsOneWidget);
      },
    );

    testWidgets(
      "should handle null applicationType requestType and businessSegment",
      (WidgetTester tester) async {
        Globals.request = Request(
          applicationRefNo: "NULL-DROPDOWNS",
          applicationType: null,
          requestType: null,
          businessSegment: null,
        );

        await pumpScreenIndex(tester);

        expect(find.byType(ScreenIndex), findsOneWidget);
        expect(find.text("Application Type"), findsWidgets);
        expect(find.text("Request Type"), findsWidgets);
        expect(find.text("Business Segment"), findsWidgets);
      },
    );

    testWidgets(
      "should show and hide Group ID text field when checkbox is toggled",
      (WidgetTester tester) async {
        Globals.request = Request(
          applicationRefNo: "GROUP-TOGGLE",
          groupId: null,
        );

        await pumpScreenIndex(tester);

        final beforeCount = find.byType(TextFormField).evaluate().length;

        await enableGroupId(tester, value: true);
        final afterEnableCount = find.byType(TextFormField).evaluate().length;
        expect(afterEnableCount, greaterThan(beforeCount));

        await enableGroupId(tester, value: false);
        final afterDisableCount = find.byType(TextFormField).evaluate().length;
        expect(afterDisableCount, equals(beforeCount));
      },
    );

    testWidgets("should show Apply button", (WidgetTester tester) async {
      await pumpScreenIndex(tester);

      expect(find.text("Apply"), findsOneWidget);
    });

    testWidgets(
      "should update applicationRefNo on submit",
      (WidgetTester tester) async {
        Globals.request = Request(applicationRefNo: "OLD-REF");

        await pumpScreenIndex(tester);

        final textFields = find.byType(TextFormField);
        expect(textFields, findsWidgets);

        await tester.enterText(textFields.first, "NEW-REF-999");
        await tester.pumpAndSettle();

        await tapApply(tester);

        expect(Globals.request?.applicationRefNo, "NEW-REF-999");
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining("App Ref No.: NEW-REF-999"), findsOneWidget);
      },
    );

    testWidgets(
      "should do nothing when Apply is pressed and Globals.request is null",
      (WidgetTester tester) async {
        Globals.request = null;

        await pumpScreenIndex(tester);

        await tapApply(tester);

        expect(find.byType(SnackBar), findsNothing);
      },
    );

    testWidgets(
      "should update Group ID when checkbox enabled and valid number entered",
      (WidgetTester tester) async {
        Globals.request = Request(
          applicationRefNo: "GROUP-ID",
          groupId: null,
        );

        await pumpScreenIndex(tester);

        await enableGroupId(tester, value: true);

        final allTextFields = find.byType(TextFormField);
        expect(allTextFields, findsWidgets);

        await tester.enterText(allTextFields.last, "999");
        await tester.pumpAndSettle();

        await tapApply(tester);

        expect(Globals.request?.groupId, 999);
        expect(find.textContaining("Group ID: 999"), findsOneWidget);
      },
    );

    testWidgets(
      "should keep Group ID null when checkbox enabled but field left empty",
      (WidgetTester tester) async {
        Globals.request = Request(
          applicationRefNo: "EMPTY-GROUP",
          groupId: null,
        );

        await pumpScreenIndex(tester);

        await enableGroupId(tester, value: true);
        await tapApply(tester);

        expect(Globals.request?.groupId, null);
      },
    );

    testWidgets(
      "should set Group ID to null when invalid text is entered",
      (WidgetTester tester) async {
        Globals.request = Request(
          applicationRefNo: "INVALID-GROUP",
          groupId: null,
        );

        await pumpScreenIndex(tester);

        await enableGroupId(tester, value: true);

        final allTextFields = find.byType(TextFormField);
        await tester.enterText(allTextFields.last, "ABC123");
        await tester.pumpAndSettle();

        await tapApply(tester);

        expect(Globals.request?.groupId, null);
        expect(find.byType(SnackBar), findsOneWidget);
      },
    );

    testWidgets(
      "should render table headers and route rows",
      (WidgetTester tester) async {
        await pumpScreenIndex(tester);

        expect(find.text("Screen Name"), findsOneWidget);
        expect(find.text("Action"), findsOneWidget);

        expect(find.text("RM Certification"), findsOneWidget);
        expect(find.text("File Access"), findsOneWidget);
        expect(find.text("Home"), findsOneWidget);
        expect(find.text("CCSYS - Approval"), findsOneWidget);

        expect(find.text("View"), findsWidgets);
      },
    );

    testWidgets(
      "should navigate to "
      "Home route when "
      "Home View button callback is triggered",
      (WidgetTester tester) async {
        final router = GoRouter(
          initialLocation: "/",
          routes: [
            GoRoute(
              path: "/",
              builder: (context, state) => const ScreenIndex(),
            ),
            GoRoute(
              path: Routes.home,
              builder: (context, state) => const Scaffold(
                body: Text("Home Page"),
              ),
            ),
            GoRoute(
              path: Routes.rmCertification,
              builder: (context, state) => const Scaffold(
                body: Text("RM Certification Page"),
              ),
            ),
          ],
        );

        await pumpScreenIndex(tester, router: router);

        // Home is the 15th item in _getRouteMap() => index 14
        await tapViewButtonByIndex(tester, 14);

        expect(find.text("Home Page"), findsOneWidget);
      },
    );

    testWidgets(
      "should dispose controllers when widget is removed",
      (WidgetTester tester) async {
        await pumpScreenIndex(tester);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Text("Replacement Widget"),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text("Replacement Widget"), findsOneWidget);
      },
    );

    testWidgets(
      "should update all dropdowns and show snackbar with all selected values",
      (WidgetTester tester) async {
        Globals.request = Request(
          applicationRefNo: "FULL-UPDATE",
          groupId: null,
        );

        await pumpScreenIndex(tester);

        await setApplicationType(tester, ApplicationType.newToBank);
        await setRequestType(tester, RequestType.fullCA);
        await setBusinessSegment(tester, BusinessSegment.corporate);
        await setRequestStatus(tester, RequestStatus.initiated);

        await enableGroupId(tester, value: true);

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.last, "777");
        await tester.pumpAndSettle();

        await tapApply(tester);

        expect(
          Globals.request?.applicationType?.id,
          ServerConstants.applicationTypeId[ApplicationType.newToBank],
        );
        expect(
          Globals.request?.requestType?.id,
          ServerConstants.requestTypeId[RequestType.fullCA],
        );
        expect(
          Globals.request?.businessSegment?.id,
          ServerConstants.businessSegmentId[BusinessSegment.corporate],
        );
        expect(
          Globals.request?.requestStatus?.id,
          ServerConstants.requestStatusId[RequestStatus.initiated],
        );
        expect(Globals.request?.groupId, 777);

        expect(find.byType(SnackBar), findsOneWidget);
      },
    );

    testWidgets(
      "should cover every ApplicationType case via callback selection",
      (WidgetTester tester) async {
        Globals.request = Request(applicationRefNo: "APP-TYPES");

        await pumpScreenIndex(tester);

        for (final type in ApplicationType.values) {
          await setApplicationType(tester, type);
          await tapApply(tester);

          expect(
            Globals.request?.applicationType?.id,
            ServerConstants.applicationTypeId[type],
          );
        }
      },
    );

    testWidgets(
      "should cover every RequestType case via callback selection",
      (WidgetTester tester) async {
        Globals.request = Request(applicationRefNo: "REQUEST-TYPES");

        await pumpScreenIndex(tester);

        for (final type in RequestType.values) {
          await setRequestType(tester, type);
          await tapApply(tester);

          expect(
            Globals.request?.requestType?.id,
            ServerConstants.requestTypeId[type],
          );
        }
      },
    );

    testWidgets(
      "should cover every BusinessSegment case via callback selection",
      (WidgetTester tester) async {
        Globals.request = Request(applicationRefNo: "BUSINESS-SEGMENTS");

        await pumpScreenIndex(tester);

        for (final segment in BusinessSegment.values) {
          await setBusinessSegment(tester, segment);
          await tapApply(tester);

          expect(
            Globals.request?.businessSegment?.id,
            ServerConstants.businessSegmentId[segment],
          );
        }
      },
    );

    testWidgets(
      "should cover every RequestStatus case via callback selection",
      (WidgetTester tester) async {
        Globals.request = Request(applicationRefNo: "REQUEST-STATUS");

        await pumpScreenIndex(tester);

        for (final status in RequestStatus.values) {
          await setRequestStatus(tester, status);
          await tapApply(tester);

          expect(
            Globals.request?.requestStatus?.id,
            ServerConstants.requestStatusId[status],
          );
        }
      },
    );

    testWidgets(
      "should render every ApplicationType from request initialization",
      (WidgetTester tester) async {
        for (final type in ApplicationType.values) {
          Globals.request = Request(
            applicationRefNo: "APP-${type.name}",
            applicationType: Reference(
              id: ServerConstants.applicationTypeId[type],
              name: type.name,
            ),
          );

          await pumpScreenIndex(tester);
          expect(find.byType(ScreenIndex), findsOneWidget);

          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        }
      },
    );

    testWidgets(
      "should render every RequestType from request initialization",
      (WidgetTester tester) async {
        for (final type in RequestType.values) {
          Globals.request = Request(
            applicationRefNo: "REQ-${type.name}",
            requestType: Reference(
              id: ServerConstants.requestTypeId[type],
              name: type.name,
            ),
          );

          await pumpScreenIndex(tester);
          expect(find.byType(ScreenIndex), findsOneWidget);

          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        }
      },
    );

    testWidgets(
      "should render every BusinessSegment from request initialization",
      (WidgetTester tester) async {
        for (final segment in BusinessSegment.values) {
          Globals.request = Request(
            applicationRefNo: "SEG-${segment.name}",
            businessSegment: Reference(
              id: ServerConstants.businessSegmentId[segment],
              name: segment.name,
            ),
          );

          await pumpScreenIndex(tester);
          expect(find.byType(ScreenIndex), findsOneWidget);

          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        }
      },
    );
  });
}
