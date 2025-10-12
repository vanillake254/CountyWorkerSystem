import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExitConfirmationWrapper extends StatelessWidget {
  final Widget child;
  final bool canExit;

  const ExitConfirmationWrapper({
    super.key,
    required this.child,
    this.canExit = true,
  });

  Future<bool> _showExitDialog(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!canExit) return false;
        
        final shouldExit = await _showExitDialog(context);
        if (shouldExit) {
          // Use platform-specific exit
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }
          return false;
        }
        return false;
      },
      child: child,
    );
  }
}
