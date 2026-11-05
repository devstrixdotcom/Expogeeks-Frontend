import 'package:event_pro/utils/color.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/utils/images.dart';
import 'package:event_pro/view/authScreen/login_screen.dart';
import 'package:event_pro/scanner/view/authScreen/login_screen.dart' as scanner;
import 'package:flutter/material.dart';

/// First screen shown to a signed-out user.
///
/// Visitors / exhibitors are the main audience, so they get the large primary
/// card. Event staff (the QR scanner) are a small minority and get a quiet
/// one-line link pinned to the bottom.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _openVisitorLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _openStaffLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => scanner.LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double fw(double v) => convertFigmaToUIWidth(v, width) ?? v;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              // Fill the screen so the staff link sits at the very bottom,
              // but still scroll on short devices.
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: fw(22)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: fw(16)),
                      Image.asset(
                        loginScreenImg,
                        height: fw(250),
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: fw(18)),
                      Text(
                        'Welcome to Expo Geeks',
                        style: TextStyle(
                          fontSize: fw(26),
                          fontWeight: FontWeight.w600,
                          color: brownText,
                        ),
                      ),
                      SizedBox(height: fw(6)),
                      Text(
                        'Discover shows, connect with exhibitors and keep '
                        'your badge handy, all in one place.',
                        style: TextStyle(
                          fontSize: fw(15),
                          height: 1.4,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: fw(24)),
                      _VisitorCard(onTap: () => _openVisitorLogin(context)),
                      const Spacer(),
                      SizedBox(height: fw(20)),
                      _StaffLink(onTap: () => _openStaffLogin(context)),
                      SizedBox(height: fw(10)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The primary, prominent entry point.
class _VisitorCard extends StatelessWidget {
  final VoidCallback onTap;

  const _VisitorCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double fw(double v) => convertFigmaToUIWidth(v, width) ?? v;
    final radius = BorderRadius.circular(fw(24));

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff03A3AB), cyangreen, Color(0xff016F75)],
        ),
        boxShadow: [
          BoxShadow(
            color: cyangreen.withOpacity(0.30),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(fw(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: fw(52),
                      height: fw(52),
                      decoration: BoxDecoration(
                        color: white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.groups_rounded,
                        color: white,
                        size: fw(28),
                      ),
                    ),
                    SizedBox(width: fw(14)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Visitor / Exhibitor',
                            style: TextStyle(
                              fontSize: fw(20),
                              fontWeight: FontWeight.w700,
                              color: white,
                            ),
                          ),
                          SizedBox(height: fw(2)),
                          Text(
                            'Sign in with your email',
                            style: TextStyle(
                              fontSize: fw(13),
                              color: white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: fw(16)),
                Wrap(
                  spacing: fw(8),
                  runSpacing: fw(8),
                  children: [
                    _FeatureChip(icon: Icons.event_outlined, label: 'Shows'),
                    _FeatureChip(
                        icon: Icons.storefront_outlined, label: 'Exhibitors'),
                    _FeatureChip(
                        icon: Icons.handshake_outlined, label: 'Meetings'),
                    _FeatureChip(icon: Icons.badge_outlined, label: 'Badge'),
                  ],
                ),
                SizedBox(height: fw(20)),
                Container(
                  height: fw(52),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(fw(30)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: fw(16),
                          fontWeight: FontWeight.w600,
                          color: cyangreen,
                        ),
                      ),
                      SizedBox(width: fw(8)),
                      Icon(Icons.arrow_forward_rounded,
                          color: cyangreen, size: fw(20)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double fw(double v) => convertFigmaToUIWidth(v, width) ?? v;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: fw(10), vertical: fw(6)),
      decoration: BoxDecoration(
        color: white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(fw(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: white, size: fw(15)),
          SizedBox(width: fw(5)),
          Text(
            label,
            style: TextStyle(fontSize: fw(12.5), color: white),
          ),
        ],
      ),
    );
  }
}

/// Low-key, single-line entry for event staff.
class _StaffLink extends StatelessWidget {
  final VoidCallback onTap;

  const _StaffLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double fw(double v) => convertFigmaToUIWidth(v, width) ?? v;

    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(fw(20)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: fw(14), vertical: fw(10)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_scanner_rounded,
                  size: fw(18), color: textColor.withOpacity(0.7)),
              SizedBox(width: fw(8)),
              Text(
                'Event staff? ',
                style: TextStyle(fontSize: fw(14), color: textColor),
              ),
              Text(
                'Open Scanner',
                style: TextStyle(
                  fontSize: fw(14),
                  fontWeight: FontWeight.w600,
                  color: cyangreen,
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: fw(20), color: cyangreen),
            ],
          ),
        ),
      ),
    );
  }
}
