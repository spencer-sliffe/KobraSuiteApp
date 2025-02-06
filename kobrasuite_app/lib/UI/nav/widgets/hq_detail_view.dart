/// UI/nav/widgets/hq_detail_view.dart

import 'package:flutter/material.dart';

class HQDetailView extends StatelessWidget {
  const HQDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
            Navigator.pop(context);
          }
        },
        child: Container(
          color: Colors.black.withOpacity(0.9),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'HQ Detail View',
                  style: TextStyle(color: Colors.white, fontSize: 28),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Notifications, progress tracking, animation placeholder',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}