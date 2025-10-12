import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExitConfirmationWrapper extends StatefulWidget {
  final Widget child;
  final bool canExit;

  const ExitConfirmationWrapper({
    super.key,
    required this.child,
    this.canExit = true,
  });

  @override
  State<ExitConfirmationWrapper> createState() => _ExitConfirmationWrapperState();
}

class _ExitConfirmationWrapperState extends State<ExitConfirmationWrapper> {
  Timer? _exitTimer;
  int _countdown = 5;
  bool _isCountingDown = false;

  @override
  void dispose() {
    _exitTimer?.cancel();
    super.dispose();
  }

  void _startExitCountdown() {
    if (_isCountingDown) return;

    setState(() {
      _isCountingDown = true;
      _countdown = 5;
    });

    // Show snackbar with countdown
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('App will auto exit in'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_countdown',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'CANCEL',
          textColor: Colors.white,
          onPressed: () {
            _cancelExit();
          },
        ),
        backgroundColor: Colors.black87,
      ),
    );

    // Start countdown timer
    _exitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown > 0) {
        // Update snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('App will auto exit in'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_countdown',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            duration: Duration(seconds: _countdown),
            action: SnackBarAction(
              label: 'CANCEL',
              textColor: Colors.white,
              onPressed: () {
                _cancelExit();
              },
            ),
            backgroundColor: Colors.black87,
          ),
        );
      } else {
        // Exit the app
        timer.cancel();
        SystemNavigator.pop();
      }
    });
  }

  void _cancelExit() {
    _exitTimer?.cancel();
    setState(() {
      _isCountingDown = false;
      _countdown = 5;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        
        if (!widget.canExit) {
          return;
        }
        
        _startExitCountdown();
      },
      child: widget.child,
    );
  }
}
