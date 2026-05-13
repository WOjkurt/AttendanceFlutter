import 'api_service.dart';

class SectionService extends ApiService {
  final String _baseEndpoint = '/AttendanceManagement/Section';

  Future<dynamic> getAllSections() async {
    final result = await get(_baseEndpoint);
    return result['data'];
  }

  Future<dynamic> createSection(Map<String, dynamic> data) async {
    final result = await post(_baseEndpoint, body: data);
    return result['data'];
  }

  Future<dynamic> getSectionById(String id) async {
    final result = await get('$_baseEndpoint/$id');
    return result['data'];
  }

  Future<dynamic> updateSection(String id, Map<String, dynamic> data) async {
    final result = await put('$_baseEndpoint/$id', body: data);
    return result['data'];
  }

  Future<dynamic> deleteSection(String id) async {
    return await delete('$_baseEndpoint/$id');
  }
}
