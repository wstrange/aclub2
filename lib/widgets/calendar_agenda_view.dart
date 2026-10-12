import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_models/shared_models.dart';

import 'calendar_common.dart';

/// A compact month-agenda view that lists all events for the displayed month
/// in a scrollable vertical list, grouped by date.
///
/// Designed for mobile screens where a full calendar grid wastes space.
/// Reuses the same data streams and filter logic as [CalendarView].
class CalendarAgendaView extends HookWidget {
  const CalendarAgendaView({
    super.key,
    required this.sectionId,
    this.userId,
    this.onEventTap,
  });

  final String sectionId;
  final String? userId;
  final void Function(Event event)? onEventTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final displayedMonth = useState(DateTime(now.year, now.month));
    final filter = useState(CalendarEventFilter.all);

    final calendarState = useCalendarEvents(
      sectionId: sectionId,
      userId: userId,
      filter: filter.value,
    );

    if (calendarState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (calendarState.error != null) {
      return CalendarErrorView(error: calendarState.error);
    }

    final filteredEvents = calendarState.filteredEvents;

    // ── Build grouped agenda for the displayed month ─────────────────────
    final year = displayedMonth.value.year;
    final month = displayedMonth.value.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Collect events for each day of the month. A multi-day event appears on
    // every day it spans within this month.
    final dayEntries = <_DayEntry>[];
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(year, month, d);
      final dayEvents = getEventsForDay(filteredEvents, date);
      if (dayEvents.isNotEmpty) {
        // Sort events within a day by start time.
        dayEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
        dayEntries.add(_DayEntry(date: date, events: dayEvents));
      }
    }

    // ── Navigation ───────────────────────────────────────────────────────
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
    }

    return CalendarScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Month Navigation Header ──────────────────────────────────
          CalendarMonthHeader(
            displayedMonth: displayedMonth.value,
            filter: filter.value,
            onFilterChanged: (f) => filter.value = f,
            onPreviousMonth: goToPreviousMonth,
            onNextMonth: goToNextMonth,
            onToday: goToToday,
          ),

          const Divider(height: 1),

          // ── Event count summary ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              dayEntries.isEmpty
                  ? 'No events this month'
                  : '${filteredEvents.where((e) {
                      final s = DateTime(e.startDate.year, e.startDate.month, e.startDate.day);
                      final en = DateTime(e.endDate.year, e.endDate.month, e.endDate.day);
                      final monthStart = DateTime(year, month, 1);
                      final monthEnd = DateTime(year, month, daysInMonth);
                      return s.compareTo(monthEnd) <= 0 && en.compareTo(monthStart) >= 0;
                    }).length} event${filteredEvents.length == 1 ? '' : 's'} across ${dayEntries.length} day${dayEntries.length == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),

          // ── Agenda List ──────────────────────────────────────────────
          Expanded(
            child: dayEntries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_busy_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No events scheduled this month.',
                          style: TextStyle(color: Theme.of(context).colorScheme.outline),
                        ),
                      ],
                    ),
                  )
                : _AgendaList(
                    dayEntries: dayEntries,
                    now: now,
                    onEventTap: onEventTap,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Groups events by date for agenda rendering.
class _DayEntry {
  const _DayEntry({required this.date, required this.events});
  final DateTime date;
  final List<Event> events;
}

/// The scrollable agenda list with date headers and event rows.
class _AgendaList extends HookWidget {
  const _AgendaList({
    required this.dayEntries,
    required this.now,
    this.onEventTap,
  });

  final List<_DayEntry> dayEntries;
  final DateTime now;
  final void Function(Event event)? onEventTap;

  @override
  Widget build(BuildContext context) {
    // Build a flat list of items: date headers + event rows.
    final items = <_AgendaItem>[];
    for (final entry in dayEntries) {
      items.add(_AgendaItem.header(entry.date));
      for (final event in entry.events) {
        items.add(_AgendaItem.event(event, entry.date));
      }
    }

    // Find the index of today's header (or the next future date) to auto-scroll.
    final todayNorm = DateTime(now.year, now.month, now.day);
    int initialScrollIndex = 0;
    for (var i = 0; i < items.length; i++) {
      if (items[i].isHeader && !items[i].date!.isBefore(todayNorm)) {
        initialScrollIndex = i;
        break;
      }
    }

    final scrollController = useScrollController();

    // Auto-scroll to today on first build.
    useEffect(() {
      if (initialScrollIndex > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            // Estimate offset: each header ~40px, each event row ~72px.
            // This is approximate; good enough for scrolling near today.
            var offset = 0.0;
            for (var i = 0; i < initialScrollIndex; i++) {
              offset += items[i].isHeader ? 40.0 : 72.0;
            }
            scrollController.animateTo(
              offset.clamp(0, scrollController.position.maxScrollExtent),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
      return null;
    }, [dayEntries.length]);

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item.isHeader) {
          return _DateHeader(date: item.date!, now: now);
        }
        return _EventRow(
          event: item.event!,
          dayDate: item.date!,
          onTap: onEventTap != null ? () => onEventTap!(item.event!) : null,
        );
      },
    );
  }
}

