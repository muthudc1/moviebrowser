import 'package:intl/intl.dart';

class DateFormatter {
  static String formatReleaseDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return 'Release date unknown';
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('MMMM d, yyyy').format(date);
    } catch (_) {
      return rawDate;
    }
  }

  static String getYear(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(rawDate);
      return date.year.toString();
    } catch (_) {
      return 'N/A';
    }
  }

  static String formatRuntime(int? minutes) {
    if (minutes == null || minutes <= 0) return 'N/A';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0 && remainingMinutes > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${remainingMinutes}m';
    }
  }

  static String formatCurrency(int? amount) {
    if (amount == null || amount <= 0) return 'N/A';
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 0);
    return formatter.format(amount);
  }
}
