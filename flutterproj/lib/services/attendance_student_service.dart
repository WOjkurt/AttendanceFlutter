import 'api_service.dart';
import '../models/attendance_student_model.dart';
import '../controllers/token_controller.dart';

class AttendanceStudentService extends ApiService {
  final String _baseEndpoint = '/AttendanceStudentManagement/AttendanceStudent';

  /// Fetches the first attendance record returned by the backend
  /// (relies on backend filtering by JWT identity server-side)
  /// and returns the studentDocumentSeries.
  /// Returns null if the student has no attendance records yet.
  Future<String?> fetchStudentDocumentSeries() async {
    final result = await get(_baseEndpoint);
    final list = result['data'] as List<dynamic>;
    if (list.isEmpty) return null;
    return AttendanceStudent.fromJson(list.first).studentDocumentSeries;
  }

  /// Fetches all attendance records and filters to only the
  /// currently logged-in student's records (by cached DocumentSeries).
  Future<List<AttendanceStudent>> getMyAttendance() async {
    final documentSeries = await TokenController().getDocumentSeries();
    final result = await get(_baseEndpoint);
    final list = result['data'] as List<dynamic>;
    final all = list.map((e) => AttendanceStudent.fromJson(e)).toList();

    if (documentSeries == null || documentSeries.isEmpty) return all;

    return all
        .where((a) => a.studentDocumentSeries == documentSeries)
        .toList();
  }

  Future<AttendanceStudent> createAttendanceStudent(
      Map<String, dynamic> data) async {
    final result = await post(_baseEndpoint, body: data);
    return AttendanceStudent.fromJson(result['data']);
  }
}