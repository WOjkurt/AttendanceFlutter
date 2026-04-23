import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/school/student_profile.dart';
import '../models/school/attendance_record.dart';
import '../models/school/schedule_entry.dart';

/// Handles all HTTP communication with the **main school management system**.
///
/// This controller is responsible **only** for mapping endpoints to method
/// calls and converting raw JSON into typed model objects.
/// Business logic belongs in the BLoC layer, not here.
///
/// ─── Setup ──────────────────────────────────────────────────────────────────
/// 1. Fill in [ApiConfig.schoolSystemBaseUrl] and [ApiConfig.schoolSystemApiKey].
/// 2. Add/rename methods below as the real endpoints become available.
/// 3. Inject into the relevant BLoC the same way [AuthService] is injected.
/// ────────────────────────────────────────────────────────────────────────────
class SchoolSystemController {
  late final ApiClient _client;

  SchoolSystemController()
      : _client = ApiClient(
          baseUrl: ApiConfig.schoolSystemBaseUrl,
          apiKey: ApiConfig.schoolSystemApiKey,
        );

  /// Visible for testing — allows injecting a mock [ApiClient].
  SchoolSystemController.withClient(this._client);

  // ─── Student ──────────────────────────────────────────────────────────────

  /// Fetches the full profile for [studentId] from the school system.
  ///
  /// TODO: Replace '/students/{id}' with the real endpoint path.
  Future<StudentProfile> getStudentProfile(String studentId) async {
    final data = await _client.get('/students/$studentId');
    return StudentProfile.fromJson(Map<String, dynamic>.from(data as Map));
  }

  // ─── Attendance ───────────────────────────────────────────────────────────

  /// Retrieves the attendance list for [classId] on the given [date]
  /// (ISO-8601 date string, e.g. '2026-04-19').
  ///
  /// TODO: Replace '/attendance' with the real endpoint path.
  Future<List<AttendanceRecord>> getAttendance({
    required String classId,
    required String date,
  }) async {
    final data = await _client.get(
      '/attendance',
      queryParams: {'classId': classId, 'date': date},
    );
    return (data as List)
        .map((e) => AttendanceRecord.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Submits an updated [record] to the school system.
  ///
  /// TODO: Replace '/attendance' with the real endpoint path.
  Future<void> submitAttendance(AttendanceRecord record) async {
    await _client.post('/attendance', body: record.toJson());
  }

  // ─── Schedule ─────────────────────────────────────────────────────────────

  /// Fetches the class schedule for [teacherId].
  ///
  /// TODO: Replace '/schedules' with the real endpoint path.
  Future<List<ScheduleEntry>> getSchedule(String teacherId) async {
    final data = await _client.get(
      '/schedules',
      queryParams: {'teacherId': teacherId},
    );
    return (data as List)
        .map((e) => ScheduleEntry.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  void dispose() => _client.dispose();
}
