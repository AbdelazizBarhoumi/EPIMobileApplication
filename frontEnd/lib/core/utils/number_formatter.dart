// filepath: c:\Users\abdulazeezbrhomi\OneDrive\University\Epi\Sem3\flutter\epiApp\lib\core\utils\number_formatter.dart
import 'package:intl/intl.dart';

class NumberFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'TND ',
    decimalDigits: 2,
  );

  static final NumberFormat _percentageFormat = NumberFormat.percentPattern();

  static final NumberFormat _decimalFormat = NumberFormat('#.##');

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatPercentage(double value) {
    return _percentageFormat.format(value / 100);
  }

  static String formatGPA(double gpa) {
    return _decimalFormat.format(gpa);
  }

  static String formatGrade(double grade) {
    return _decimalFormat.format(grade);
  }

  static String formatCredits(int credits) {
    return credits.toString();
  }

  static String formatAttendance(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  static String getLetterGrade(double grade) {
    if (grade >= 90) return 'A';
    if (grade >= 80) return 'B';
    if (grade >= 70) return 'C';
    if (grade >= 60) return 'D';
    return 'F';
  }

  static String getGradePoint(double grade) {
    if (grade >= 90) return '4.0';
    if (grade >= 80) return '3.0';
    if (grade >= 70) return '2.0';
    if (grade >= 60) return '1.0';
    return '0.0';
  }
}
