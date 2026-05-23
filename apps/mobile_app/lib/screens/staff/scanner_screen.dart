import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_chip.dart';
import 'manual_entry_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController cameraController = MobileScannerController();
  bool isProcessing = false;
  bool isFacialMode = false;

  // Variables para la cámara real en el reconocimiento biométrico facial
  CameraController? _facialCameraController;
  Future<void>? _initializeCameraFuture;
  List<CameraDescription> _availableCameras = [];
  bool _isCameraInitialized = false;

  AnimationController? _laserController;
  bool isFacialScanning = false;
  double facialScanProgress = 0.0;
  String facialScanStatus = 'Listo para escanear';
  StudentData? matchedStudent;
  double matchConfidence = 0.0;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    cameraController.dispose();
    _facialCameraController?.dispose();
    _laserController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFacialMode() async {
    if (isFacialMode) {
      // Exiting facial mode -> Stop facial camera, restart QR scanner
      setState(() {
        isFacialMode = false;
        isProcessing = false;
        matchedStudent = null;
        isFacialScanning = false;
        facialScanProgress = 0.0;
        _disposeCamera();
      });
      try {
        await cameraController.start();
      } catch (e) {
        debugPrint('Error starting QR camera: $e');
      }
    } else {
      // Entering facial mode -> Stop QR scanner first, then start facial camera
      setState(() {
        facialScanStatus = 'Liberando recursos de cámara...';
      });
      try {
        await cameraController.stop();
        // Give native hardware resources time to release
        await Future.delayed(const Duration(milliseconds: 800));
      } catch (e) {
        debugPrint('Error stopping QR camera: $e');
      }
      setState(() {
        isFacialMode = true;
        isProcessing = false;
        matchedStudent = null;
        isFacialScanning = false;
        facialScanProgress = 0.0;
        facialScanStatus = 'Iniciando cámara...';
      });
      await _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      if (_facialCameraController != null) {
        await _facialCameraController!.dispose();
        _facialCameraController = null;
      }
      _isCameraInitialized = false;
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        if (mounted) {
          setState(() {
            facialScanStatus = 'No se encontraron cámaras';
          });
        }
        return;
      }

      // Try to find the front-facing camera
      CameraDescription? selectedCamera;
      for (var camera in _availableCameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          selectedCamera = camera;
          break;
        }
      }
      
      // Fallback to the first available camera
      selectedCamera ??= _availableCameras.first;

      _facialCameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeCameraFuture = _facialCameraController!.initialize();
      await _initializeCameraFuture;

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          facialScanStatus = 'Alinea tu rostro en el óvalo y presiona Escanear';
        });
      }
    } catch (e) {
      debugPrint('Error initializing facial camera: $e');
      if (mounted) {
        setState(() {
          facialScanStatus = 'Error al iniciar la cámara: $e';
        });
      }
    }
  }

  void _disposeCamera() {
    _facialCameraController?.dispose();
    _facialCameraController = null;
    _isCameraInitialized = false;
  }

  Future<void> _toggleCameraLens() async {
    if (_facialCameraController == null || _availableCameras.isEmpty) return;

    try {
      final currentLensDirection = _facialCameraController!.description.lensDirection;
      CameraDescription? newCamera;

      for (var camera in _availableCameras) {
        if (currentLensDirection == CameraLensDirection.front &&
            camera.lensDirection == CameraLensDirection.back) {
          newCamera = camera;
          break;
        } else if (currentLensDirection == CameraLensDirection.back &&
            camera.lensDirection == CameraLensDirection.front) {
          newCamera = camera;
          break;
        }
      }

      newCamera ??= _availableCameras.firstWhere(
        (camera) => camera.lensDirection != currentLensDirection,
        orElse: () => _availableCameras.first,
      );

      if (newCamera != _facialCameraController!.description) {
        setState(() {
          _isCameraInitialized = false;
          facialScanStatus = 'Cambiando de cámara...';
        });

        await _facialCameraController!.dispose();
        _facialCameraController = CameraController(
          newCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        _initializeCameraFuture = _facialCameraController!.initialize();
        await _initializeCameraFuture;

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
            facialScanStatus = 'Alinea tu rostro en el óvalo y presiona Escanear';
          });
        }
      }
    } catch (e) {
      debugPrint('Error toggling camera lens: $e');
      if (mounted) {
        setState(() {
          facialScanStatus = 'Error al cambiar cámara: $e';
        });
      }
    }
  }

  Future<void> _captureAndVerifyFace() async {
    if (_facialCameraController == null || !_isCameraInitialized || isFacialScanning) return;

    setState(() {
      isFacialScanning = true;
      facialScanProgress = 0.15;
      facialScanStatus = 'Capturando rostro...';
      matchedStudent = null;
    });

    try {
      // 1. Take picture
      final XFile imageFile = await _facialCameraController!.takePicture();
      
      if (!mounted) return;
      setState(() {
        facialScanProgress = 0.45;
        facialScanStatus = 'Procesando imagen facial...';
      });

      // 2. Read bytes and convert to Base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64.encode(bytes)}';

      if (!mounted) return;
      setState(() {
        facialScanProgress = 0.75;
        facialScanStatus = 'Analizando y verificando coincidencia...';
      });

      // 3. Connect to API via Provider
      final appProvider = context.read<AppProvider>();
      final result = await appProvider.recordBiometricAttendance(
        capturedImage: base64Image,
        direction: 'entry',
      );

      if (!mounted) return;

      if (result != null && result['success'] == true) {
        final studentJson = result['student'];
        final double confidence = (result['confidence'] as num?)?.toDouble() ?? 100.0;

        final matched = StudentData(
          id: studentJson['id'] as String? ?? '',
          name: studentJson['full_name'] as String? ?? 'Desconocido',
          grade: studentJson['current_section'] as String? ?? 'Sin curso',
          photoUrl: studentJson['photo_url'] as String?,
          todayStatus: StatusType.present,
          todayTime: 'Registrado',
        );

        setState(() {
          matchedStudent = matched;
          matchConfidence = confidence;
          facialScanProgress = 1.0;
          facialScanStatus = '¡Rostro Reconocido con éxito!';
          isFacialScanning = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Asistencia registrada para ${matched.name} (${confidence.toStringAsFixed(1)}%)'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Keep success card visible for 4.5 seconds, then reset
        await Future.delayed(const Duration(milliseconds: 4500));
        if (mounted) {
          setState(() {
            matchedStudent = null;
            facialScanProgress = 0.0;
            facialScanStatus = 'Alinea tu rostro en el óvalo y presiona Escanear';
          });
        }
      } else {
        throw Exception('Rostro no identificado');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        isFacialScanning = false;
        facialScanProgress = 0.0;
        facialScanStatus = 'Rostro no reconocido: ${e.message}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isFacialScanning = false;
        facialScanProgress = 0.0;
        facialScanStatus = 'No se reconoció el rostro del estudiante';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rostro no reconocido. Por favor, intente de nuevo.'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    }
  }

  ImageProvider? _getStudentImageProvider(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('data:image')) {
      try {
        final base64String = photoUrl.split(',').last;
        return MemoryImage(base64.decode(base64String));
      } catch (e) {
        debugPrint('Error decoding base64 student photo: $e');
        return null;
      }
    }
    return NetworkImage(photoUrl);
  }

  void _onDetect(BarcodeCapture capture) {
    if (isProcessing || isFacialMode) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String code = barcodes.first.rawValue ?? '';
      _processScannedCode(code);
    }
  }

  Future<void> _processScannedCode(String code) async {
    setState(() => isProcessing = true);

    try {
      final appProvider = context.read<AppProvider>();
      final success = await appProvider.recordAttendance(
        studentId: code,
        method: 'qr',
        direction: 'entry',
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ingreso registrado exitosamente'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código QR inválido o estudiante no encontrado'),
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
        const SnackBar(
          content: Text('Código QR inválido o no reconocido'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Acceso'),
        actions: [
          if (!isFacialMode)
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () => cameraController.toggleTorch(),
            ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: isFacialMode ? _toggleCameraLens : () => cameraController.switchCamera(),
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
                if (isFacialMode)
                  (_isCameraInitialized && _facialCameraController != null)
                      ? SizedBox.expand(
                          child: CameraPreview(_facialCameraController!),
                        )
                      : Container(
                          color: Colors.black,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                else
                  MobileScanner(
                    controller: cameraController,
                    onDetect: _onDetect,
                  ),
                if (isFacialMode)
                  // Contenedor del óvalo con escaneo láser animado
                  Container(
                    width: 200,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: matchedStudent != null
                            ? AppTheme.successColor
                            : isFacialScanning
                                ? Colors.greenAccent
                                : Colors.white,
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(150),
                      boxShadow: [
                        BoxShadow(
                          color: (matchedStudent != null
                                  ? AppTheme.successColor
                                  : Colors.greenAccent)
                              .withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(150),
                      child: Stack(
                        children: [
                          if (isFacialScanning && matchedStudent == null)
                            AnimatedBuilder(
                              animation: _laserController!,
                              builder: (context, child) {
                                return Positioned(
                                  top: 300 * _laserController!.value,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.greenAccent.withOpacity(0.8),
                                          blurRadius: 12,
                                          spreadRadius: 3,
                                        )
                                      ],
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  )
                else
                  // Cuadrado tradicional para escaneo de QR
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isProcessing ? AppTheme.successColor : Colors.white,
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                // Loader tradicional (solo para escaneo QR)
                if (isProcessing && !isFacialMode)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),

                // Pantalla de coincidencia glassmorphism premium
                if (matchedStudent != null)
                  Positioned.fill(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                        child: Container(
                          color: Colors.black.withOpacity(0.55),
                          child: Center(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.elasticOut,
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    width: 310,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.92),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: AppTheme.successColor,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.successColor.withOpacity(0.4),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppTheme.successColor.withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.verified_user,
                                            color: AppTheme.successColor,
                                            size: 48,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Coincidencia Biométrica',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        Text(
                                          '${matchConfidence.toStringAsFixed(1)}%',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.successColor,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppTheme.successColor.withOpacity(0.5),
                                              width: 3,
                                            ),
                                            image: matchedStudent!.photoUrl != null &&
                                                    matchedStudent!.photoUrl!.isNotEmpty
                                                ? DecorationImage(
                                                    image: _getStudentImageProvider(matchedStudent!.photoUrl)!,
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child: matchedStudent!.photoUrl == null ||
                                                  matchedStudent!.photoUrl!.isEmpty
                                              ? Icon(
                                                  Icons.person,
                                                  size: 50,
                                                  color: Colors.grey[400],
                                                )
                                              : null,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          matchedStudent!.name,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          matchedStudent!.grade,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.successColor,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle_outline,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'INGRESO REGISTRADO',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  letterSpacing: 1.1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
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
                  Column(
                    children: [
                      Text(
                        isFacialMode ? facialScanStatus : 'Escanea el QR del estudiante',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isFacialMode && isFacialScanning
                              ? Colors.green[700]
                              : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (isFacialMode && isFacialScanning && matchedStudent == null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: facialScanProgress,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isFacialMode) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (_isCameraInitialized && !isFacialScanning) ? _captureAndVerifyFace : null,
                        icon: const Icon(Icons.camera_alt, size: 24),
                        label: const Text(
                          'Escanear Rostro',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleFacialMode,
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
