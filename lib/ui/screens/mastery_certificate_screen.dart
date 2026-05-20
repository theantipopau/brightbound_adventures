import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:brightbound_adventures/core/services/avatar_provider.dart';

class MasteryCertificateScreen extends StatelessWidget {
  final String zoneId;
  final String zoneName;
  final Color themeColor;

  const MasteryCertificateScreen({
    super.key,
    required this.zoneId,
    required this.zoneName,
    required this.themeColor,
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final avatar = context.watch<AvatarProvider>().avatar;
    final trimmedName = avatar?.name.trim() ?? '';
    final studentName = trimmedName.isNotEmpty ? trimmedName : 'Brave Explorer';
    final issuedOn = _formatDate(DateTime.now());
    final certificateId =
        '${zoneId.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mastery Certificate'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeColor.withValues(alpha: 0.1),
              Colors.white,
              themeColor.withValues(alpha: 0.06),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: themeColor.withValues(alpha: 0.35),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withValues(alpha: 0.18),
                          blurRadius: 28,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'CERTIFICATE OF MASTERY',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                            color: Color(0xFF4A4F73),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          height: 2,
                          width: 180,
                          color: themeColor.withValues(alpha: 0.45),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'This certifies that',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666A88),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          studentName,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: themeColor,
                            letterSpacing: 0.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'has successfully mastered',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666A88),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          zoneName,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2A2D45),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Outstanding Learning Achievement',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3E4463),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            Expanded(
                              child: _SignatureBlock(
                                title: 'Issued On',
                                value: issuedOn,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SignatureBlock(
                                title: 'Certificate ID',
                                value: certificateId,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Share/export coming in next update.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.workspace_premium),
                        label: const Text('Celebrate'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignatureBlock extends StatelessWidget {
  final String title;
  final String value;

  const _SignatureBlock({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 1.5,
          width: double.infinity,
          color: const Color(0xFF8D91AC),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF434766),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF7D829E),
          ),
        ),
      ],
    );
  }
}
