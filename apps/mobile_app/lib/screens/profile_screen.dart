import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Carlos Pérez',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'carlos@ejemplo.com',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '+123456789',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            _buildSectionTitle(context, 'Mis Estudiantes'),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF0F0F0),
                  child: Text('J'),
                ),
                title: const Text('Juan Pérez'),
                subtitle: const Text('3ro Secundaria'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Vincular nuevo estudiante'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Configuración'),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Notificaciones'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Ayuda y Soporte'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
