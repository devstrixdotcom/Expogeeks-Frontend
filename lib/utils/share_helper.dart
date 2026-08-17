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
/// non-empty rect that lies fully inside the Flutter view. share_plus checks
/// `CGRectContainsRect(controller.view.frame, origin)` and returns a
/// "sharePositionOrigin: argument must be set" PlatformException without
/// presenting anything when it fails — and because UIKit hands out a
/// popoverPresentationController on iPhone too, that check runs on every
/// device, not just iPad. Android ignores the argument entirely, which is why
/// the same call works there. Always go through these helpers instead of
/// calling `Share.share` directly.
Rect sharePositionOriginFrom(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  // Keep a point of margin: the rect has to be *contained*, so one sitting
  // exactly on the edge is at the mercy of rounding.
  final safeArea =
      Rect.fromLTWH(0, 0, screenSize.width, screenSize.height).deflate(1);
  final fallback = Rect.fromCenter(center: safeArea.center, width: 1, height: 1);

  // Never cast blindly: a context taken from a `ListView.builder`/`.separated`
  // itemBuilder belongs to the sliver, so its render object is a RenderSliver,
  // and `as RenderBox` would throw a TypeError before the share is ever
  // attempted. Fall back to the centre of the screen in that case.
  final renderObject = context.findRenderObject();
  if (renderObject is! RenderBox) return fallback;
  final box = renderObject;
  if (!box.attached || !box.hasSize) return fallback;

  // A context from an itemBuilder belongs to the row, not the page, and a row
  // keeps its true coordinates while scrolled out of sight (Flutter builds
  // past the viewport via cacheExtent). Clamping is what keeps such a rect
  // from landing outside the view and killing the share sheet on iOS.
  final rect = (box.localToGlobal(Offset.zero) & box.size).intersect(safeArea);
  if (rect.isEmpty || !rect.isFinite) return fallback;
  return rect;
}

/// Opens the platform share sheet. [context] should belong to the widget the
/// share sheet is anchored to (the share button) so the iPad popover points at
/// it; any widget context on screen works otherwise.
Future<void> shareTextFrom(BuildContext context, String text,
    {String? subject}) async {
  final size = MediaQuery.of(context).size;
  final centred = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2), width: 1, height: 1);

  Rect origin;
  try {
    origin = sharePositionOriginFrom(context);
  } catch (e) {
    // Resolving the anchor must never be what stops a share.
    debugPrint('Could not resolve share origin, using centre: $e');
    origin = centred;
  }

  try {
    await Share.share(text, subject: subject, sharePositionOrigin: origin);
  } catch (e) {
    // Never let a rejected anchor swallow the share silently: retry from the
    // centre of the screen, which is always inside the view.
    debugPrint('Share failed with origin $origin, retrying centred: $e');
    if (origin == centred) return;
    try {
      await Share.share(text, subject: subject, sharePositionOrigin: centred);
    } catch (e) {
      debugPrint('Share failed: $e');
    }
  }
}
