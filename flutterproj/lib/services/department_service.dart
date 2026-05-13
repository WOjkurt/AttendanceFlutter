import 'api_service.dart';

class DepartmentService extends ApiService {
  final String _baseEndpoint = '/AttendanceManagement/Department';

  Future<dynamic> getAllDepartments() async {
    final result = await get(_baseEndpoint);
    return result['data'];
  }

  Future<dynamic> createDepartment(Map<String, dynamic> data) async {
    final result = await post(_baseEndpoint, body: data);
    return result['data'];
  }

  Future<dynamic> getDepartmentById(String id) async {
    final result = await get('$_baseEndpoint/$id');
    return result['data'];
  }

  Future<dynamic> updateDepartment(String id, Map<String, dynamic> data) async {
    final result = await put('$_baseEndpoint/$id', body: data);
    return result['data'];
  }

  Future<dynamic> deleteDepartment(String id) async {
    return await delete('$_baseEndpoint/$id');
  }
}
