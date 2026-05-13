import 'api_service.dart';

class TeacherService extends ApiService {
  final String _baseEndpoint = '/api/Teacher';

  Future<dynamic> getAllTeachers() async {
    final result = await get(_baseEndpoint);
    return result['data'];
  }

  Future<dynamic> createTeacher(Map<String, dynamic> data) async {
    final result = await post(_baseEndpoint, body: data);
    return result['data'];
  }

  Future<dynamic> getTeacherById(String id) async {
    final result = await get('$_baseEndpoint/$id');
    return result['data'];
  }

  Future<dynamic> updateTeacher(String id, Map<String, dynamic> data) async {
    final result = await put('$_baseEndpoint/$id', body: data);
    return result['data'];
  }

  Future<dynamic> deleteTeacher(String id) async {
    return await delete('$_baseEndpoint/$id');
  }
}
