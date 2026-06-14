import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppMessage extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback? onDismiss;

  const AppMessage({
    super.key,
    required this.message,
    this.isError = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isError ? AppColors.errorBg : AppColors.successBg;
    final borderColor = isError ? AppColors.errorBorder : AppColors.successBorder;
    final contentColor = isError ? AppColors.errorText : AppColors.successText;
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: contentColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: contentColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, size: 16, color: contentColor),
            ),
          ],
        ],
      ),
    );
  }
}
