import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VanillaBranding extends StatelessWidget {
  final bool compact;
  
  const VanillaBranding({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final url = Uri.parse('https://vanillasoftwares.web.app');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: compact ? 8 : 12,
          horizontal: compact ? 12 : 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.purple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Powered by ',
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 12 : 14,
              ),
            ),
            Text(
              'VANILLA SOFTWARES',
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.open_in_new,
              color: Colors.white,
              size: compact ? 14 : 16,
            ),
          ],
        ),
      ),
    );
  }
}
