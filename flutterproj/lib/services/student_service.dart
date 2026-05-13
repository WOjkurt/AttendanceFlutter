import 'api_service.dart';
import 'package:collection/collection.dart';
import '../models/student_model.dart';

class StudentService extends ApiService {
  final String _baseEndpoint = '/api/Student';

  Future<List<Student>> getStudents() async {
    final result = await get(_baseEndpoint);
    final list = result['data'] as List<dynamic>;
    return list.map((json) => Student.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Finds a student by their user's DocumentSeries from the full student list.
  Future<Student?> getStudentByDocumentSeries(String documentSeries) async {
    final result = await get(_baseEndpoint);
    final list = result['data'] as List<dynamic>;
    final students = list.map((e) => Student.fromJson(e as Map<String, dynamic>)).toList();
    return students.firstWhereOrNull(
      (s) => s.userDocumentSeries == documentSeries,
    );
  }

  Future<Student> getStudentById(String id) async {
    final result = await get('$_baseEndpoint/$id');
    return Student.fromJson(result['data'] as Map<String, dynamic>);
  }

  Future<Student> createStudent(Map<String, dynamic> body) async {
    final result = await post(_baseEndpoint, body: body);
    return Student.fromJson(result['data'] as Map<String, dynamic>);
  }

  Future<Student> updateStudent(String id, Map<String, dynamic> body) async {
    final result = await put('$_baseEndpoint/$id', body: body);
    return Student.fromJson(result['data'] as Map<String, dynamic>);
  }

  Future<void> deleteStudent(String id) async {
    await delete('$_baseEndpoint/$id');
  }
}
