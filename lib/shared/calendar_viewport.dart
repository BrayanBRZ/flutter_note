import 'package:meu_app/shared/appearance.dart';
import 'package:meu_app/data/models/task.dart';

/// Date-only interval with an inclusive start and exclusive end.
class CalendarViewport {
  const CalendarViewport(this.start, this.endExclusive);
  final DateTime start;
  final DateTime endExclusive;
  static final firstDay = DateTime.utc(2020, 1, 1);
  static final lastDay = DateTime.utc(2100, 12, 31);

  factory CalendarViewport.forPage(DateTime focusedDay, CalendarPeriod period) {
    final day = DateTime.utc(focusedDay.year, focusedDay.month, focusedDay.day);
    if (period == CalendarPeriod.month) {
      return CalendarViewport(
        DateTime.utc(day.year, day.month),
        DateTime.utc(day.year, day.month + 1),
      );
    }
    // Fortnight pages in TableCalendar are anchored to firstDay, not the tapped
    // date. Mirroring that anchor keeps the second row in the same period.
    final anchor = firstDay.subtract(Duration(days: firstDay.weekday - 1));
    final length = period == CalendarPeriod.week ? 7 : 14;
    final page = (day.difference(anchor).inDays / length).floor();
    final start = anchor.add(Duration(days: page * length));
    return CalendarViewport(start, start.add(Duration(days: length)));
  }

  bool contains(DateTime value) {
    final date = DateTime.utc(value.year, value.month, value.day);
    return !date.isBefore(start) && date.isBefore(endExclusive);
  }

  List<Task> tasksFrom(List<Task> tasks) =>
      tasks.where((task) => contains(task.targetDate)).toList()..sort((a, b) {
        final date = a.normalizedDate.compareTo(b.normalizedDate);
        return date != 0 ? date : a.targetDate.compareTo(b.targetDate);
      });
}
