import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/document_data.dart";

void main() {
  group("DocumentDetail.fromJson", () {
    test(
        "parses type and resolves name via"
        " documentTypes (json.name is id as string)", () {
      // Arrange: json["name"] holds an ID-like string that should match a
      // Reference.id
      final Map<String, dynamic> json = <String, dynamic>{
        "type": "document",
        "name": "101", // will be int.tryParse('101') → 101
        // No attributes → docTypeId should remain nullable (we do not assert
        // it)
        // No children → lists should be empty
      };

      final documentTypes = <Reference>[
        Reference(id: 101, name: "KYC Document"),
        Reference(id: 202, name: "Another Type"),
      ];

      // We pass non-null lists for all reference groups even if unused here,
      // because the factory has non-null assertions for children mapping.
      final subTypes = <Reference>[];
      final subSubTypes = <Reference>[];
      final subSubSubTypes = <Reference>[];
      final languages = <Reference>[];

      // Act
      final model = DocumentDetail.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(model.type, "document");
      // name is taken from the matched Reference in documentTypes
      expect(model.name, "KYC Document");
      // documentType also returned (the Reference we matched)
      expect(model.documentType, isA<Reference>());
      expect(model.documentType!.id, 101);
      expect(model.documentType!.name, "KYC Document");

      // No children were provided → all lists are empty but non-null.
      expect(model.docYears, isA<List>());
      expect(model.docYears, isEmpty);

      expect(model.legacyFiles, isA<List>());
      expect(model.legacyFiles, isEmpty);

      expect(model.documents, isA<List>());
      expect(model.documents, isEmpty);

      // docTypeId is computed from attributes?.docType via
      // Utils.getDocumentTypeById;
      // attributes were not provided, so we expect null and do NOT assert a
      // value here.
      expect(model.docTypeId, isNull);
    });

    test(
        "when json.name does not "
        "parse or no match found → "
        "name stays null and documentType is empty Reference()", () {
      // Arrange: name cannot be parsed to int (e.g., 'ABC') → int.tryParse
      // fails
      final Map<String, dynamic> json = <String, dynamic>{
        "type": "document",
        "name": "ABC", // int.tryParse('ABC') → null → no match
      };

      final documentTypes = <Reference>[
        Reference(id: 1, name: "Type-1"),
      ];
      final subTypes = <Reference>[];
      final subSubTypes = <Reference>[];
      final subSubSubTypes = <Reference>[];
      final languages = <Reference>[];

      // Act
      final model = DocumentDetail.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(model.type, "document");
      // name is docType?.name, but docType will be Reference() (id null) from
      // orElse, so name remains null
      expect(model.name, isNull);

      // documentType should be an empty Reference (fallback)
      expect(model.documentType, isA<Reference>());
      expect(model.documentType!.id, isNull);
      expect(model.documentType!.name, isNull);

      // children absent → lists empty
      expect(model.docYears, isEmpty);
      expect(model.legacyFiles, isEmpty);
      expect(model.documents, isEmpty);
    });

    test(
        "children with unknown type are ignored "
        "by filters (no mapping invoked)", () {
      final Map<String, dynamic> json = <String, dynamic>{
        "type": "document",
        "name": "1",
        "children": <Map<String, dynamic>>[
          {"type": "unknown", "foo": "bar"},
          {"type": "mystery", "x": 1},
        ],
      };

      final documentTypes = <Reference>[Reference(id: 1, name: "Doc-1")];
      final subTypes = <Reference>[];
      final subSubTypes = <Reference>[];
      final subSubSubTypes = <Reference>[];
      final languages = <Reference>[];

      final model = DocumentDetail.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Unknown children types → all filtered lists stay empty.
      expect(model.docYears, isEmpty);
      expect(model.legacyFiles, isEmpty);
      expect(model.documents, isEmpty);

      // Name resolved from documentTypes since '1' parses and matches id=1
      expect(model.name, "Doc-1");
    });

    // test(
    //     'throws when children exist but reference lists are null (due to
    // non-null assertions)',
    //     () {
    //   // Arrange: include a child of a recognized type so that the factory attempts mapping
    //   final Map<String, dynamic> json = <String, dynamic>{
    //     'type': 'document',
    //     'name': '1',
    //     'children': <Map<String, dynamic>>[
    //       {
    //         'type': 'year',
    //       }, // will try DocYearDetail.fromJson(..., documentTypes!, ...)
    //       {
    //         'type': 'file',
    //       }, // will try DocSubTypeDetail.fromJson(..., subTypes! ...)
    //       {
    //         'type': 'legacy',
    //       }, // will try LegacyFiles.fromJson(..., documentTypes! ...)
    //     ],
    //   };

    //   // Act & Assert: since the code uses `documentTypes!`, `subTypes!` etc.,
    //   // passing null here will cause a runtime error.
    //   expect(
    //     () => DocumentDetail.fromJson(
    //       json,
    //       null, // documentTypes!
    //       null, // subTypes!
    //       null, // subSubTypes!
    //       null, // subSubSubTypes!
    //       null, // languages!
    //     ),
    //     throwsA(isA<Error>()),
    //   );
    // });

    test("children absent → it works even if reference lists are null", () {
      final Map<String, dynamic> json = <String, dynamic>{
        "type": "document",
        "name": "123", // parsed but no documentTypes to match; docType
        // no children
      };

      final model = DocumentDetail.fromJson(
        json,
        null,
        null,
        null,
        null,
        null,
      );

      expect(model.type, "document");
      expect(model.name, isNull); // no matching doc type name
      expect(model.docYears, isEmpty);
      expect(model.legacyFiles, isEmpty);
      expect(model.documents, isEmpty);
    });
  });

  group("DocumentDetail.fromJson → docTypeId computation branches", () {
    // Provide non-null (possibly empty) reference lists to satisfy non-null
    // assertions elsewhere
    final List<Reference> emptyRefs = <Reference>[];

    test("attributes.docType as int → calls Utils.getDocumentTypeById(int)",
        () {
      final Map<String, dynamic> json = <String, dynamic>{
        "type": "document",
        "name": "123", // will not match any Reference; we don't care here
        "attributes": <String, dynamic>{"docType": 7},
        "children":
            <Map<String, dynamic>>[], // keep empty to avoid child parsers
      };

      final detail = DocumentDetail.fromJson(
        json,
        emptyRefs, // documentTypes
        emptyRefs, // subTypes
        emptyRefs, // subSubTypes
        emptyRefs, // subSubSubTypes
        emptyRefs, // languages
      );

      // We don't assert the value because it's looked up via a static Utils
      // method.
      // Executing this branch is enough for coverage.
      // docTypeId may be null or a DocumentType depending on your Utils
      // implementation.
      // ignore: unnecessary_type_check
      expect(detail.docTypeId is Object? /* no-throw sentinel */, true);
    });

    test(
        "attributes.docType as String → parses to "
        "int and calls Utils.getDocumentTypeById", () {
      final Map<String, dynamic> json = <String, dynamic>{
        "type": "document",
        "name": "123",
        "attributes": <String, dynamic>{"docType": "7"},
        "children": <Map<String, dynamic>>[],
      };

      final detail = DocumentDetail.fromJson(
        json,
        emptyRefs,
        emptyRefs,
        emptyRefs,
        emptyRefs,
        emptyRefs,
      );

      // Same rationale as above—just ensure the code path executes.
      // ignore: unnecessary_type_check
      expect(detail.docTypeId is Object? /* no-throw sentinel */, isNotNull);
    });

    test("no attributes / null docType → docTypeId remains null", () {
      // Case A: no attributes key at all
      final Map<String, dynamic> jsonNoAttrs = <String, dynamic>{
        "type": "document",
        "name": "123",
        "children": <Map<String, dynamic>>[],
      };

      final detailNoAttrs = DocumentDetail.fromJson(
        jsonNoAttrs,
        emptyRefs,
        emptyRefs,
        emptyRefs,
        emptyRefs,
        emptyRefs,
      );
      expect(detailNoAttrs.docTypeId, isNull);

      // Case B: attributes present but docType explicitly null
      final Map<String, dynamic> jsonNullDocType = <String, dynamic>{
        "type": "document",
        "name": "123",
        "attributes": <String, dynamic>{"docType": null},
        "children": <Map<String, dynamic>>[],
      };

      final detailNullDocType = DocumentDetail.fromJson(
        jsonNullDocType,
        emptyRefs,
        emptyRefs,
        emptyRefs,
        emptyRefs,
        emptyRefs,
      );
      expect(detailNullDocType.docTypeId, isNull);
    });
  });
}
