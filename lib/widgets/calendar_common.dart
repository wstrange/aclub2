import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_models/shared_models.dart';

import '../repo.dart';

/// Filter selection for calendar events: all events or only events associated with the user.
enum CalendarEventFilter() {
  all,
  mine,
}

/// Full month names (January–December).
const List<String> calendarMonthNames = [
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

/// Abbreviated month names (Jan–Dec).
const List<String> calendarShortMonthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Full weekday names starting with Sunday.
const List<String> calendarWeekDayNames = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

/// Abbreviated weekday names starting with Sunday.
const List<String> calendarShortWeekDayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

/// Checks if an [event] spans across or occurs on [day].
bool isEventOnDay(Event event, DateTime day) {
  final target = DateTime(day.year, day.month, day.day);
  final startNorm = DateTime(event.startDate.year, event.startDate.month, event.startDate.day);
  final endNorm = DateTime(event.endDate.year, event.endDate.month, event.endDate.day);
  return target.compareTo(startNorm) >= 0 && target.compareTo(endNorm) <= 0;
}

/// Returns all events from [events] that occur on [day].
List<Event> getEventsForDay(List<Event> events, DateTime day) {
  return events.where((e) => isEventOnDay(e, day)).toList();
}

/// Whether [event] has already ended (its end date/time is in the past).
/// Registration is closed for past events.
bool isEventPast(Event event, [DateTime? now]) {
  return event.endDate.isBefore(now ?? DateTime.now());
}

/// Whether every event in [events] has already ended. An empty list is not
/// considered past — callers should check [events].isEmpty separately.
bool allEventsPast(List<Event> events, [DateTime? now]) {
  return events.isNotEmpty && events.every((e) => isEventPast(e, now));
}

/// Checks whether an event is associated with [userId]
/// (as creator, trip leader, or registered participant).
bool isUserEvent({required Event event, required String? userId, required Set<String> registeredEventIds}) {
  if (userId == null) return false;
  final isCreator = event.creatorId == userId;
  final isLeader = event.tripLeaderIds.contains(userId);
  final isRegistered = registeredEventIds.contains(event.id);
  return isCreator || isLeader || isRegistered;
}

/// Filters [events] according to [filter].
List<Event> filterCalendarEvents({
  required List<Event> events,
  required CalendarEventFilter filter,
  required String? userId,
  required Set<String> registeredEventIds,
}) {
  if (filter == CalendarEventFilter.all || userId == null) {
    return events;
  }
  return events
      .where((event) => isUserEvent(event: event, userId: userId, registeredEventIds: registeredEventIds))
      .toList();
}

/// Represents the loaded stream state for calendar views.
class const CalendarEventsState({
  required final List<Event> events,
  required final List<Event> filteredEvents,
  required final Set<String> registeredEventIds,
  required final String? currentUserId,
  required final bool isLoading,
  required final Object? error,
});

/// Hook that loads section events, user registrations, and provides filtered events.
CalendarEventsState useCalendarEvents({
  required String sectionId,
  String? userId,
  required CalendarEventFilter filter,
}) {
  final currentUserId = userId ?? FirebaseAuth.instance.currentUser?.uid;

  final eventsStream = useMemoized(() => repository.streamSectionEvents(sectionId), [sectionId]);
  final eventsSnapshot = useStream(eventsStream);

  final registrationsStream = useMemoized(
    () =>
        currentUserId != null ? repository.streamUserRegisteredEventIds(currentUserId) : Stream.value(const <String>{}),
    [currentUserId],
  );
  final registrationsSnapshot = useStream(registrationsStream);
  final registeredEventIds = registrationsSnapshot.data ?? const <String>{};

  final events = eventsSnapshot.data ?? const <Event>[];

  final filteredEvents = useMemoized(
    () => filterCalendarEvents(
      events: events,
      filter: filter,
      userId: currentUserId,
      registeredEventIds: registeredEventIds,
    ),
    [events, filter, currentUserId, registeredEventIds],
  );

  final isLoading = eventsSnapshot.connectionState == ConnectionState.waiting && !eventsSnapshot.hasData;
  final error = eventsSnapshot.error;

  return CalendarEventsState(
    events: events,
    filteredEvents: filteredEvents,
    registeredEventIds: registeredEventIds,
    currentUserId: currentUserId,
    isLoading: isLoading,
    error: error,
  );
}

/// Standard centered layout container with max width constraint for calendar views.
class const CalendarScaffold({super.key, required this.child, this.maxWidth = 650}) extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Standard error display for calendar widgets.
class const CalendarErrorView({super.key, required this.error}) extends StatelessWidget {
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error loading events: $error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ),
    );
  }
}

/// Responsive month navigation header shared between monthly calendar and agenda views.
class const CalendarMonthHeader({
  super.key,
  required this.displayedMonth,
  required this.filter,
  required this.onFilterChanged,
  required this.onPreviousMonth,
  required this.onNextMonth,
  required this.onToday,
}) extends StatelessWidget {
  final DateTime displayedMonth;
  final CalendarEventFilter filter;
  final ValueChanged<CalendarEventFilter> onFilterChanged;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = displayedMonth.year;
    final month = displayedMonth.month;
    final isCurrentMonth = now.year == year && now.month == month;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 450;
        final isVeryNarrow = constraints.maxWidth < 380;
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 8, 4),
          child: Row(
            children: [
              Text(
                '${isNarrow ? calendarShortMonthNames[month - 1] : calendarMonthNames[month - 1]} $year',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isNarrow ? 14 : null,
                ),
              ),
              const Spacer(),
              // ── Filter Segmented Button (All events / My events) ─
              SegmentedButton<CalendarEventFilter>(
                segments: [
                  ButtonSegment<CalendarEventFilter>(
                    value: CalendarEventFilter.all,
                    label: Text(isVeryNarrow ? 'All' : 'All events', style: const TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment<CalendarEventFilter>(
                    value: CalendarEventFilter.mine,
                    label: Text(isVeryNarrow ? 'Mine' : 'My events', style: const TextStyle(fontSize: 11)),
                  ),
                ],
                selected: {filter},
                onSelectionChanged: (newSelection) {
                  if (newSelection.isNotEmpty) {
                    onFilterChanged(newSelection.first);
                  }
                },
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: isVeryNarrow ? 6 : 10)),
                ),
              ),
              const Spacer(),
              if (!isCurrentMonth)
                if (isNarrow)
                  IconButton(
                    icon: const Icon(Icons.today, size: 20),
                    tooltip: 'Today',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
                    onPressed: onToday,
                  )
                else
                  TextButton(
                    onPressed: onToday,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text('Today'),
                  ),
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 22),
                tooltip: 'Previous month',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
                onPressed: onPreviousMonth,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 22),
                tooltip: 'Next month',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
                onPressed: onNextMonth,
              ),
            ],
          ),
        );
      },
    );
  }
}
