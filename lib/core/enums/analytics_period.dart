import '../formatters/date_formatter.dart';

enum AnalyticsPeriod { currentMonth, last3Months, yearToDate, allTime }

extension AnalyticsPeriodX on AnalyticsPeriod {
  String get label {
    switch (this) {
      case AnalyticsPeriod.currentMonth:
        return 'Bulan ini';
      case AnalyticsPeriod.last3Months:
        return '3 bulan';
      case AnalyticsPeriod.yearToDate:
        return 'Tahun ini';
      case AnalyticsPeriod.allTime:
        return 'Semua';
    }
  }

  String get description {
    switch (this) {
      case AnalyticsPeriod.currentMonth:
        return 'Data bulan berjalan';
      case AnalyticsPeriod.last3Months:
        return 'Data tiga bulan terakhir';
      case AnalyticsPeriod.yearToDate:
        return 'Data sejak awal tahun';
      case AnalyticsPeriod.allTime:
        return 'Semua transaksi';
    }
  }

  DateTime? startDate(DateTime now) {
    switch (this) {
      case AnalyticsPeriod.currentMonth:
        return DateFormatter.startOfMonth(now);
      case AnalyticsPeriod.last3Months:
        return DateTime(now.year, now.month - 2);
      case AnalyticsPeriod.yearToDate:
        return DateTime(now.year);
      case AnalyticsPeriod.allTime:
        return null;
    }
  }
}
