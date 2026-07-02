import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _shortDate = DateFormat('d MMM yyyy', 'id_ID');
  static final DateFormat _month = DateFormat('MMMM yyyy', 'id_ID');
  static final DateFormat _time = DateFormat('HH.mm', 'id_ID');
  static final DateFormat _monthKey = DateFormat('yyyy-MM', 'id_ID');

  static String dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final value = DateTime(date.year, date.month, date.day);
    final diff = today.difference(value).inDays;

    if (diff == 0) {
      return 'Hari ini';
    }
    if (diff == 1) {
      return 'Kemarin';
    }
    if (diff < 7) {
      return 'Minggu ini';
    }
    return _shortDate.format(date);
  }

  static String dateTimeLabel(DateTime date) {
    return '${dayLabel(date)}, ${_time.format(date)}';
  }

  static String monthLabel(DateTime date) {
    return _month.format(date);
  }

  static String monthKey(DateTime date) {
    return _monthKey.format(date);
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime startOfWeek(DateTime date) {
    final day = startOfDay(date);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }
}
