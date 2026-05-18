import 'package:flutter/material.dart';
import '../widgets/student_card.dart';
import '../widgets/status_chip.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, Carlos',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Asistencia de Hoy',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            
            // Renderización dinámica de estudiantes (Relación 1:N simulada)
            ...[
              {
                'name': 'Juan Pérez',
                'grade': '3ro Secundaria',
                'status': StatusType.present,
                'time': '07:55 AM',
              },
              {
                'name': 'María Pérez',
                'grade': '1ro Secundaria',
                'status': StatusType.absent,
                'time': 'Pendiente',
              }
            ].map((student) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: StudentCard(
                name: student['name'] as String,
                grade: student['grade'] as String,
                imageUrl: '',
                status: student['status'] as StatusType,
                time: student['time'] as String,
              ),
            )),
            
            const SizedBox(height: 16),
            Text(
              'Alertas Recientes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.error.withOpacity(0.05),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                title: const Text('Falta no justificada'),
                subtitle: const Text('María no registró ingreso hoy.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
