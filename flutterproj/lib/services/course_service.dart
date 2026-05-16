import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../controllers/token_controller.dart';
import 'api_service.dart';
import '../models/course_model.dart';

class CourseService extends ApiService {
  final String _baseEndpoint = '/api/Student/Get_All_Course';

  Future<List<Course>> getAllCourses() async {
    if (kDebugMode) {
      final tokenController = TokenController();
      final token = await tokenController.getToken();
      final url = Uri.parse('$baseUrl$_baseEndpoint');
      debugPrint('Testing Course Endpoint: $url');
      try {
        final rawResponse = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 30));
        debugPrint('Course Endpoint Status Code: ${rawResponse.statusCode}');
        debugPrint('Course Endpoint Response Body: ${rawResponse.body}');
      } catch (e) {
        debugPrint('Course Endpoint Raw Error: $e');
      }
    }

    final result = await get(_baseEndpoint);
    final list = result['data'] as List<dynamic>? ?? [];
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
