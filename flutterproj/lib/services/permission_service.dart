import 'api_service.dart';

class PermissionService extends ApiService {
  final String _baseEndpoint = '/AttendanceManagement/Permission';

  Future<dynamic> getAllPermissions() async {
    final result = await get(_baseEndpoint);
    return result['data'];
  }

  Future<dynamic> createPermission(Map<String, dynamic> data) async {
    final result = await post(_baseEndpoint, body: data);
    return result['data'];
  }

  Future<dynamic> getPermissionById(String id) async {
    final result = await get('$_baseEndpoint/$id');
    return result['data'];
  }

  Future<dynamic> updatePermission(String id, Map<String, dynamic> data) async {
    final result = await put('$_baseEndpoint/$id', body: data);
    return result['data'];
  }

  Future<dynamic> deletePermission(String id) async {
    return await delete('$_baseEndpoint/$id');
  }
}
