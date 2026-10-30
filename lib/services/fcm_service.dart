import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import '../repo.dart';
import '../routes.dart';

final _log = Logger('FcmService');

/// Sanitizes a string to conform to FCM topic naming rules:
/// `[a-zA-Z0-9-_.~%]{1,900}`.
String sanitizeTopicName(String input) =>
    input.replaceAll(RegExp(r'[^a-zA-Z0-9-_.~%]'), '_');

/// Builds the generic event topic name for a given section.
String sectionEventsTopic(String sectionId) =>
    'section_${sanitizeTopicName(sectionId)}_events';

/// Top-level background message handler invoked when the app receives a message
/// while in the background or terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  _log.fine('Handling background FCM message: ${message.messageId}, data=${message.data}');
}

/// Service managing Firebase Cloud Messaging permissions, device tokens,
/// topic subscriptions, and message-based navigation.
class FcmService() {
  static final FcmService instance = FcmService();

  String? _currentToken;
  StreamSubscription<String>? _onRegisteredSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;
  String? _activeUid;

  /// Whether FCM is supported on the current runtime platform.
  bool get isSupported {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  /// Whether topic subscriptions are supported on the current platform.
  /// FCM Web does not support client-side topic subscriptions.
  bool get isTopicSupported => isSupported && !kIsWeb;

  /// Initializes listeners for incoming messages and token changes.
  Future<void> initialize() async {
    if (!isSupported) {
      _log.info('FCM is not supported on this platform (${defaultTargetPlatform.name}).');
      return;
    }

    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Foreground message listener
      _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _log.info(
          'FCM foreground message received: title=${message.notification?.title}, data=${message.data}',
        );
      });

      // Background app open listener (user tapped notification while app was running in background)
      _onMessageOpenedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _log.info('App opened from FCM notification: data=${message.data}');
        _handleNotificationNavigation(message);
      });

      // Check if app was launched directly from a terminated state via notification tap
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _log.info('App launched from terminated state via FCM notification: data=${initialMessage.data}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleNotificationNavigation(initialMessage);
        });
      }

      // Listen for registration tokens
      _onRegisteredSub = FirebaseMessaging.instance.onRegistered.listen((newToken) async {
        _log.info('FCM registered token received');
        _currentToken = newToken;
        final uid = _activeUid;
        if (uid != null && uid.isNotEmpty) {
          try {
            await repository.addFcmToken(uid, newToken);
          } catch (e) {
            _log.warning('Failed to update FCM token in Firestore: $e');
          }
        }
      });
    } catch (e, st) {
      _log.warning('Failed to initialize FcmService: $e', e, st);
    }
  }

  /// Requests notification permissions from the operating system.
  Future<NotificationSettings?> requestPermission() async {
    if (!isSupported) return null;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      _log.info('Notification permission authorization status: ${settings.authorizationStatus}');
      return settings;
    } catch (e) {
      _log.warning('requestPermission failed: $e');
      return null;
    }
  }

  /// Registers the device instance and stores the token in the user's Firestore profile.
  Future<void> syncDeviceToken(String uid) async {
    if (!isSupported || uid.isEmpty) return;
    _activeUid = uid;

    try {
      await FirebaseMessaging.instance.register();
      _log.info('Requested FCM registration for user $uid');
    } catch (e) {
      _log.warning('syncDeviceToken failed for $uid: $e');
    }
  }

  /// Subscribes or unsubscribes to section event topics based on the user's
  /// preferences and memberships.
  Future<void> syncTopicSubscriptions({
    required List<String> memberSectionIds,
    required bool pushEnabled,
    required bool notifyForNewEvents,
  }) async {
    if (!isTopicSupported) {
      _log.fine('FCM topic subscriptions skipped: not supported on this platform.');
      return;
    }

    final shouldSubscribe = pushEnabled && notifyForNewEvents;

    for (final sectionId in memberSectionIds) {
      final topic = sectionEventsTopic(sectionId);
      try {
        if (shouldSubscribe) {
          await FirebaseMessaging.instance.subscribeToTopic(topic);
          _log.fine('Subscribed to topic: $topic');
        } else {
          await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
          _log.fine('Unsubscribed from topic: $topic');
        }
      } catch (e) {
        _log.warning('Error updating topic subscription for $topic: $e');
      }
    }
  }

  /// Handles sign out: cleans up device token from the user profile and unsubscribes from topics.
  Future<void> handleSignOut(String uid, {List<String> memberSectionIds = const []}) async {
    _activeUid = null;
    final token = _currentToken;

    if (token != null && token.isNotEmpty) {
      try {
        await repository.removeFcmToken(uid, token);
        _log.info('Removed FCM token for user $uid on sign out');
      } catch (e) {
        _log.warning('Failed to remove FCM token on sign out: $e');
      }
    }

    if (isTopicSupported && memberSectionIds.isNotEmpty) {
      for (final sectionId in memberSectionIds) {
        try {
          await FirebaseMessaging.instance.unsubscribeFromTopic(sectionEventsTopic(sectionId));
        } catch (_) {}
      }
    }
  }

  /// Deep links into an event when a notification is tapped.
  void _handleNotificationNavigation(RemoteMessage message) {
    final sectionId = message.data['sectionId']?.toString();
    final eventId = message.data['eventId']?.toString();

    if (sectionId != null && sectionId.isNotEmpty && eventId != null && eventId.isNotEmpty) {
      _log.info('Navigating to event: sectionId=$sectionId, eventId=$eventId');
      try {
        routerConfig.router.push(EventDetailRoute(sectionId: sectionId, eventId: eventId));
      } catch (e) {
        _log.warning('Failed to navigate to EventDetailRoute from notification: $e');
      }
    }
  }

  /// Disposes active subscriptions.
  void dispose() {
    _onRegisteredSub?.cancel();
    _onMessageSub?.cancel();
    _onMessageOpenedAppSub?.cancel();
  }
}

/// Global singleton instance of [FcmService].
final fcmService = FcmService.instance;
