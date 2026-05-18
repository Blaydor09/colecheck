import 'package:flutter/material.dart';

class ManualAttendanceScreen extends StatelessWidget {
  const ManualAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist Manual'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          'Lista de estudiantes en desarrollo...',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
