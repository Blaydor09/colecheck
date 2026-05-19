import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'manual_entry_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isProcessing = false;
  bool isFacialMode = false;

  void _onDetect(BarcodeCapture capture) {
    if (isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String code = barcodes.first.rawValue ?? '';
      _processScannedCode(code);
    }
  }

  Future<void> _processScannedCode(String code) async {
    setState(() => isProcessing = true);
    
    try {
      // The QR code should contain the student ID
      final appProvider = context.read<AppProvider>();
      final success = await appProvider.recordAttendance(
        studentId: code,
        method: isFacialMode ? 'biometric' : 'qr',
        direction: 'entry',
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFacialMode
                ? 'Rostro reconocido exitosamente'
                : 'Ingreso registrado exitosamente'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFacialMode
                ? 'Rostro no reconocido'
                : 'QR Inválido o estudiante no encontrado'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFacialMode
              ? 'Rostro no reconocido'
              : 'QR Inválido o no reconocido'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    }

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => isProcessing = false);
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Acceso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: _onDetect,
                ),
                // Scanner overlay box
                Container(
                  width: isFacialMode ? 200 : 250,
                  height: isFacialMode ? 300 : 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isProcessing ? AppTheme.successColor : Colors.white,
                      width: 4,
                    ),
                    borderRadius: isFacialMode 
                        ? BorderRadius.circular(150) // Óvalo/Círculo para rostro
                        : BorderRadius.circular(16),  // Cuadrado para QR
                  ),
                ),
                if (isProcessing)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: AppTheme.scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    isFacialMode ? 'Enfoca el rostro del estudiante' : 'Escanea el QR del estudiante',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              isFacialMode = !isFacialMode;
                            });
                          },
                          icon: Icon(isFacialMode ? Icons.qr_code_scanner : Icons.face),
                          label: Text(isFacialMode ? 'Cambiar a QR' : 'Reconocimiento Facial'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ManualEntryScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.list_alt),
                          label: const Text('Registro Manual'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
