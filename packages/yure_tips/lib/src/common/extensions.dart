import 'package:intl/intl.dart';

extension Format on int {
  String formatAsAmount() {
    final formattedValue = NumberFormat.decimalPattern('fr').format(this);
    return "$formattedValue F";
  }
}
