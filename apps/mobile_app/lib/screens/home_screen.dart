import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';
import '../widgets/student_card.dart';
import '../widgets/status_chip.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = context.read<AppProvider>();
      if (appProvider.students.isEmpty && !appProvider.isLoading) {
        final authProvider = context.read<AuthProvider>();
        if (authProvider.user?.isGuardian == true) {
          appProvider.fetchParentData();
        } else {
          appProvider.fetchStaffData();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final appProvider = context.watch<AppProvider>();
    final userName = authProvider.user?.firstName ?? 'Usuario';

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
      body: appProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                if (authProvider.user?.isGuardian == true) {
                  await appProvider.fetchParentData();
                } else {
                  await appProvider.fetchStaffData();
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, $userName',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 28,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Asistencia de Hoy',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),

                    if (appProvider.students.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No se encontraron estudiantes vinculados.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      )
                    else
                      ...appProvider.students.map(
                        (student) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: StudentCard(
                            name: student.name,
                            grade: student.grade,
                            imageUrl: student.photoUrl ?? '',
                            status: student.todayStatus,
                            time: student.todayTime,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Show alerts for absent students
                    if (appProvider.students
                        .any((s) => s.todayStatus == StatusType.absent)) ...[
                      Text(
                        'Alertas Recientes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ...appProvider.students
                          .where((s) => s.todayStatus == StatusType.absent)
                          .map(
                            (student) => Card(
                              color: Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withOpacity(0.05),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .error
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.warning_amber_rounded,
                                    color:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                title: const Text('Falta no justificada'),
                                subtitle: Text(
                                    '${student.name} no registró ingreso hoy.'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {},
                              ),
                            ),
                          ),
                    ],

                    // Show alerts for pending students too
                    if (appProvider.students
                        .any((s) => s.todayStatus == StatusType.pending) && authProvider.user?.isGuardian == true) ...[
                      if (!appProvider.students.any((s) => s.todayStatus == StatusType.absent))
                        Text(
                          'Alertas Recientes',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      if (!appProvider.students.any((s) => s.todayStatus == StatusType.absent))
                        const SizedBox(height: 16),
                      ...appProvider.students
                          .where((s) => s.todayStatus == StatusType.pending)
                          .map(
                            (student) => Card(
                              color: Colors.orange.withOpacity(0.05),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.schedule,
                                    color: Colors.orange,
                                  ),
                                ),
                                title: const Text('Pendiente de registro'),
                                subtitle: Text(
                                    '${student.name} aún no ha registrado ingreso.'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {},
                              ),
                            ),
                          ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
