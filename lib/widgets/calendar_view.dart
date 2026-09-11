import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_models/shared_models.dart';

import '../repo.dart';

const List<String> _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

/// A monthly calendar widget that displays events for a given [sectionId],
/// allowing navigation through months and showing event titles on scheduled days.
class CalendarView extends HookWidget {
  const CalendarView({super.key, required this.sectionId, this.onEventTap});

  final String sectionId;
  final void Function(Event event)? onEventTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final displayedMonth = useState(DateTime(now.year, now.month));
    final selectedDay = useState<DateTime?>(DateTime(now.year, now.month, now.day));

    final eventsStream = useMemoized(() => repository.streamSectionEvents(sectionId), [sectionId]);
    final eventsSnapshot = useStream(eventsStream);

    if (eventsSnapshot.connectionState == ConnectionState.waiting && !eventsSnapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (eventsSnapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error loading events: ${eventsSnapshot.error}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    final events = eventsSnapshot.data ?? [];

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

    // Filter events occurring on a specific normalized date
    List<Event> eventsForDay(DateTime day) {
      final targetDate = DateTime(day.year, day.month, day.day);
      return events.where((event) {
        final startNorm = DateTime(event.startDate.year, event.startDate.month, event.startDate.day);
        final endNorm = DateTime(event.endDate.year, event.endDate.month, event.endDate.day);
        return targetDate.compareTo(startNorm) >= 0 && targetDate.compareTo(endNorm) <= 0;
      }).toList();
    }

    final year = displayedMonth.value.year;
    final month = displayedMonth.value.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekdayOffset = firstDayOfMonth.weekday % 7; // Sunday = 0, Monday = 1, ...
    final prevMonthDays = DateTime(year, month, 0).day;

    final totalGridCells = ((startWeekdayOffset + daysInMonth + 6) ~/ 7) * 7;

    final selectedDate = selectedDay.value;
    final selectedDayEvents = selectedDate != null ? eventsForDay(selectedDate) : <Event>[];

    final isCurrentMonth = now.year == year && now.month == month;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Month Navigation Header ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  '${_monthNames[month - 1]} $year',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (!isCurrentMonth) TextButton(onPressed: goToToday, child: const Text('Today')),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous month',
                  onPressed: goToPreviousMonth,
                ),
                IconButton(icon: const Icon(Icons.chevron_right), tooltip: 'Next month', onPressed: goToNextMonth),
              ],
            ),
          ),

          // ── Day of Week Header ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            child: Row(
              children: _weekDays.map((name) {
                return Expanded(
                  child: Center(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
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
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalGridCells,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.85,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
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

                final dayEvents = eventsForDay(cellDate);

                return _DayCell(
                  date: cellDate,
                  isCurrentMonth: isThisMonth,
                  isToday: isToday,
                  isSelected: isSelected,
                  events: dayEvents,
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

          const Divider(height: 24),

          // ── Selected Day Event Summary List ───────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedDate != null) ...[
                  Text(
                    '${_monthNames[selectedDate.month - 1]} ${selectedDate.day}, ${selectedDate.year}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (selectedDayEvents.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No events scheduled for this day.',
                        style: TextStyle(color: Theme.of(context).colorScheme.outline),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedDayEvents.length,
                      itemBuilder: (context, index) {
                        final event = selectedDayEvents[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(Icons.event, color: Theme.of(context).colorScheme.primary),
                            title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: event.description != null && event.description!.isNotEmpty
                                ? Text(event.description!, maxLines: 2, overflow: TextOverflow.ellipsis)
                                : null,
                            trailing: Chip(
                              label: Text(event.type.name, style: const TextStyle(fontSize: 11)),
                              padding: EdgeInsets.zero,
                            ),
                            onTap: onEventTap != null ? () => onEventTap!(event) : null,
                          ),
                        );
                      },
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.events,
    required this.onTap,
  });

  final DateTime date;
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
      backgroundColor = colorScheme.primaryContainer.withValues(alpha: 0.4);
    } else if (events.isNotEmpty && isCurrentMonth) {
      backgroundColor = colorScheme.surfaceContainerLow;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : isToday
                ? colorScheme.primary.withValues(alpha: 0.5)
                : colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Day number header
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: isToday ? BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle) : null,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isToday
                        ? colorScheme.onPrimary
                        : !isCurrentMonth
                        ? colorScheme.outline
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Event summaries inside day cell
            Expanded(
              child: events.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: events.length > 2 ? 2 : events.length,
                      itemBuilder: (context, idx) {
                        final event = events[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 1),
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onPrimaryContainer,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
            ),
            if (events.length > 2)
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '+${events.length - 2}',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
