import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum StatusType { present, absent, late, pending }

class StatusChip extends StatelessWidget {
  final StatusType status;
  final String? label;

  const StatusChip({
    super.key,
    required this.status,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String defaultLabel;

    switch (status) {
      case StatusType.present:
        backgroundColor = AppTheme.successColor.withOpacity(0.15);
        textColor = AppTheme.successDarkColor;
        defaultLabel = 'Ingreso';
        break;
      case StatusType.absent:
        backgroundColor = AppTheme.accentColor.withOpacity(0.15);
        textColor = AppTheme.primaryColor; // Or secondary red if defined
        defaultLabel = 'Falta';
        break;
      case StatusType.late:
        backgroundColor = AppTheme.warningColor.withOpacity(0.2);
        textColor = AppTheme.warningDarkColor;
        defaultLabel = 'Retraso';
        break;
      case StatusType.pending:
        backgroundColor = AppTheme.borderColor.withOpacity(0.3);
        textColor = AppTheme.onSurfaceVariantColor;
        defaultLabel = 'Pendiente';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label ?? defaultLabel,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
