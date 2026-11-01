import 'dart:async';

import 'package:aclub2/utils/avatar_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

/// Tracks how many requests are in flight at the same time.
class _TrackingClient() extends http.BaseClient {
  int active = 0;
  int maxActive = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    active++;
    if (active > maxActive) maxActive = active;
    // Give the event loop a chance to start every queued request.
    await Future<void>.delayed(const Duration(milliseconds: 5));
    active--;
    return http.StreamedResponse(const Stream<List<int>>.empty(), 200);
  }
}

void main() {
  group('AvatarHttpFileService concurrency', () {
    test('defaults to the shared avatar concurrency cap', () {
      final service = AvatarHttpFileService();
      expect(service.concurrentFetches, 4);
    });

    test('never exceeds the configured concurrent fetch limit', () async {
      final client = _TrackingClient();
      final service = AvatarHttpFileService(httpClient: client, concurrentFetches: 2);

      await Future.wait([
        for (var i = 0; i < 8; i++) service.get('https://example.com/avatar-$i.png'),
      ]);

      expect(client.maxActive, lessThanOrEqualTo(2));
      expect(client.maxActive, greaterThan(0));
    });

    test('retries transient failures while holding one concurrency slot', () async {
      final client = _FlakyClient();
      final service = AvatarHttpFileService(
        httpClient: client,
        concurrentFetches: 1,
        initialBackoff: Duration.zero,
      );

      final response = await service.get('https://example.com/avatar.png');

      expect(response.statusCode, 200);
      expect(client.attempts, 2);
    });
  });
}

class _FlakyClient() extends http.BaseClient {
  int attempts = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    attempts++;
    if (attempts == 1) {
      return http.StreamedResponse(const Stream<List<int>>.empty(), 503);
    }
    return http.StreamedResponse(const Stream<List<int>>.empty(), 200);
  }
}
