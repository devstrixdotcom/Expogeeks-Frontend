import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

const String expogeeksSiteUrl = 'https://www.expogeeks.co.uk';

/// Public ticket page for a show. `tickets.php` identifies the show by
/// `exhibitionId`, base64 of the `organizer_exhibition` row id — the same link
/// the backend builds itself in `GetOrganizerDetails.php` (`redirectLink`).
/// Passing `organizerId` instead, or a category id in place of the exhibition
/// id, makes the page bounce straight back to the site home.
///
/// Falls back to the site home when the caller has no exhibition id, so a
/// share never carries a link that points at the wrong show.
String ticketsUrlForShow(String? exhibitionId) {
  if (exhibitionId == null || exhibitionId.isEmpty) return expogeeksSiteUrl;
  return '$expogeeksSiteUrl/tickets.php'
      '?exhibitionId=${base64Encode(utf8.encode(exhibitionId))}';
}

/// iOS refuses to open the share sheet unless `sharePositionOrigin` is a
/// non-empty rect inside the Flutter view (share_plus returns a
/// "sharePositionOrigin: argument must be set" PlatformException and nothing
/// is presented). Android ignores the argument, which is why the same call
/// works there. Always go through these helpers instead of calling
/// `Share.share` directly.
Rect sharePositionOriginFrom(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  if (box != null && box.hasSize) {
    return box.localToGlobal(Offset.zero) & box.size;
  }
  // Fallback: anchor to the middle of the screen so the rect is still
  // non-empty and inside the view.
  final size = MediaQuery.of(context).size;
  return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2), width: 1, height: 1);
}

/// Opens the platform share sheet. [context] should belong to the widget the
/// share sheet is anchored to (the share button) so the iPad popover points at
/// it; any widget context on screen works otherwise.
Future<void> shareTextFrom(BuildContext context, String text,
    {String? subject}) async {
  await Share.share(
    text,
    subject: subject,
    sharePositionOrigin: sharePositionOriginFrom(context),
  );
}
