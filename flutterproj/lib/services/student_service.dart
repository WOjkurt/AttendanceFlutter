import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import '../models/student_model.dart';
import 'api_service.dart';

class StudentService extends ApiService {
  final String _baseEndpoint = '/api/Student';

  Future<List<Student>> getStudents() async {
    final result = await get(_baseEndpoint);
    final list = result['data'] as List<dynamic>;
    return list
        .map((json) => Student.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Finds a student by their user's DocumentSeries from the full student list.
  Future<Student?> getStudentByDocumentSeries(String documentSeries) async {
    final result = await get(_baseEndpoint);
    final list = result['data'] as List<dynamic>;
    final students = list
        .map((e) => Student.fromJson(e as Map<String, dynamic>))
        .toList();
    return students.firstWhereOrNull(
      (s) => s.userDocumentSeries == documentSeries,
    );
  }

  /// Fetches the current logged in student record.
  Future<Student> getCurrentStudent() async {
    final result = await get('$_baseEndpoint/Get_by_Current_Id');
    // Depending on the API response, data might be nested or direct
    final data = result.containsKey('data') ? result['data'] : result;
    return Student.fromJson(data as Map<String, dynamic>);
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

  /// Fetches the student's QR code PNG from the new login-based endpoint.
  ///
  /// Calls GET /api/Student/Qr_In_Student_By_Login which uses the JWT token
  /// to identify the student and returns their QR code.
  ///
  /// Returns raw PNG bytes for use with [Image.memory].
  Future<Uint8List> getStudentQrCode() async {
    if (kDebugMode) {
      debugPrint('QR endpoint: /api/Student/Qr_In_Student_By_Login');
    }

    return await getBytes('/api/Student/Qr_In_Student_By_Login', requiresAuth: true);
  }
}
