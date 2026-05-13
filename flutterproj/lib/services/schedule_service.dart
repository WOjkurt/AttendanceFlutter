import 'api_service.dart';
import '../models/schedule_model.dart';

class ScheduleService extends ApiService {
  final String _baseEndpoint = '/AttendanceManagement/Schedule';

  Future<List<Schedule>> getAllSchedules() async {
    final result = await get(_baseEndpoint);
    final list = result['data'] as List<dynamic>;
    return list.map((json) => Schedule.fromJson(json)).toList();
  }

  Future<Schedule> createSchedule(Map<String, dynamic> data) async {
    final result = await post(_baseEndpoint, body: data);
    return Schedule.fromJson(result['data']);
  }

  Future<Schedule> getScheduleById(int id) async {
    final result = await get('$_baseEndpoint/$id');
    return Schedule.fromJson(result['data']);
  }

  Future<Schedule> updateSchedule(int id, Map<String, dynamic> data) async {
    final result = await put('$_baseEndpoint/$id', body: data);
    return Schedule.fromJson(result['data']);
  }

  Future<void> deleteSchedule(int id) async {
    await delete('$_baseEndpoint/$id');
  }
}
