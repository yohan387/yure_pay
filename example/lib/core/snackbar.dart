import 'package:flutter/material.dart';

class AppSnackBar {
  static void success(BuildContext context, String message) {
    _show(context, message, Icons.check_circle, Colors.green);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, Icons.error_outline, Colors.red);
  }

  static void warning(BuildContext context, String message) {
    _show(context, message, Icons.warning_amber, Colors.orange);
  }

  static void _show(
    BuildContext context,
    String message,
    IconData icon,
    Color color,
  ) {
    final snackBar = SnackBar(
      backgroundColor: Colors.black,
      content: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
