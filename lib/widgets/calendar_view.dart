import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_models/shared_models.dart';

import 'calendar_common.dart';

export 'calendar_common.dart' show CalendarEventFilter;

/// A monthly calendar widget that displays events for a given [sectionId],
/// allowing navigation through months and showing event titles on scheduled days.
class const CalendarView({super.key, required this.sectionId, this.userId, this.onEventTap}) extends HookWidget {
  final String sectionId;
  final String? userId;
  final void Function(Event event)? onEventTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final displayedMonth = useState(DateTime(now.year, now.month));
    final selectedDay = useState<DateTime?>(DateTime(now.year, now.month, now.day));
    final filter = useState(CalendarEventFilter.all);

    final calendarState = useCalendarEvents(sectionId: sectionId, userId: userId, filter: filter.value);

    if (calendarState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (calendarState.error != null) {
      return CalendarErrorView(error: calendarState.error);
    }

    final filteredEvents = calendarState.filteredEvents;

    void goToPreviousMonth() {
      final current = displayedMonth.value;
      displayedMonth.value = DateTime(current.year, current.month - 1);
    }

    void goToNextMonth() {
      final current = displayedMonth.value;
      displayedMonth.value = DateTime(current.year, current.month + 1);
    }

    void goToToday() {
      final today = DateTime.now();
      displayedMonth.value = DateTime(today.year, today.month);
      selectedDay.value = DateTime(today.year, today.month, today.day);
    }

    final year = displayedMonth.value.year;
    final month = displayedMonth.value.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekdayOffset = firstDayOfMonth.weekday % 7; // Sunday = 0, Monday = 1, ...
    final prevMonthDays = DateTime(year, month, 0).day;

    final totalGridCells = ((startWeekdayOffset + daysInMonth + 6) ~/ 7) * 7;

    final selectedDate = selectedDay.value;
    final selectedDayEvents = selectedDate != null ? getEventsForDay(filteredEvents, selectedDate) : <Event>[];

    return CalendarScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Month Navigation Header ───────────────────────────────────────
          CalendarMonthHeader(
            displayedMonth: displayedMonth.value,
            filter: filter.value,
            onFilterChanged: (f) => filter.value = f,
            onPreviousMonth: goToPreviousMonth,
            onNextMonth: goToNextMonth,
            onToday: goToToday,
          ),

          // ── Day of Week Header ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            child: Row(
              children: calendarShortWeekDayNames.map((name) {
                return Expanded(
                  child: Center(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Calendar Grid ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalGridCells,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.35,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemBuilder: (context, index) {
                DateTime cellDate;
                bool isThisMonth = true;

                if (index < startWeekdayOffset) {
                  // Previous month padding
                  final dayNum = prevMonthDays - (startWeekdayOffset - index - 1);
                  cellDate = DateTime(year, month - 1, dayNum);
                  isThisMonth = false;
                } else if (index >= startWeekdayOffset + daysInMonth) {
                  // Next month padding
                  final dayNum = index - (startWeekdayOffset + daysInMonth) + 1;
                  cellDate = DateTime(year, month + 1, dayNum);
                  isThisMonth = false;
                } else {
                  // Current month day
                  final dayNum = index - startWeekdayOffset + 1;
                  cellDate = DateTime(year, month, dayNum);
                }

                final normalizedCellDate = DateTime(cellDate.year, cellDate.month, cellDate.day);
                final isToday = now.year == cellDate.year && now.month == cellDate.month && now.day == cellDate.day;
                final isSelected =
                    selectedDate != null &&
                    selectedDate.year == cellDate.year &&
                    selectedDate.month == cellDate.month &&
                    selectedDate.day == cellDate.day;

                final dayEvents = getEventsForDay(filteredEvents, cellDate);

                return _DayCell(
                  date: cellDate,
                  isCurrentMonth: isThisMonth,
                  isToday: isToday,
                  isSelected: isSelected,
                  events: dayEvents,
                  now: now,
                  onTap: () {
                    selectedDay.value = normalizedCellDate;
                    if (!isThisMonth) {
                      displayedMonth.value = DateTime(cellDate.year, cellDate.month);
                    }
                  },
                );
              },
            ),
          ),

          // ── Selected Day Header Bar ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              border: Border(
                top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
                bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.event_note, size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  selectedDate != null
                      ? '${calendarMonthNames[selectedDate.month - 1]} ${selectedDate.day}, ${selectedDate.year}'
                      : 'Select a day',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (selectedDate != null)
                  Text(
                    selectedDayEvents.isEmpty
                        ? 'No events'
                        : '${selectedDayEvents.length} event${selectedDayEvents.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selectedDayEvents.isEmpty
                          ? Theme.of(context).colorScheme.outline
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),

          // ── Selected Day Event List ───────────────────────────────────────
          Expanded(
            child: selectedDayEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_busy_outlined,
                          size: 36,
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No events scheduled for this day.',
                          style: TextStyle(color: Theme.of(context).colorScheme.outline),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: selectedDayEvents.length,
                    itemBuilder: (context, index) {
                      final event = selectedDayEvents[index];
                      final hasEnded = isEventPast(event, now);
                      return Opacity(
                        opacity: hasEnded ? 0.5 : 1.0,
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              Icons.event,
                              color: hasEnded
                                  ? Theme.of(context).colorScheme.onSurfaceVariant
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(
                              event.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: hasEnded ? Theme.of(context).colorScheme.onSurfaceVariant : null,
                              ),
                            ),
                            subtitle: event.description != null && event.description!.isNotEmpty
                                ? Text(event.description!, maxLines: 2, overflow: TextOverflow.ellipsis)
                                : null,
                            trailing: Chip(
                              label: Text(hasEnded ? 'Ended' : event.type.name, style: const TextStyle(fontSize: 11)),
                              padding: EdgeInsets.zero,
                            ),
                            onTap: onEventTap != null ? () => onEventTap!(event) : null,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class const _DayCell({
  required this.date,
  required this.isCurrentMonth,
  required this.isToday,
  required this.isSelected,
  required this.events,
  required this.now,
  required this.onTap,
}) extends StatelessWidget {
  final DateTime date;
  final DateTime now;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final List<Event> events;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color? backgroundColor;
    if (isSelected) {
      backgroundColor = colorScheme.primaryContainer;
    } else if (isToday) {
      backgroundColor = colorScheme.primary.withValues(alpha: 0.1);
    }

    // Grey out the event dots when this day's events have all already ended.
    final dayHasEndedEvents = allEventsPast(events, now);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : isToday
                ? colorScheme.primary.withValues(alpha: 0.6)
                : Colors.transparent,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.w500,
                color: !isCurrentMonth
                    ? colorScheme.outline.withValues(alpha: 0.4)
                    : isSelected
                    ? colorScheme.onPrimaryContainer
                    : isToday
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            // Event indicators: colored dots
            if (events.isEmpty)
              const SizedBox(height: 5)
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < (events.length > 3 ? 3 : events.length); i++)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: dayHasEndedEvents
                            ? colorScheme.outline.withValues(alpha: 0.5)
                            : isSelected
                            ? colorScheme.primary
                            : colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
