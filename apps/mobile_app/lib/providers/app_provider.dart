import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../widgets/status_chip.dart';

// ── Data Models ──────────────────────────────────────────────────────────────

class StudentData {
  final String id;
  final String name;
  final String grade;
  final String? photoUrl;
  final StatusType todayStatus;
  final String todayTime;

  StudentData({
    required this.id,
    required this.name,
    required this.grade,
    this.photoUrl,
    this.todayStatus = StatusType.pending,
    this.todayTime = 'Pendiente',
  });
}

class AttendanceEvent {
  final String id;
  final String studentId;
  final String studentName;
  final StatusType status;
  final DateTime eventTime;
  final String timeStr;

  AttendanceEvent({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.status,
    required this.eventTime,
    required this.timeStr,
  });
}

// ── App Provider ─────────────────────────────────────────────────────────────

/// Application data provider — mirrors the web's AppContext.
/// Fetches students, attendance history, and provides actions.
class AppProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<StudentData> _students = [];
  List<AttendanceEvent> _attendanceHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<StudentData> get students => _students;
  List<AttendanceEvent> get attendanceHistory => _attendanceHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Data fetching ───────────────────────────────────────────────────

  /// Fetch data for a **parent/guardian** user.
  Future<void> fetchParentData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use the new parent-specific endpoints
      final results = await Future.wait([
        _api.get('/students/my-children'),
        _api.get('/attendance/my-students'),
      ]);

      final studentsRes = results[0];
      final attendanceRes = results[1];

      final List<dynamic> studentsList =
          (studentsRes['data'] as List<dynamic>?) ?? [];
      final List<dynamic> attendanceList =
          (attendanceRes['data'] as List<dynamic>?) ?? [];

      // Build attendance map: studentId → latest event today
      final today = DateTime.now();
      final Map<String, Map<String, dynamic>> todayAttendance = {};
      for (final event in attendanceList) {
        final eventTime = DateTime.tryParse(event['event_time'] ?? '');
        if (eventTime != null &&
            eventTime.year == today.year &&
            eventTime.month == today.month &&
            eventTime.day == today.day) {
          final sid = event['student_id'] as String? ?? '';
          if (!todayAttendance.containsKey(sid)) {
            todayAttendance[sid] = event as Map<String, dynamic>;
          }
        }
      }

      _students = studentsList.map((s) {
        final sid = s['id'] as String? ?? '';
        final todayEvent = todayAttendance[sid];

        return StudentData(
          id: sid,
          name: s['full_name'] as String? ?? 'Sin nombre',
          grade: _extractGrade(s),
          photoUrl: s['photo_url'] as String?,
          todayStatus: _parseStatus(todayEvent?['status_after']),
          todayTime: _formatTime(todayEvent?['event_time']),
        );
      }).toList();

      _attendanceHistory = attendanceList.map((event) {
        final studentName = event['students']?['full_name'] as String? ?? 'Estudiante';
        final eventTime = DateTime.tryParse(event['event_time'] ?? '') ?? DateTime.now();

        return AttendanceEvent(
          id: event['id'] as String? ?? '',
          studentId: event['student_id'] as String? ?? '',
          studentName: studentName,
          status: _parseStatus(event['status_after']),
          eventTime: eventTime,
          timeStr: _formatTime(event['event_time']),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching parent data: $e');
      _errorMessage = 'No se pudieron cargar los datos';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch data for a **staff/teacher** user.
  Future<void> fetchStaffData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.get('/students'),
        _api.get('/attendance'),
      ]);

      final studentsRes = results[0];
      final attendanceRes = results[1];

      final List<dynamic> studentsList =
          (studentsRes['data'] as List<dynamic>?) ?? [];
      final List<dynamic> attendanceList =
          (attendanceRes['data'] as List<dynamic>?) ?? [];

      // Build attendance map for today
      final today = DateTime.now();
      final Map<String, Map<String, dynamic>> todayAttendance = {};
      for (final event in attendanceList) {
        final eventTime = DateTime.tryParse(event['event_time'] ?? '');
        if (eventTime != null &&
            eventTime.year == today.year &&
            eventTime.month == today.month &&
            eventTime.day == today.day) {
          final sid = event['student_id'] as String? ?? '';
          if (!todayAttendance.containsKey(sid)) {
            todayAttendance[sid] = event as Map<String, dynamic>;
          }
        }
      }

      _students = studentsList.map((s) {
        final sid = s['id'] as String? ?? '';
        final todayEvent = todayAttendance[sid];

        return StudentData(
          id: sid,
          name: s['full_name'] as String? ?? 'Sin nombre',
          grade: _extractGrade(s),
          photoUrl: s['photo_url'] as String?,
          todayStatus: _parseStatus(todayEvent?['status_after']),
          todayTime: _formatTime(todayEvent?['event_time']),
        );
      }).toList();

      _attendanceHistory = attendanceList.map((event) {
        final studentName = event['students']?['full_name'] as String? ?? 'Estudiante';
        final eventTime = DateTime.tryParse(event['event_time'] ?? '') ?? DateTime.now();

        return AttendanceEvent(
          id: event['id'] as String? ?? '',
          studentId: event['student_id'] as String? ?? '',
          studentName: studentName,
          status: _parseStatus(event['status_after']),
          eventTime: eventTime,
          timeStr: _formatTime(event['event_time']),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching staff data: $e');
      _errorMessage = 'No se pudieron cargar los datos';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Actions ─────────────────────────────────────────────────────────

  /// Record attendance for a student via the API.
  Future<bool> recordAttendance({
    required String studentId,
    required String method, // 'qr', 'manual', 'biometric'
    String direction = 'entry',
    String? notes,
  }) async {
    try {
      final response = await _api.post('/attendance/record', {
        'studentId': studentId,
        'method': method,
        'direction': direction,
        if (notes != null) 'notes': notes,
      });

      if (response['success'] == true) {
        // Update local student status
        final event = response['data'] as Map<String, dynamic>?;
        if (event != null) {
          final sid = event['student_id'] as String? ?? studentId;
          final newStatus = _parseStatus(event['status_after']);
          final newTime = _formatTime(event['event_time']);

          _students = _students.map((s) {
            if (s.id == sid) {
              return StudentData(
                id: s.id,
                name: s.name,
                grade: s.grade,
                photoUrl: s.photoUrl,
                todayStatus: newStatus,
                todayTime: newTime,
              );
            }
            return s;
          }).toList();

          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      debugPrint('Error recording attendance: $e');
    }
    return false;
  }

  /// Clear all data (on logout).
  void clear() {
    _students = [];
    _attendanceHistory = [];
    _errorMessage = null;
    notifyListeners();
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  String _extractGrade(dynamic s) {
    // Try class_sections first
    if (s['class_sections'] != null) {
      final section = s['class_sections'];
      return section['display_name'] as String? ??
          section['name'] as String? ??
          'No asignado';
    }
    // Fallback to metadata
    if (s['metadata'] != null && s['metadata'] is Map) {
      return s['metadata']['registered_grade_label'] as String? ??
          'No asignado';
    }
    return 'No asignado';
  }

  StatusType _parseStatus(String? status) {
    switch (status) {
      case 'present':
        return StatusType.present;
      case 'late':
        return StatusType.late;
      case 'absent':
        return StatusType.absent;
      default:
        return StatusType.pending;
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Pendiente';

    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return 'Pendiente';

    final localDt = dt.toLocal();
    final hour = localDt.hour;
    final minute = localDt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;

    return '$displayHour:$minute $period';
  }
}
