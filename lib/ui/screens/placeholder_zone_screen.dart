import 'package:flutter/material.dart';

class PlaceholderZoneScreen extends StatelessWidget {
  final String zoneName;

  const PlaceholderZoneScreen({
    Key? key,
    required this.zoneName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(zoneName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '$zoneName - Coming Soon',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Map'),
            ),
          ],
        ),
      ),
    );
  }
}
