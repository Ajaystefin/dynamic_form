import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/profitability/account_conduct.dart";

// Import your models

void main() {
  group("AccountConductDetail", () {
    test("fromJson parses all fields correctly", () {
      final json = {
        "name": "Overdraft",
        "previousYear": "100",
        "currentYear": "120",
        "custName": "ABC LLC",
        "rimNo": 123456,
      };

      final detail = AccountConductDetail.fromJson(json);

      expect(detail.name, "Overdraft");
      expect(detail.previousYear, "100");
      expect(detail.currentYear, "120");
      expect(detail.custName, "ABC LLC");
      expect(detail.rimNo, 123456);
    });

    test("toJson serializes correctly", () {
      const detail = AccountConductDetail(
        name: "OD Hardcore",
        previousYear: "10",
        currentYear: "15",
        custName: "XYZ LTD",
        rimNo: 7890,
      );

      final map = detail.toJson();
      expect(map["name"], "OD Hardcore");
      expect(map["previousYear"], "10");
      expect(map["currentYear"], "15");
      expect(map["custName"], "XYZ LTD");
      expect(map["rimNo"], 7890);
    });

    test("copyWith updates selected fields", () {
      const detail = AccountConductDetail(
        name: "Cheque Returns",
        previousYear: "",
        currentYear: "",
        custName: "ACME",
        rimNo: 11,
      );

      final updated = detail.copyWith(currentYear: "5");
      expect(updated.name, "Cheque Returns");
      expect(updated.previousYear, "");
      expect(updated.currentYear, "5");
      expect(updated.custName, "ACME");
      expect(updated.rimNo, 11);
    });

    test("fromJson handles rimNo as String and num", () {
      final asString = AccountConductDetail.fromJson(const {
        "rimNo": "42",
      });
      expect(asString.rimNo, 42);

      final asDouble = AccountConductDetail.fromJson(const {
        "rimNo": 42.9,
      });
      expect(asDouble.rimNo, 42);
    });
  });

  group("AccountConductDto", () {
    test("fromJson parses mixed numeric types safely", () {
      final json = {
        "rimNo": "10001",
        "custName": "FOO INC",
        "pastDueOrExcesses": "12",
        "chequeReturns": 3,
        "turnoverInAcc": 1000.75,
        "odHardcore": "0",
        "unusualTransactions": "5.5",
        "transparencyDisclosureLevels": null,
        "accountConductDetailsList": [
          {
            "name": "OD Hardcore",
            "previousYear": "10",
            "currentYear": "15",
            "custName": "FOO INC",
            "rimNo": "10001",
          },
          {
            "name": "Cheque Returns",
            "previousYear": "",
            "currentYear": "2",
            "custName": "FOO INC",
            "rimNo": 10001,
          },
        ],
      };

      final dto = AccountConductDto.fromJson(json);

      expect(dto.rimNo, 10001);
      expect(dto.custName, "FOO INC");
      expect(dto.passDueOrExcesses, "12");
      expect(dto.chequeReturns, "3");
      expect(dto.turnoverInAcc, "1000.75");
      expect(dto.odHardcore, "0");
      expect(dto.unusualTransactions, "5.5");
      expect(dto.transparencyDisclosureLevels, "null");
      expect(dto.accountConductDetailsList.length, 2);
      expect(dto.accountConductDetailsList.first.name, "OD Hardcore");
      expect(dto.accountConductDetailsList.last.name, "Cheque Returns");
    });

    test("fromJson handles missing accountConductDetailsList gracefully", () {
      final dto = AccountConductDto.fromJson(const {
        "rimNo": 123,
        "custName": "No Details Co.",
      });
      expect(dto.accountConductDetailsList, isA<List<AccountConductDetail>>());
      expect(dto.accountConductDetailsList, isEmpty);
    });
  });

  group("AccountConductResponseData", () {
    // test('fromJson reads previousYearLable typo and currentYearLable', () {
    //   final json = {
    //     'previousYearLable': 'FY-2023', // typo key per backend
    //     'currentYearLable': 'FY-2024',
    //     'accountConductDtoList': [
    //       {
    //         'rimNo': 100,
    //         'custName': 'TEST',
    //         'pastDueOrExcesses': 1,
    //         'chequeReturns': 0,
    //         'turnoverInAcc': 10,
    //         'odHardcore': 0,
    //         'unusualTransactions': 0,
    //         'transparencyDisclosureLevels': 123,
    //         'accountConductDetailsList': [
    //           {
    //             'name': 'OD Hardcore',
    //             'previousYear': '',
    //             'currentYear': '5',
    //             'custName': 'TEST',
    //             'rimNo': 100,
    //           },
    //         ],
    //       },
    //     ],
    //   };

    //   final resp = AccountConductResponseData.fromJson(json);
    //   expect(resp.previousYearLable, 'FY-2023');
    //   expect(resp.currentYearLable, 'FY-2024');
    //   expect(resp.previousYearLabel, 'FY-2023'); // normalized getter
    //   expect(resp.currentYearLabel, 'FY-2024');
    //   expect(resp.accountConductDtoList.length, 1);
    //   expect(resp.accountConductDtoList.first.custName, 'TEST');
    // });

    // test('toJson serializes back with same keys (including typo)', () {
    //   const dto = AccountConductDto(
    //     rimNo: 100,
    //     custName: 'TEST',
    //     accountConductDetailsList: [],
    //   );

    //   const resp = AccountConductResponseData(
    //     accountConductDtoList: [dto],
    //     previousYearLable: 'FY-2023',
    //     currentYearLable: 'FY-2024',
    //   );

    //   final map = resp.toJson();
    //   expect(map['previousYearLable'], 'FY-2023');
    //   expect(map['currentYearLable'], 'FY-2024');
    //   expect(map['accountConductDtoList'], isA<List>());

    //   final first = (map['accountConductDtoList'] as List).first as Map;
    //   expect(first['rimNo'], 100);
    //   expect(first['custName'], 'TEST');
    // });

    // test('copyWith updates selectively', () {
    //   const original = AccountConductResponseData(
    //     accountConductDtoList: [],
    //     previousYearLable: 'FY-2023',
    //     currentYearLable: 'FY-2024',
    //   );

    //   final updated = original.copyWith(
    //     previousYearLable: 'FY-2022',
    //   );

    //   expect(updated.previousYearLable, 'FY-2022');
    //   expect(updated.currentYearLable, 'FY-2024');
    //   expect(updated.accountConductDtoList, isEmpty);

    //   // Original remains unchanged
    //   expect(original.previousYearLable, 'FY-2023');
    // });

    test("fromJson handles missing keys gracefully", () {
      final resp = AccountConductResponseData.fromJson(const {});
      expect(resp.previousYearLable, isNull);
      expect(resp.currentYearLable, isNull);
      expect(resp.accountConductDtoList, isEmpty);
    });
  });
}
