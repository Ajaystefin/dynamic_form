import 'package:intl/intl.dart';

extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  String formatNumber() {
    try {
      final numValue = num.parse(this);
      final format = NumberFormat.decimalPattern('en_IN');
      return format.format(numValue);
    } catch (e) {
      return this; // Return original string if parsing fails
    }
  }
}
