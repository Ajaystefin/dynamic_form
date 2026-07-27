import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/components/file_attachment/tooltip_helper.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";

class TestAssetLoader extends AssetLoader {
  const TestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "eDigitalFilingFileAttachments": {
        "fileAttachments": {
          "tooltip": {
            "documentName": {
              "financialProjection": "Financial Projection Tooltip",
              "creditApplication": "Credit Application Tooltip",
              "constitutional": "Constitutional Tooltip",
              "default": "Default Tooltip",
            },
          },
        },
      },
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pumpTestApp(WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale("en")],
        path: "assets/translations",
        fallbackLocale: const Locale("en"),
        startLocale: const Locale("en"),
        assetLoader: const TestAssetLoader(),
        child: Builder(
          builder: (BuildContext context) {
            return MaterialApp(
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              home: const Scaffold(
                body: SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  group("TooltipHelper.getDocumentNameTooltip", () {
    testWidgets(
      "returns financial projection tooltip when document type is financial statements and subtype is projection",
      (WidgetTester tester) async {
        await pumpTestApp(tester);

        final String result = TooltipHelper.getDocumentNameTooltip(
          ServerConstants.documentTypeId[DocumentType.financialStatements],
          ServerConstants.subSubTypeFinancialProjection,
        );

        expect(result, "Financial Projection Tooltip");
      },
    );

    testWidgets(
      "returns credit application tooltip when document type is credit application",
      (WidgetTester tester) async {
        await pumpTestApp(tester);

        final String result = TooltipHelper.getDocumentNameTooltip(
          ServerConstants.documentTypeId[DocumentType.creditApplication],
          null,
        );

        expect(result, "Credit Application Tooltip");
      },
    );

    testWidgets(
      "returns constitutional tooltip when document type is constitutional document",
      (WidgetTester tester) async {
        await pumpTestApp(tester);

        final String result = TooltipHelper.getDocumentNameTooltip(
          ServerConstants.documentTypeId[DocumentType.constitutionalDocument],
          null,
        );

        expect(result, "Constitutional Tooltip");
      },
    );

    testWidgets(
      "returns default tooltip when document type is financial statements but subtype is not projection",
      (WidgetTester tester) async {
        await pumpTestApp(tester);

        final String result = TooltipHelper.getDocumentNameTooltip(
          ServerConstants.documentTypeId[DocumentType.financialStatements],
          999999,
        );

        expect(result, "Default Tooltip");
      },
    );

    testWidgets(
      "returns default tooltip when document type is null",
      (WidgetTester tester) async {
        await pumpTestApp(tester);

        final String result = TooltipHelper.getDocumentNameTooltip(
          null,
          null,
        );

        expect(result, "Default Tooltip");
      },
    );
  });
}
