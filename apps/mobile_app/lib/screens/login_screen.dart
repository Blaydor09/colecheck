import 'package:flutter/material.dart';
import '../widgets/primary_button.dart';
import 'parent_dashboard.dart';
import 'staff/scanner_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Text(
                'Bienvenido a\nColecheck',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Portal para Padres y Apoderados',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico o DNI',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Entrar como Padre/Apoderado',
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ParentDashboard()),
                  );
                },
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                text: 'Entrar como Personal (Escáner)',
                isGhost: true,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ScannerScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
