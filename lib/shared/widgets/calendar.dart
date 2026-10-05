import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meu_app/data/models/tag.dart';
import 'package:meu_app/data/models/task.dart';
import 'package:meu_app/shared/appearance.dart';
import 'package:meu_app/shared/calendar_viewport.dart';
import 'package:meu_app/shared/widgets/floating_card.dart';
import 'package:meu_app/shared/widgets/tag_indicator.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget {
  const Calendar({
    super.key,
    required this.tasks,
    required this.period,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onPeriodChanged,
    required this.onToday,
    this.tagsById = const {},
  });

  final List<Task> tasks;
  final Map<int, Tag> tagsById;
  final CalendarPeriod period;
  final DateTime focusedDay;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onPageChanged;
  final ValueChanged<CalendarPeriod> onPeriodChanged;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final formats = {
      CalendarPeriod.week: CalendarFormat.week,
      CalendarPeriod.twoWeeks: CalendarFormat.twoWeeks,
      CalendarPeriod.month: CalendarFormat.month,
    };
    final taskSource = <DateTime, List<Task>>{};
    for (final task in tasks) {
      taskSource.putIfAbsent(task.normalizedDate, () => []).add(task);
    }
    final viewport = CalendarViewport.forPage(focusedDay, period);
    return FloatingCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CalendarHeader(
            focusedDay: focusedDay,
            period: period,
            viewport: viewport,
            onPageChanged: onPageChanged,
            onPeriodChanged: onPeriodChanged,
            onToday: onToday,
          ),
          const SizedBox(height: 8),
          TableCalendar<Task>(
            headerVisible: false,
            locale: 'pt_BR',
            firstDay: CalendarViewport.firstDay,
            lastDay: CalendarViewport.lastDay,
            focusedDay: focusedDay,
            calendarFormat: formats[period]!,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableGestures: AvailableGestures.horizontalSwipe,
            rowHeight: 52,
            daysOfWeekHeight: MediaQuery.textScalerOf(context).scale(22),
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (day, _) => onDaySelected(day),
            onPageChanged: onPageChanged,
            eventLoader: (day) =>
                taskSource[DateTime(day.year, day.month, day.day)] ?? [],
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
              ),
              weekendStyle: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            calendarStyle: CalendarStyle(
              cellMargin: const EdgeInsets.all(4),
              outsideDaysVisible: false,
              defaultTextStyle: TextStyle(color: scheme.onSurface),
              weekendTextStyle: TextStyle(color: scheme.onSurface),
              disabledTextStyle: TextStyle(color: scheme.onSurfaceVariant),
              selectedTextStyle: TextStyle(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
              todayTextStyle: TextStyle(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
              selectedDecoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              todayDecoration: BoxDecoration(
                border: Border.all(color: scheme.outline, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              defaultDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              weekendDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            calendarBuilders: CalendarBuilders<Task>(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                final colors = events
                    .map(
                      (task) => tagsById[task.tagId]?.color ?? scheme.onSurface,
                    )
                    .toSet()
                    .take(3);
                return Positioned(
                  bottom: 5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final color in colors)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: TagIndicator(color: color, size: 6),
                        ),
                    ],
                  ),
                );
              },
            ),
            pageAnimationDuration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.focusedDay,
    required this.period,
    required this.viewport,
    required this.onPageChanged,
    required this.onPeriodChanged,
    required this.onToday,
  });

  final DateTime focusedDay;
  final CalendarPeriod period;
  final CalendarViewport viewport;
  final ValueChanged<DateTime> onPageChanged;
  final ValueChanged<CalendarPeriod> onPeriodChanged;
  final VoidCallback onToday;

  DateTime? _adjacentPage(int offset) {
    var target = period == CalendarPeriod.month
        ? DateTime.utc(focusedDay.year, focusedDay.month + offset)
        : viewport.start.add(
            Duration(days: offset * (period == CalendarPeriod.week ? 7 : 14)),
          );
    final range = CalendarViewport.forPage(target, period);
    if (!range.endExclusive.isAfter(CalendarViewport.firstDay) ||
        range.start.isAfter(CalendarViewport.lastDay)) {
      return null;
    }
    if (target.isBefore(CalendarViewport.firstDay)) {
      target = CalendarViewport.firstDay;
    }
    if (target.isAfter(CalendarViewport.lastDay)) {
      target = CalendarViewport.lastDay;
    }
    return target;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final month = DateFormat('MMMM yyyy', 'pt_BR').format(focusedDay);
    final title = Semantics(
      header: true,
      child: Text(
        '${month[0].toUpperCase()}${month.substring(1)}',
        style: theme.textTheme.titleMedium,
      ),
    );
    final label = switch (period) {
      CalendarPeriod.week => '1 semana',
      CalendarPeriod.twoWeeks => '2 semanas',
      CalendarPeriod.month => '1 mês',
    };
    final nextPeriod = CalendarPeriod
        .values[(period.index + 1) % CalendarPeriod.values.length];
    final periodButton = Align(
      alignment: Alignment.centerLeft,
      child: Tooltip(
        message: 'Alternar período: 1 semana, 2 semanas, 1 mês',
        child: TextButton(
          key: const ValueKey('calendar-period-toggle'),
          onPressed: () => onPeriodChanged(nextPeriod),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            textStyle: theme.textTheme.bodySmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.swap_horiz_rounded, size: 16),
              const SizedBox(width: 6),
              Flexible(child: Text(label)),
            ],
          ),
        ),
      ),
    );
    final previous = _adjacentPage(-1);
    final next = _adjacentPage(1);
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Ir para hoje',
          onPressed: onToday,
          icon: const Icon(Icons.today_outlined, size: 20),
        ),
        IconButton(
          tooltip: 'Período anterior',
          onPressed: previous == null ? null : () => onPageChanged(previous),
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: 'Próximo período',
          onPressed: next == null ? null : () => onPageChanged(next),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        title,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: periodButton),
            actions,
          ],
        ),
      ],
    );
  }
}
