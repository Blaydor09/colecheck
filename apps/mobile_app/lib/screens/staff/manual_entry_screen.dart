import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/student_card.dart';
import '../../widgets/status_chip.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final List<Map<String, dynamic>> _mockStudents = [
    {'name': 'Juan Pérez', 'grade': '3ro Secundaria', 'status': StatusType.pending},
    {'name': 'María Gómez', 'grade': '1ro Secundaria', 'status': StatusType.present},
    {'name': 'Carlos Díaz', 'grade': '5to Primaria', 'status': StatusType.pending},
    {'name': 'Ana Silva', 'grade': '2do Secundaria', 'status': StatusType.absent},
    {'name': 'Emma Thompson', 'grade': '5to Secundaria', 'status': StatusType.late},
  ];

  String _searchQuery = '';

  void _markAttendance(int index, StatusType newStatus) {
    setState(() {
      _mockStudents[index]['status'] = newStatus;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estado actualizado a ${newStatus.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _mockStudents.where((s) {
      return s['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                
                // Original index in _mockStudents to update the real state
                final realIndex = _mockStudents.indexOf(student);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        StudentCard(
                          name: student['name'],
                          grade: student['grade'],
                          imageUrl: '',
                          status: student['status'],
                          time: '--:--',
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              'Ingreso',
                              AppTheme.successColor,
                              () => _markAttendance(realIndex, StatusType.present),
                            ),
                            _buildActionButton(
                              'Retraso',
                              AppTheme.warningColor,
                              () => _markAttendance(realIndex, StatusType.late),
                            ),
                            _buildActionButton(
                              'Falta',
                              AppTheme.accentColor,
                              () => _markAttendance(realIndex, StatusType.absent),
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
