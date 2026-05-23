import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'parent_dashboard.dart';
import 'teacher_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.tryRestoreSession();

    if (!mounted) return;

    // Small delay for splash branding
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    if (authProvider.isAuthenticated && authProvider.user != null) {
      final user = authProvider.user!;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => user.isGuardian
              ? const ParentDashboard()
              : const TeacherDashboard(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dummy logo representation
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Colecheck',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Asistencia Inteligente',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}
