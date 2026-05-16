import 'api_service.dart';
import '../models/schedule_model.dart';

class ScheduleService extends ApiService {
  final String _baseEndpoint = '/AttendanceManagement/Schedule';

  Future<List<Schedule>> getAllSchedules() async {
    final result = await get(_baseEndpoint);
    final list = result['data'] as List<dynamic>;
    return list.map((json) => Schedule.fromJson(json)).toList();
  }

  Future<List<DaySchedule>> getCurrentDaySchedule() async {
    final now = DateTime.now();
    String dayName = 'Unknown';
    switch (now.weekday) {
      case 1: dayName = 'Monday'; break;
      case 2: dayName = 'Tuesday'; break;
      case 3: dayName = 'Wednesday'; break;
      case 4: dayName = 'Thursday'; break;
      case 5: dayName = 'Friday'; break;
      case 6: dayName = 'Saturday'; break;
      case 7: dayName = 'Sunday'; break;
    }

    final url = '$_baseEndpoint/$dayName/Get_Students_CurrentDay_Schedule';
    final result = await get(url);

    final list = result['data'] as List<dynamic>? ?? [];
    return list.map((json) => DaySchedule.fromJson(json)).toList();
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