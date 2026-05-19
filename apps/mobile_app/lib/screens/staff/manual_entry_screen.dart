import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/student_card.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  String _searchQuery = '';
  String? _processingStudentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = context.read<AppProvider>();
      if (appProvider.students.isEmpty && !appProvider.isLoading) {
        appProvider.fetchStaffData();
      }
    });
  }

  Future<void> _markAttendance(String studentId, String status) async {
    setState(() => _processingStudentId = studentId);

    final appProvider = context.read<AppProvider>();
    final success = await appProvider.recordAttendance(
      studentId: studentId,
      method: 'manual',
      direction: 'entry',
    );

    if (!mounted) return;
    setState(() => _processingStudentId = null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Asistencia registrada exitosamente'
              : 'Error al registrar asistencia',
        ),
        backgroundColor: success ? AppTheme.successColor : AppTheme.accentColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    final filteredStudents = appProvider.students.where((s) {
      return s.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Manual'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o ID...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: appProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredStudents.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'No se encontraron estudiantes.'
                              : 'No hay estudiantes registrados.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => appProvider.fetchStaffData(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                            final isProcessing =
                                _processingStudentId == student.id;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    StudentCard(
                                      name: student.name,
                                      grade: student.grade,
                                      imageUrl: student.photoUrl ?? '',
                                      status: student.todayStatus,
                                      time: student.todayTime,
                                    ),
                                    const Divider(),
                                    if (isProcessing)
                                      const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8),
                                        child: CircularProgressIndicator(),
                                      )
                                    else
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildActionButton(
                                            'Ingreso',
                                            AppTheme.successColor,
                                            () => _markAttendance(
                                                student.id, 'present'),
                                          ),
                                          _buildActionButton(
                                            'Retraso',
                                            AppTheme.warningColor,
                                            () => _markAttendance(
                                                student.id, 'late'),
                                          ),
                                          _buildActionButton(
                                            'Falta',
                                            AppTheme.accentColor,
                                            () => _markAttendance(
                                                student.id, 'absent'),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      child: Text(label),
    );
  }
}
