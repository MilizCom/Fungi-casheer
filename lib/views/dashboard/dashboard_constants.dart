import 'package:flutter/material.dart';

class DashboardColors {
  static const Color bgCanvas = Color(0xFFF8F9FD);
  static const Color primaryColor = Color(0xFFFF8C00);
  static const Color secondaryColor = Color(0xFF2D3436);
  static const Color chartBlue = Color(0xFF54A0FF);
  static const Color chartPurple = Color(0xFF5F27CD);
  static const Color chartRed = Color(0xFFFF6B6B);
  static const Color chartGreen = Color(0xFF00B894);
}

class DashboardStyles {
  static TextStyle titleStyle() => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
}

class EmptyStateWidget extends StatelessWidget {
  final String text;
  const EmptyStateWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
