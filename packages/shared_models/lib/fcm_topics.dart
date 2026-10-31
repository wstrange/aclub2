/// FCM topic naming shared by the Flutter client and the Cloud Functions
/// backend.
///
/// These live in `shared_models` so the publisher (functions) and the
/// subscriber (client) can never silently disagree about a topic name. A
/// mismatch would mean notifications are sent to a topic nobody is listening
/// on, which is hard to spot at runtime.
library;

/// Sanitizes a string to conform to FCM topic naming rules:
/// `[a-zA-Z0-9-_.~%]{1,900}`.
String sanitizeTopicName(String input) =>
    input.replaceAll(RegExp(r'[^a-zA-Z0-9-_.~%]'), '_');

/// Builds the generic event topic name for a given section.
String sectionEventsTopic(String sectionId) =>
    'section_${sanitizeTopicName(sectionId)}_events';
