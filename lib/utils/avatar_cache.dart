// Avatar image caching plumbing.
//
// Why this exists: profile photos are served from Google's avatar CDN
// (lh3.googleusercontent.com), which rate-limits request bursts per IP with
// HTTP 429. The members directory mounts up to 40 avatars at once, and
// Flutter's default in-memory `ImageCache` never persists across app
// restarts, so every cold start re-fetched every avatar from Google.
//
// The pieces below fix both halves:
//
//  * [AvatarHttpFileService] caps concurrent downloads (the cache manager
//    queues the rest) and transparently retries throttled responses with
//    proper backoff, honoring the `Retry-After` header when present.
//  * [avatarCacheManager] persists downloads on disk for
//    [avatarCacheStalePeriod], so avatars that were fetched once keep working
//    offline-ish and don't re-hit Google on subsequent launches.
import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

// Cap in-flight avatar downloads; the cache manager queues beyond this, so a
// 40-tile directory never hammers the CDN in a single burst.
const int _maxConcurrentFetches = 4;

// Google rotates the avatar URL when a user changes their photo, so the URL
// is the version key — cache entries never need revalidation. Served
// `max-age` is only 24h, which would still re-fetch on most launches, so
// entries are marked valid far longer than that; the disk prune keeps the
// cache bounded via [avatarCacheStalePeriod].
const Duration avatarCacheStalePeriod = Duration(days: 30);

/// The disk-backed cache manager used by [UserAvatar].
final BaseCacheManager avatarCacheManager = CacheManager(
  Config(
    'user_avatars',
    fileService: AvatarHttpFileService(),
    // Prune cache objects after this period to bound disk use. This is
    // intentionally generous: the entries' `validTill` matches it, so
    // launch-to-launch re-fetches don't happen at all within the window.
    stalePeriod: avatarCacheStalePeriod,
    maxNrOfCacheObjects: 5000,
  ),
);

/// [HttpFileService] tuned for the Google avatar CDN: bounded concurrency,
/// retry-with-backoff on HTTP 429/5xx, and disk entries that stay valid for
/// [avatarCacheStalePeriod] instead of the server's short `max-age`.
// Primary-constructor heads can't set the base class's `concurrentFetches`
// mutable field, so use a classic constructor with the lint opt-out below.
class AvatarHttpFileService extends HttpFileService {
  // ignore: use_primary_constructors
  AvatarHttpFileService({http.Client? httpClient, this.maxRetries = 3, Duration? initialBackoff})
    : _httpClient = httpClient ?? http.Client(),
      _initialBackoff = initialBackoff ?? const Duration(milliseconds: 500) {
    concurrentFetches = _maxConcurrentFetches;
  }

  final http.Client _httpClient;

  /// Retries for throttled / transient server errors before giving up and
  /// letting the widget's error widget show the fallback.
  final int maxRetries;

  final Duration _initialBackoff;

  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers}) async {
    var attempt = 0;
    while (true) {
      final request = http.Request('GET', Uri.parse(url));
      if (headers != null) request.headers.addAll(headers);
      final response = await _httpClient.send(request);

      final retriable = response.statusCode == 429 || (response.statusCode >= 500 && response.statusCode < 600);
      if (!retriable || attempt >= maxRetries) {
        if (retriable) {
          // Setup never succeeded; final attempt also failed — report the
          // status as-is so the caller's error path handles it.
        }
        return AvatarHttpGetResponse(response);
      }

      // Free the unused response body before waiting.
      await response.stream.drain<void>();
      await Future.delayed(_backoffDelay(response.headers['retry-after'], attempt));
      attempt++;
    }
  }

  Duration _backoffDelay(String? retryAfter, int attempt) {
    // Honor the server hint when it is a plain seconds count.
    final retryAfterSeconds = int.tryParse(retryAfter ?? '');
    if (retryAfterSeconds != null && retryAfterSeconds > 0) {
      return Duration(seconds: retryAfterSeconds);
    }
    // Exponential backoff with jitter: 0.5s, 1s, 2s, ...
    final backoffMs = _initialBackoff.inMilliseconds * (1 << attempt);
    final jitterMs = backoffMs * (DateTime.now().microsecondsSinceEpoch % 125) ~/ 1000;
    return Duration(milliseconds: backoffMs + jitterMs);
  }
}

/// Like [HttpGetResponse] but keeps the disk entry valid for
/// [avatarCacheStalePeriod] regardless of the server's `max-age`, so
/// launches don't re-download every avatar after the CDN's 24h TTL lapses.
//// Disk entry for an avatar download with a long-lived validity that
/// overrides the server's short `max-age`, matching [avatarCacheStalePeriod].
class AvatarHttpGetResponse extends HttpGetResponse {
  // Classic super-param constructor (lint opt-out below).
  // ignore: use_primary_constructors
  AvatarHttpGetResponse(super.response);

  @override
  DateTime get validTill => DateTime.now().add(avatarCacheStalePeriod);
}
