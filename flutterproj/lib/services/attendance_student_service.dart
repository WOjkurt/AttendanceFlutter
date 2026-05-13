import 'api_service.dart';
import '../models/attendance_student_model.dart';

class AttendanceStudentService extends ApiService {
  final String _baseEndpoint = '/AttendanceStudentManagement/AttendanceStudent';

  Future<List<AttendanceStudent>> getAttendanceByStudent() async {
    final result = await get(_baseEndpoint);
    final list = result['data'] as List<dynamic>;
    return list.map((json) => AttendanceStudent.fromJson(json)).toList();
  }

  Future<AttendanceStudent> createAttendanceStudent(Map<String, dynamic> data) async {
    final result = await post(_baseEndpoint, body: data);
    return AttendanceStudent.fromJson(result['data']);
  }
}
