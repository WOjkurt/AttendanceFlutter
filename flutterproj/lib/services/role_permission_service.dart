import 'api_service.dart';

class RolePermissionService extends ApiService {
  final String _baseEndpoint = '/AttendanceManagement/RolePermission';

  Future<dynamic> getAllRolePermissions() async {
    final result = await get(_baseEndpoint);
    return result['data'];
  }

  Future<dynamic> createRolePermission(Map<String, dynamic> data) async {
    final result = await post(_baseEndpoint, body: data);
    return result['data'];
  }

  Future<dynamic> getRolePermissionById(String id) async {
    final result = await get('$_baseEndpoint/$id');
    return result['data'];
  }

  Future<dynamic> updateRolePermission(String id, Map<String, dynamic> data) async {
    final result = await put('$_baseEndpoint/$id', body: data);
    return result['data'];
  }

  Future<dynamic> deleteRolePermission(String id) async {
    return await delete('$_baseEndpoint/$id');
  }
}
