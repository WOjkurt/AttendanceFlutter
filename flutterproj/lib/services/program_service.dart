import 'api_service.dart';

class ProgramService extends ApiService {
  final String _baseEndpoint = '/AttendanceManagement/Program';

  Future<dynamic> getAllPrograms() async {
    final result = await get(_baseEndpoint);
    return result['data'];
  }

  Future<dynamic> createProgram(Map<String, dynamic> data) async {
    final result = await post(_baseEndpoint, body: data);
    return result['data'];
  }

  Future<dynamic> getProgramById(String id) async {
    final result = await get('$_baseEndpoint/$id');
    return result['data'];
  }

  Future<dynamic> updateProgram(String id, Map<String, dynamic> data) async {
    final result = await put('$_baseEndpoint/$id', body: data);
    return result['data'];
  }

  Future<dynamic> deleteProgram(String id) async {
    return await delete('$_baseEndpoint/$id');
  }
}
