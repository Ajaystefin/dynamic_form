import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/document_data.dart";
import "package:wcas_frontend/models/request/file_attachment/file_upload.dart";

void main() {
  group("FileDetail.fromJson", () {
    test("parses type and name; documents becomes [] when children is null",
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        "type": "CATEGORY",
        "name": "KYC Docs",
        // 'children' intentionally omitted → null
      };

      // Act
      final model = FileDetail.fromJson(
        json,
        null, // documentTypes
        null, // subTypes
        null, // subSubTypes
        null, // subSubSubTypes
        null, // languages
      );

      // Assert
      expect(model.type, "CATEGORY");
      expect(model.name, "KYC Docs");
      expect(model.documents, isA<List<DocumentDetail>>());
      expect(model.documents, isEmpty);
    });

    test("documents becomes [] when children is an empty list", () {
      final Map<String, dynamic> json = <String, dynamic>{
        "type": "CATEGORY",
        "name": "KYC Docs",
        "children": <Map<String, dynamic>>[],
      };

      final model = FileDetail.fromJson(
        json,
        null, // references can still be null when children is empty
        null,
        null,
        null,
        null,
      );

      expect(model.type, "CATEGORY");
      expect(model.name, "KYC Docs");
      expect(model.documents, isEmpty);
    });

    // test(
    //     'throws when children is non-empty but reference lists are null (due
    // to forced null assertions).',
    //     () {
    //   final Map<String, dynamic> json = <String, dynamic>{
    //     'type': 'CATEGORY',
    //     'name': 'KYC Docs',
    //     'children': <Map<String, dynamic>>[
    //       <String, dynamic>{'some': 'child'},
    //     ],
    //   };

    //   // Because the implementation uses `documentTypes!` etc.,
    //   // passing null reference lists with non-empty children will throw.
    //   expect(
    //     () => FileDetail.fromJson(
    //       json,
    //       null, // documentTypes!
    //       null, // subTypes!
    //       null, // subSubTypes!
    //       null, // subSubSubTypes!
    //       null, // languages!
    //     ),
    //     throwsA(isA<
    //         Error>(),), // could be a NullError/TypeError depending on runtime
    //   );
    // });

    group("FileDetail default constructor", () {
      test("creates object with provided type, documents, and name", () {
        // Arrange
        final docs = <DocumentDetail>[]; // empty list still valid

        // Act
        final model = FileDetail(
          type: "CATEGORY",
          documents: docs,
          name: "KYC Docs",
        );

        // Assert
        expect(model.type, "CATEGORY");
        expect(model.documents, same(docs)); // exact list passed in
        expect(model.name, "KYC Docs");
      });

      test("creates object with null name", () {
        final model = FileDetail(
          type: "CATEGORY",
          documents: const [],
        );

        expect(model.type, "CATEGORY");
        expect(model.documents, isEmpty);
        expect(model.name, isNull);
      });
    });

    // OPTIONAL (enable if you are confident DocumentDetail.fromJson can handle
    // empty reference lists)
    test(
        "maps each child to a DocumentDetail when reference lists are provided",
        () {
      final Map<String, dynamic> json = <String, dynamic>{
        "type": "CATEGORY",
        "name": "KYC Docs",
        "children": <Map<String, dynamic>>[
          <String, dynamic>{/* minimal valid shape for DocumentDetail */},
          <String, dynamic>{/* minimal valid shape for DocumentDetail */},
        ],
      };

      // Provide empty (but non-null) reference lists to satisfy the non-null
      // assertions.
      final refs = <Reference>[];

      final model = FileDetail.fromJson(
        json,
        refs,
        refs,
        refs,
        refs,
        refs,
      );

      expect(model.type, "CATEGORY");
      expect(model.name, "KYC Docs");
      expect(model.documents, isNotEmpty);
      expect(model.documents!.length, 2);
    });
  });
}
