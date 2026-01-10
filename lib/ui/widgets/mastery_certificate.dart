import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

/// Certificate Generator for Skill Mastery and Zone Completion
/// Creates beautiful, shareable certificates for achievements
class MasteryCertificate extends StatelessWidget {
  final String studentName;
  final String achievementType; // 'skill', 'zone', 'milestone'
  final String achievementName;
  final String date;
  final int starsEarned;
  final GlobalKey certificateKey = GlobalKey();

  MasteryCertificate({
    super.key,
    required this.studentName,
    required this.achievementType,
    required this.achievementName,
    required this.date,
    required this.starsEarned,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: certificateKey,
      child: Container(
        width: 600,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.amber, width: 8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative border pattern
            Positioned.fill(
              child: CustomPaint(
                painter: CertificateBorderPainter(),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  const Text(
                    'CERTIFICATE OF ACHIEVEMENT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // "Presented to"
                  const Text(
                    'This certificate is proudly presented to',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Student name
                  Text(
                    studentName,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Achievement
                  Text(
                    _getAchievementText(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Achievement name with emoji
                  Text(
                    '${_getEmoji()} $achievementName ${_getEmoji()}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stars earned
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⭐⭐⭐⭐⭐', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Text(
                        '$starsEarned Stars Earned',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('⭐⭐⭐⭐⭐', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // BrightBound signature
                  const Text(
                    'BrightBound Adventures',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),

            // Corner decorations
            Positioned(
              top: 20,
              left: 20,
              child: Text('🌟', style: TextStyle(fontSize: 32)),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Text('🌟', style: TextStyle(fontSize: 32)),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Text('🌟', style: TextStyle(fontSize: 32)),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Text('🌟', style: TextStyle(fontSize: 32)),
            ),
          ],
        ),
      ),
    );
  }

  String _getAchievementText() {
    switch (achievementType) {
      case 'skill':
        return 'for successfully mastering the skill';
      case 'zone':
        return 'for completing all challenges in';
      case 'milestone':
        return 'for reaching the incredible milestone of';
      default:
        return 'for outstanding achievement in';
    }
  }

  String _getEmoji() {
    switch (achievementType) {
      case 'skill':
        return '🏅';
      case 'zone':
        return '🗺️';
      case 'milestone':
        return '🎯';
      default:
        return '⭐';
    }
  }
}

/// Custom painter for decorative border
class CertificateBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw decorative lines in corners
    final cornerSize = 60.0;

    // Top-left
    canvas.drawLine(Offset(30, 30), Offset(30 + cornerSize, 30), paint);
    canvas.drawLine(Offset(30, 30), Offset(30, 30 + cornerSize), paint);

    // Top-right
    canvas.drawLine(Offset(size.width - 30, 30),
        Offset(size.width - 30 - cornerSize, 30), paint);
    canvas.drawLine(Offset(size.width - 30, 30),
        Offset(size.width - 30, 30 + cornerSize), paint);

    // Bottom-left
    canvas.drawLine(Offset(30, size.height - 30),
        Offset(30 + cornerSize, size.height - 30), paint);
    canvas.drawLine(Offset(30, size.height - 30),
        Offset(30, size.height - 30 - cornerSize), paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - 30, size.height - 30),
        Offset(size.width - 30 - cornerSize, size.height - 30), paint);
    canvas.drawLine(Offset(size.width - 30, size.height - 30),
        Offset(size.width - 30, size.height - 30 - cornerSize), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dialog to display and share certificate
class CertificateDialog extends StatelessWidget {
  final MasteryCertificate certificate;

  const CertificateDialog({
    super.key,
    required this.certificate,
  });

  Future<void> _shareCertificate(BuildContext context) async {
    try {
      // Find the RepaintBoundary
      RenderRepaintBoundary boundary =
          certificate.certificateKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      // Capture as image
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      await image.toByteData(format: ui.ImageByteFormat.png);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Certificate captured! You can save or share it.'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // In a full implementation, use share_plus package:
      // await Share.shareXFiles([XFile.fromData(pngBytes, mimeType: 'image/png')]);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing certificate: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🏆 Congratulations! 🏆',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              child: certificate,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _shareCertificate(context),
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to show certificate
void showMasteryCertificate(
  BuildContext context, {
  required String studentName,
  required String achievementType,
  required String achievementName,
  required int starsEarned,
}) {
  final now = DateTime.now();
  final date = '${now.month}/${now.day}/${now.year}';

  final certificate = MasteryCertificate(
    studentName: studentName,
    achievementType: achievementType,
    achievementName: achievementName,
    date: date,
    starsEarned: starsEarned,
  );

  showDialog(
    context: context,
    builder: (context) => CertificateDialog(certificate: certificate),
  );
}