/// A tagged union: either a date header or an event row.
class _AgendaItem {
  _AgendaItem.header(this.date)
      : event = null,
        isHeader = true;
  _AgendaItem.event(this.event, this.date) : isHeader = false;

  final bool isHeader;
  final DateTime? date;
  final Event? event;
}

/// Sticky-style date section header.
class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date, required this.now});

  final DateTime date;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final isTomorrow = date.year == now.year && date.month == now.month && date.day == now.day + 1;
    final isYesterday = date.year == now.year && date.month == now.month && date.day == now.day - 1;

    final weekDay = calendarShortWeekDayNames[date.weekday % 7];

    String label;
    if (isToday) {
      label = 'Today · $weekDay, ${calendarShortMonthNames[date.month - 1]} ${date.day}';
    } else if (isTomorrow) {
      label = 'Tomorrow · $weekDay, ${calendarShortMonthNames[date.month - 1]} ${date.day}';
    } else if (isYesterday) {
      label = 'Yesterday · $weekDay, ${calendarShortMonthNames[date.month - 1]} ${date.day}';
    } else {
      label = '${calendarWeekDayNames[date.weekday % 7]}, ${calendarShortMonthNames[date.month - 1]} ${date.day}';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          if (isToday)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                color: isToday ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single event row in the agenda list.
class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.event,
    required this.dayDate,
    this.onTap,
  });

  final Event event;
  final DateTime dayDate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final icon = _iconForEventType(event.type);
    final timeStr = _formatTimeRange(event);

    // Check if this is a multi-day event and we're on a continuation day.
    final startNorm = DateTime(event.startDate.year, event.startDate.month, event.startDate.day);
    final endNorm = DateTime(event.endDate.year, event.endDate.month, event.endDate.day);
    final isMultiDay = startNorm != endNorm;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Type icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                // Title + time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              timeStr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isMultiDay) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: colorScheme.tertiaryContainer.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'multi-day',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onTertiaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Event type chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event.type.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 18, color: colorScheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Maps [EventType] to a Material icon.
IconData _iconForEventType(EventType type) {
  return switch (type) {
    EventType.hike => Icons.hiking,
    EventType.climb => Icons.terrain,
    EventType.rock => Icons.landscape,
    EventType.trailRun => Icons.directions_run,
    EventType.alpineSki => Icons.downhill_skiing,
    EventType.skiMountaineering => Icons.snowshoeing,
    EventType.snowshoe => Icons.ac_unit,
    EventType.social => Icons.celebration,
    EventType.presentation => Icons.co_present,
  };
}

/// Formats the time range for display, e.g. "9:00 AM – 5:00 PM".
String _formatTimeRange(Event event) {
  return '${_formatTime(event.startDate)} – ${_formatTime(event.endDate)}';
}

String _formatTime(DateTime dt) {
  final hour = dt.hour;
  final minute = dt.minute;
  final isPm = hour >= 12;
  final displayHour = hour == 0
      ? 12
      : hour > 12
          ? hour - 12
          : hour;
  final minuteStr = minute == 0 ? '' : ':${minute.toString().padLeft(2, '0')}';
  return '$displayHour$minuteStr ${isPm ? 'PM' : 'AM'}';
}
