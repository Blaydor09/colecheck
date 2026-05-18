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
            
            const StudentCard(
              name: 'Juan Pérez',
              grade: '3ro Secundaria',
              imageUrl: '',
              status: StatusType.present,
              time: '07:55 AM',
            ),
            const SizedBox(height: 16),
            const StudentCard(
              name: 'María Pérez',
              grade: '1ro Secundaria',
              imageUrl: '',
              status: StatusType.absent,
              time: 'Pendiente',
            ),
            
            const SizedBox(height: 32),
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
