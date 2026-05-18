import 'package:flutter/material.dart';
import '../widgets/status_chip.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Asistencia'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 10,
        itemBuilder: (context, index) {
          // Mock data generation
          final isLate = index == 2;
          final isAbsent = index == 5;
          final status = isAbsent ? StatusType.absent : (isLate ? StatusType.late : StatusType.present);
          final timeStr = isAbsent ? '--:--' : (isLate ? '08:15 AM' : '07:${45 + (index % 10)} AM');
          final dateStr = '1${9 - index} de Mayo, 2026';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                dateStr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Ingreso: $timeStr'),
              trailing: StatusChip(status: status),
            ),
          );
        },
      ),
    );
  }
}
