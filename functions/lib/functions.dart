import 'dart:convert';
import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';
import 'package:aclub_admin/admin_repo.dart';

/// Health check Cloud Function.
@CloudFunction()
Response helloWorld(Request request) {
  return Response.ok('Hello from aclub Dart Functions!');
}

/// Admin Seeding Cloud Function: `/adminSeed?reset=true`
@CloudFunction()
Future<Response> adminSeed(Request request) async {
  final repo = AdminRepository();
  try {
    final reset = request.url.queryParameters['reset'] == 'true';
    if (reset) {
      await repo.resetAll();
    }
    final result = await repo.seedAll();
    return Response.ok(
      jsonEncode({
        'status': 'success',
        'message': 'Database seeded successfully',
        'data': result,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'status': 'error', 'message': e.toString()}),
      headers: {'Content-Type': 'application/json'},
    );
  } finally {
    await repo.close();
  }
}

/// Admin Stats Cloud Function: `/adminStats`
@CloudFunction()
Future<Response> adminStats(Request request) async {
  final repo = AdminRepository();
  try {
    final stats = await repo.getStats();
    return Response.ok(
      jsonEncode({
        'status': 'success',
        'stats': stats,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'status': 'error', 'message': e.toString()}),
      headers: {'Content-Type': 'application/json'},
    );
  } finally {
    await repo.close();
  }
}
