import 'api_service.dart';

class AttendanceService extends ApiService {
  final String _baseEndpoint = '/AttendanceManagement/Attendance';

  Future<dynamic> getAllAttendances() async {
    final result = await get(_baseEndpoint);
    return result['data'];
  }

  Future<dynamic> createAttendance(Map<String, dynamic> data) async {
    final result = await post(_baseEndpoint, body: data);
    return result['data'];
  }

  Future<dynamic> getAttendanceById(String id) async {
    final result = await get('$_baseEndpoint/$id');
    return result['data'];
  }

  Future<dynamic> updateAttendance(String id, Map<String, dynamic> data) async {
    final result = await put('$_baseEndpoint/$id', body: data);
    return result['data'];
  }

  Future<dynamic> deleteAttendance(String id) async {
    return await delete('$_baseEndpoint/$id');
  }
}
