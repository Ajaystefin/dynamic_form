import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/login/user.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/request.dart';

class Globals {
  static final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static final navigatorKey = GlobalKey<NavigatorState>();
  static DeviceScreenType? deviceScreenType;
  static User? user;
  static Request? request = Request(
      applicationRefNo: "202504APNIS027301",
      customerName: "John",
      customerRimNo: 1201,
      applicationType: Reference(name: "New"),
      requestType: Reference(id: 2, name: "Application"),
      businessSegment: Reference(id: 100, name: "CBD Personal"),
      customerType: Reference(name: ''),
      groupId: 111,
      groupName: 'GID001',
      groupOwner: 116320,
      customers: [
        Customer(customerName: "John", id: "25", customerRimNo: 1305),
        Customer(
            customerName: "Sara country",
            id: "50",
            customerRimNo: 1001,
            type: CustomerType.country),
        Customer(
            customerName: "Dale below ig",
            id: "150",
            customerRimNo: 1102,
            type: CustomerType.belowInvestmentGradeBanks),
        Customer(
            customerRimNo: 1503,
            id: "151",
            customerName: 'John Doe ig',
            type: CustomerType.investmentGradeBanks),
        Customer(customerRimNo: 25, id: "152", customerName: 'John Doe'),
        Customer(customerRimNo: 51, customerName: 'Jane Smith'),
        Customer(customerRimNo: 52, customerName: 'Alice Johnson'),
        Customer(customerRimNo: 53, customerName: 'Bob Williams'),
        Customer(customerRimNo: 54, customerName: 'Carlos Martinez'),
        Customer(customerRimNo: 55, customerName: 'Emily Davis'),
        Customer(customerRimNo: 56, customerName: 'David Lee'),
        Customer(customerRimNo: 57, customerName: 'Fatima Noor'),
        Customer(customerRimNo: 58, customerName: 'George Kim'),
        Customer(customerRimNo: 59, customerName: 'George '),
      ]);
  static String currentRoute = '/';
  static String previousRoute = '/';
  static String sessionID = "";
  static List<Option>? dynamicFormCurrencyCodes = [];
  static List<Option>? dynamicFormEconomicZones = [];
}
