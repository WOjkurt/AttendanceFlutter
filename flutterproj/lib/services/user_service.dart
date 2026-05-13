import 'api_service.dart';
import 'package:collection/collection.dart';
import '../models/user_model.dart';

class UserService extends ApiService {
  final String _baseEndpoint = '/api/User';

  Future<List<UserModel>> getAllUsers() async {
    final result = await get(_baseEndpoint);
    final list = result['data'] as List<dynamic>;
    return list.map((json) => UserModel.fromJson(json)).toList();
  }

  /// Finds a user by email (case-insensitive) from the full user list.
  Future<UserModel?> getUserByEmail(String email) async {
    final result = await get(_baseEndpoint);
    final list = result['data'] as List<dynamic>;
    final users = list.map((e) => UserModel.fromJson(e)).toList();
    return users.firstWhereOrNull(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
  }

  Future<UserModel> createUser(Map<String, dynamic> data) async {
    final result = await post(_baseEndpoint, body: data);
    return UserModel.fromJson(result['data']);
  }

  Future<UserModel> getUserById(String id) async {
    final result = await get('$_baseEndpoint/$id');
    return UserModel.fromJson(result['data']);
  }

  Future<void> deleteUser(String id) async {
    await delete('$_baseEndpoint/$id');
  }
}
