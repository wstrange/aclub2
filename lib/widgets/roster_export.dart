import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_models/shared_models.dart';

import '../repo.dart';
import '../widgets/user_display.dart' show resolveUserDisplay;

/// Data holder for a single participant row in the roster.
class _ParticipantInfo({
  required this.name,
  required this.email,
  required this.phone,
  required this.emergencyContactName,
  required this.emergencyContactPhone,
  required this.emergencyContactRelation,
  required this.medicalConditions,
  required this.status,
  required this.isDriver,
  required this.needsRide,
}) {
  final String name;
  final String? email;
  final String? phone;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String? emergencyContactRelation;
  final String? medicalConditions;
  final RegistrationStatus status;
  final bool? isDriver;
  final bool? needsRide;
}

/// Fetches approved/attended registrations and their profiles, returning them
/// sorted alphabetically by display name.
Future<List<_ParticipantInfo>> _loadParticipants(String sectionId, String eventId) async {
  final registrations = await repository.getEventRegistrations(sectionId, eventId);
  final active = registrations
      .where(
        (r) =>
            r.status == RegistrationStatus.approved ||
            r.status == RegistrationStatus.attended ||
            r.status == RegistrationStatus.pending,
      )
      .toList();

  final userIds = active.map((r) => r.userId).toList();
  final profiles = await repository.getUserProfiles(userIds);

  final participants = active.map((r) {
    final profile = profiles[r.userId];
    return _ParticipantInfo(
      name: resolveUserDisplay(r.userId, profile),
      email: profile?.email,
      phone: profile?.phone,
      emergencyContactName: profile?.emergencyContactName ?? '',
      emergencyContactPhone: profile?.emergencyContactPhone ?? '',
      emergencyContactRelation: profile?.emergencyContactRelation,
      medicalConditions: profile?.medicalConditions,
      status: r.status,
      isDriver: r.isDriver,
      needsRide: r.needsRide,
    );
  }).toList()..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  return participants;
}

/// Formats the participant roster as a human-readable plain-text string.
String _formatAsText(Event event, List<_ParticipantInfo> participants) {
  final buf = StringBuffer();

  buf.writeln(event.title);
  buf.writeln('─' * 40);
  buf.writeln('Date: ${_fmtDate(event.startDate)} – ${_fmtDate(event.endDate)}');
  if (event.location?.description != null) {
    buf.writeln('Location: ${event.location!.description}');
  }
  if (event.carpoolOption != null) {
    buf.writeln('Carpool: ${_fmtDate(event.carpoolOption!.meetTime)} at ${event.carpoolOption!.meetPlace}');
  }
  buf.writeln();
  buf.writeln('Participants (${participants.length}):');
  buf.writeln('─' * 40);

  for (var i = 0; i < participants.length; i++) {
    final p = participants[i];
    buf.writeln('${i + 1}. ${p.name}');
    if (p.email != null && p.email!.isNotEmpty) buf.writeln('   📧 ${p.email}');
    if (p.phone != null && p.phone!.isNotEmpty) buf.writeln('   📱 ${p.phone}');
    final ecParts = <String>[
      p.emergencyContactName,
      if (p.emergencyContactRelation != null && p.emergencyContactRelation!.isNotEmpty)
        '(${p.emergencyContactRelation})',
      p.emergencyContactPhone,
    ].where((s) => s.isNotEmpty);
    if (ecParts.isNotEmpty) buf.writeln('   🚨 Emergency Contact: ${ecParts.join(' ')}');

    final carpoolParts = <String>[if (p.isDriver == true) '🚗 Driver', if (p.needsRide == true) '🙋 Needs ride'];
    if (carpoolParts.isNotEmpty) buf.writeln('   ${carpoolParts.join('  ')}');

    if (p.status == RegistrationStatus.pending) buf.writeln('   ⏳ Pending approval');

    buf.writeln();
  }

  buf.writeln('Generated: ${_fmtDate(DateTime.now())}');
  buf.writeln('⚠ This roster contains personal contact information — please keep it confidential.');
  return buf.toString();
}

/// Builds a PDF document for the roster.
Future<pw.Document> _buildPdf(Event event, List<_ParticipantInfo> participants) async {
  final pdf = pw.Document(title: '${event.title} – Participant Roster', author: 'Alpine Club');

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(40),
      header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(event.title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('${_fmtDate(event.startDate)} – ${_fmtDate(event.endDate)}', style: const pw.TextStyle(fontSize: 11)),
          if (event.location?.description != null)
            pw.Text('Location: ${event.location!.description}', style: const pw.TextStyle(fontSize: 11)),
          if (event.carpoolOption != null)
            pw.Text(
              'Carpool: ${_fmtDate(event.carpoolOption!.meetTime)} at ${event.carpoolOption!.meetPlace}',
              style: const pw.TextStyle(fontSize: 11),
            ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Participants: ${participants.length}',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(),
        ],
      ),
      footer: (context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'CONFIDENTIAL — Generated ${_fmtDate(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
      build: (context) => [
        pw.TableHelper.fromTextArray(
          headerAlignment: pw.Alignment.centerLeft,
          cellAlignment: pw.Alignment.centerLeft,
          headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          headers: ['#', 'Name', 'Phone', 'Email', 'Emergency Contact', 'EC Phone', 'Medical'],
          data: [
            for (var i = 0; i < participants.length; i++)
              [
                '${i + 1}',
                participants[i].name,
                participants[i].phone ?? '',
                participants[i].email ?? '',
                [
                  participants[i].emergencyContactName,
                  if (participants[i].emergencyContactRelation != null &&
                      participants[i].emergencyContactRelation!.isNotEmpty)
                    '(${participants[i].emergencyContactRelation})',
                ].join(' '),
                participants[i].emergencyContactPhone,
                participants[i].medicalConditions ?? '',
              ],
          ],
        ),
      ],
    ),
  );

  return pdf;
}

String _fmtDate(DateTime dt) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final weekday = weekdays[dt.weekday - 1];
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$weekday ${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} $hour:$minute';
}

/// Shows a bottom sheet with options to share the participant roster as text
/// or export it as a PDF. Intended to be called from the event detail page.
void showRosterExportSheet(BuildContext context, Event event) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Export Participant Roster',
              style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(event.title, style: Theme.of(sheetContext).textTheme.bodySmall),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share as Text'),
              subtitle: const Text('Shareable text for Messages, email, etc.'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _exportAsText(context, event);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Export PDF'),
              subtitle: const Text('Formatted PDF — print or save offline'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _exportAsPdf(context, event);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _exportAsText(BuildContext context, Event event) async {
  _showLoadingSnackBar(context, 'Preparing roster…');
  try {
    final participants = await _loadParticipants(event.sectionId, event.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No approved participants to export.')));
      return;
    }

    final text = _formatAsText(event, participants);
    await SharePlus.instance.share(ShareParams(text: text, subject: '${event.title} – Participant Roster'));
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to export roster: $e')));
    }
  }
}

Future<void> _exportAsPdf(BuildContext context, Event event) async {
  _showLoadingSnackBar(context, 'Generating PDF…');
  try {
    final participants = await _loadParticipants(event.sectionId, event.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No approved participants to export.')));
      return;
    }

    final pdf = await _buildPdf(event, participants);
    if (!context.mounted) return;

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $e')));
    }
  }
}

void _showLoadingSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text(message),
        ],
      ),
      duration: const Duration(seconds: 30),
    ),
  );
}
