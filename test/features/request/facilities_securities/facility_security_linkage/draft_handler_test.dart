import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/draft_handler.dart";
import "package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/state.dart";

class MockFacilitySecurityLinkageViewModel extends Mock
    implements FacilitySecurityLinkageViewModel {}

class MockFacilitySecurityLinkageState extends Mock
    implements FacilitySecurityLinkageState {}

void main() {
  late FacilitySecurityLinkageDraftHandler handler;
  late MockFacilitySecurityLinkageViewModel vm;
  late MockFacilitySecurityLinkageState state;

  String? securityNumberFilter;
  String? securityTypeFilter;

  setUpAll(() {
    registerFallbackValue(MockFacilitySecurityLinkageState());
    registerFallbackValue(FilterType.securityNumber);
  });

  setUp(() {
    handler = FacilitySecurityLinkageDraftHandler();
    vm = MockFacilitySecurityLinkageViewModel();
    state = MockFacilitySecurityLinkageState();

    securityNumberFilter = null;
    securityTypeFilter = null;

    when(() => vm.securityNumberFilter).thenAnswer(
      (_) => securityNumberFilter,
    );

    when(() => vm.securityNumberFilter = any()).thenAnswer((invocation) {
      securityNumberFilter = invocation.positionalArguments.first as String?;
      return null;
    });

    when(() => vm.securityTypeFilter).thenAnswer(
      (_) => securityTypeFilter,
    );

    when(() => vm.securityTypeFilter = any()).thenAnswer((invocation) {
      securityTypeFilter = invocation.positionalArguments.first as String?;
      return null;
    });

    when(() => vm.state).thenReturn(state);
    when(() => state.copyWith()).thenReturn(state);
    when(() => vm.emit(any())).thenReturn(null);

    when(
      () => vm.onFilter(
        value: any(named: "value"),
        filterType: any(named: "filterType"),
      ),
    ).thenAnswer((_) async {});
  });

  group("FacilitySecurityLinkageDraftHandler.buildDraftData", () {
    testWidgets(
      "calls form save and returns JSON-safe filter payload",
      (tester) async {
        final formKey = GlobalKey<FormState>();

        when(() => vm.formKey).thenReturn(formKey);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: "SEC-123",
                      onSaved: (value) {
                        vm.securityNumberFilter = value;
                      },
                    ),
                    TextFormField(
                      initialValue: "Mortgage",
                      onSaved: (value) {
                        vm.securityTypeFilter = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        final result = handler.buildDraftData(vm);

        expect(result, <String, dynamic>{
          "securityNumberFilter": "SEC-123",
          "securityTypeFilter": "Mortgage",
        });

        verify(() => vm.formKey).called(1);
        verify(() => vm.securityNumberFilter).called(1);
        verify(() => vm.securityTypeFilter).called(1);
      },
    );

    test(
      "returns current filter values when form currentState is null",
      () {
        final formKey = GlobalKey<FormState>();

        securityNumberFilter = "SEC-999";
        securityTypeFilter = "Pledge";

        when(() => vm.formKey).thenReturn(formKey);

        final result = handler.buildDraftData(vm);

        expect(result["securityNumberFilter"], "SEC-999");
        expect(result["securityTypeFilter"], "Pledge");
      },
    );
  });

  group("FacilitySecurityLinkageDraftHandler.applyDraft", () {
    test(
      "restores non-null filters, emits state, and schedules both filters",
      () async {
        handler.applyDraft(vm, <String, dynamic>{
          "securityNumberFilter": " SEC-456 ",
          "securityTypeFilter": " Guarantee ",
        });

        expect(securityNumberFilter, " SEC-456 ");
        expect(securityTypeFilter, " Guarantee ");

        verify(() => vm.state).called(1);
        verify(() => state.copyWith()).called(1);
        verify(() => vm.emit(state)).called(1);

        await Future<void>.delayed(Duration.zero);

        verify(
          () => vm.onFilter(
            value: "SEC-456",
            filterType: FilterType.securityNumber,
          ),
        ).called(1);

        verify(
          () => vm.onFilter(
            value: "Guarantee",
            filterType: FilterType.securityType,
          ),
        ).called(1);
      },
    );

    test(
      "does not restore filters when draft values are null and does not schedule filters",
      () async {
        handler.applyDraft(vm, <String, dynamic>{
          "securityNumberFilter": null,
          "securityTypeFilter": null,
        });

        expect(securityNumberFilter, isNull);
        expect(securityTypeFilter, isNull);

        verify(() => vm.state).called(1);
        verify(() => state.copyWith()).called(1);
        verify(() => vm.emit(state)).called(1);

        await Future<void>.delayed(Duration.zero);

        verifyNever(
          () => vm.onFilter(
            value: any(named: "value"),
            filterType: any(named: "filterType"),
          ),
        );
      },
    );

    test(
      "restores empty filters but does not schedule filter calls",
      () async {
        handler.applyDraft(vm, <String, dynamic>{
          "securityNumberFilter": "   ",
          "securityTypeFilter": "",
        });

        expect(securityNumberFilter, "   ");
        expect(securityTypeFilter, "");

        verify(() => vm.state).called(1);
        verify(() => state.copyWith()).called(1);
        verify(() => vm.emit(state)).called(1);

        await Future<void>.delayed(Duration.zero);

        verifyNever(
          () => vm.onFilter(
            value: any(named: "value"),
            filterType: any(named: "filterType"),
          ),
        );
      },
    );

    test(
      "converts non-string draft values to string before restoring",
      () async {
        handler.applyDraft(vm, <String, dynamic>{
          "securityNumberFilter": 12345,
          "securityTypeFilter": true,
        });

        expect(securityNumberFilter, "12345");
        expect(securityTypeFilter, "true");

        verify(() => vm.state).called(1);
        verify(() => state.copyWith()).called(1);
        verify(() => vm.emit(state)).called(1);

        await Future<void>.delayed(Duration.zero);

        verify(
          () => vm.onFilter(
            value: "12345",
            filterType: FilterType.securityNumber,
          ),
        ).called(1);

        verify(
          () => vm.onFilter(
            value: "true",
            filterType: FilterType.securityType,
          ),
        ).called(1);
      },
    );
  });
}
