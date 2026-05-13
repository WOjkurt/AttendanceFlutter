import 'api_service.dart';
import '../models/course_model.dart';

class CourseService extends ApiService {
  final String _baseEndpoint = '/AttendanceManagement/Course';

  Future<List<Course>> getAllCourses() async {
    final result = await get(_baseEndpoint);
    final list = result['data'] as List<dynamic>;
    return list.map((json) => Course.fromJson(json)).toList();
  }

  Future<Course> createCourse(Map<String, dynamic> data) async {
    final result = await post(_baseEndpoint, body: data);
    return Course.fromJson(result['data']);
  }

  Future<Course> getCourseById(int id) async {
    final result = await get('$_baseEndpoint/$id');
    return Course.fromJson(result['data']);
  }

  Future<Course> updateCourse(int id, Map<String, dynamic> data) async {
    final result = await put('$_baseEndpoint/$id', body: data);
    return Course.fromJson(result['data']);
  }

  Future<void> deleteCourse(int id) async {
    await delete('$_baseEndpoint/$id');
  }
}
