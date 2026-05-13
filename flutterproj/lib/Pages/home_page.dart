import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/profile_bloc.dart';
import '../blocs/schedule_bloc.dart';
import '../blocs/course_bloc.dart';
import '../blocs/attendance_student_bloc.dart';
import '../models/schedule_model.dart';
import '../models/course_model.dart';
import 'schedule_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is! ProfileLoaded) {
        context.read<ProfileBloc>().add(const LoadProfile());
      }
    }
    // Ensure schedules and courses are loaded
    final scheduleState = context.read<ScheduleBloc>().state;
    if (scheduleState is! ScheduleLoaded) {
      context.read<ScheduleBloc>().add(const LoadSchedules());
    }
    final courseState = context.read<CourseBloc>().state;
    if (courseState is! CourseLoaded) {
      context.read<CourseBloc>().add(const LoadCourses());
    }
  }

  /// firstname greeting ni ha
  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return 'Student';
    final parts = fullName.trim().split(' ');
    return parts.first;
  }

  /// Get today's schedules sorted by start time
  List<Schedule> _getTodaySchedules(List<Schedule> all) {
    final todayDow = DateTime.now().weekday % 7; // Sunday=0
    return all.where((s) => s.dayOfWeek == todayDow).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Find the current or next upcoming event for the banner
  Schedule? _getCurrentEvent(List<Schedule> todaySchedules) {
    if (todaySchedules.isEmpty) return null;
    final now = TimeOfDay.now();
    for (final s in todaySchedules) {
      final end = _parseTime(s.endTime);
      if (end == null) continue;
      if (end.hour > now.hour || (end.hour == now.hour && end.minute > now.minute)) {
        return s;
      }
    }
    return todaySchedules.first; // fallback to first
  }

  TimeOfDay? _parseTime(String time) {
    try {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }

  String _formatTimeRange(String start, String end) {
    String fmt(String t) {
      try {
        final parts = t.split(':');
        final h = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final period = h >= 12 ? 'PM' : 'AM';
        final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
        return '$hour12:${m.toString().padLeft(2, '0')} $period';
      } catch (_) {
        return t;
      }
    }
    return '${fmt(start)} - ${fmt(end)}';
  }

  String _getCourseName(int courseId, List<Course> courses) {
    final match = courses.where((c) => c.courseId == courseId);
    if (match.isNotEmpty) {
      final c = match.first;
      return '${c.code}: ${c.title}';
    }
    return 'Course #$courseId';
  }

  String _getCourseCategory(int courseId, List<Course> courses) {
    final match = courses.where((c) => c.courseId == courseId);
    if (match.isNotEmpty) {
      return match.first.code;
    }
    return 'Class';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildGreetingSection(),
                const SizedBox(height: 24),
                _buildCurrentEventBanner(),
                const SizedBox(height: 28),
                _buildUpcomingRemindersSection(),
                const SizedBox(height: 28),
                _buildAIAnalyticsSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Top greeting: avatar + "Hi, Name!" + date
  Widget _buildGreetingSection() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        String displayName = 'Student';
        if (profileState is ProfileLoaded) {
          displayName = _getFirstName(profileState.user.fullName);
        } else {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated && authState.user.fullName.isNotEmpty) {
            displayName = _getFirstName(authState.user.fullName);
          }
        }

        final dateStr = DateFormat('d MMMM yyyy').format(DateTime.now());

        return Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF4A90D9).withOpacity(0.3),
                  width: 2.5,
                ),
                color: const Color(0xFFE8EFF8),
              ),
              child: const ClipOval(
                child: Icon(
                  Icons.person,
                  size: 32,
                  color: Color(0xFF4A90D9),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name + date
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.sourceSans3(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1F36),
                    ),
                    children: [
                      const TextSpan(text: 'Hi, '),
                      TextSpan(
                        text: '$displayName!',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2E3192),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7B8794),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Blue banner card showing the current / next event
  Widget _buildCurrentEventBanner() {
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      builder: (context, scheduleState) {
        return BlocBuilder<CourseBloc, CourseState>(
          builder: (context, courseState) {
            String title = 'No Events Today';
            String subtitle = 'Enjoy your free time!';

            if (scheduleState is ScheduleLoaded && scheduleState.schedules.isNotEmpty) {
              final todaySchedules = _getTodaySchedules(scheduleState.schedules);
              final current = _getCurrentEvent(todaySchedules);

              if (current != null) {
                final courses = courseState is CourseLoaded ? courseState.courses : <Course>[];
                title = _getCourseName(current.courseId, courses);
                subtitle = '${_formatTimeRange(current.startTime, current.endTime)} | Section ${current.sectionId}';
              } else if (todaySchedules.isEmpty) {
                title = 'No data';
                subtitle = 'No data';
              }
            } else if (scheduleState is ScheduleLoading) {
              title = 'Loading...';
              subtitle = 'Fetching your schedule';
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5BAAF0), Color(0xFF72C6F0)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5BAAF0).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// "Upcoming Reminders" section with schedule cards
  Widget _buildUpcomingRemindersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Reminders',
              style: GoogleFonts.sourceSans3(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1F36),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SchedulePage()),
              ),
              child: Text(
                'See all',
                style: GoogleFonts.sourceSans3(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A90D9),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<ScheduleBloc, ScheduleState>(
          builder: (context, scheduleState) {
            return BlocBuilder<CourseBloc, CourseState>(
              builder: (context, courseState) {
                if (scheduleState is ScheduleLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  );
                }

                if (scheduleState is ScheduleLoaded) {
                  final courses = courseState is CourseLoaded ? courseState.courses : <Course>[];

                  // Show today's upcoming + tomorrow's schedules as reminders
                  final todayDow = DateTime.now().weekday % 7;
                  final tomorrowDow = (todayDow + 1) % 7;

                  final reminders = scheduleState.schedules.where((s) {
                    return s.dayOfWeek == todayDow || s.dayOfWeek == tomorrowDow;
                  }).toList()
                    ..sort((a, b) {
                      if (a.dayOfWeek != b.dayOfWeek) {
                        return a.dayOfWeek == todayDow ? -1 : 1;
                      }
                      return a.startTime.compareTo(b.startTime);
                    });

                  if (reminders.isEmpty) {
                    return _buildEmptyReminders();
                  }

                  // Show max 4 reminders
                  final displayReminders = reminders.take(4).toList();

                  return Column(
                    children: displayReminders.map((schedule) {
                      return _buildReminderCard(schedule, courses);
                    }).toList(),
                  );
                }

                if (scheduleState is ScheduleError) {
                  return _buildErrorReminders(scheduleState.message);
                }

                return _buildEmptyReminders();
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildReminderCard(Schedule schedule, List<Course> courses) {
    final courseName = _getCourseName(schedule.courseId, courses);
    final timeStr = _formatTimeRange(schedule.startTime, schedule.endTime);
    final category = _getCourseCategory(schedule.courseId, courses);

    // Alternate icons for variety
    final icons = [
      Icons.description_outlined,
      Icons.laptop_mac_outlined,
      Icons.menu_book_outlined,
      Icons.science_outlined,
    ];
    final icon = icons[schedule.courseId % icons.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD0D9E8),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: const Color(0xFF4A90D9),
            ),
          ),
          const SizedBox(width: 14),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseName,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1F36),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '$timeStr  ·  $category',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8E99A8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReminders() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 40,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 8),
            Text(
              'No upcoming reminders',
              style: GoogleFonts.sourceSans3(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorReminders(String message) {
    final isWakingUp = message.toLowerCase().contains('waking up');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(
              isWakingUp ? Icons.cloud_sync : Icons.error_outline,
              size: 36,
              color: isWakingUp ? const Color(0xFF5BAAF0) : Colors.redAccent,
            ),
            const SizedBox(height: 8),
            Text(
              isWakingUp ? 'Server is waking up...' : message,
              textAlign: TextAlign.center,
              style: GoogleFonts.sourceSans3(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.read<ScheduleBloc>().add(const LoadSchedules()),
              child: Text(
                'Retry',
                style: GoogleFonts.sourceSans3(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4A90D9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "AI Analytics" section with merit score from attendance data
  Widget _buildAIAnalyticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Analytics',
          style: GoogleFonts.sourceSans3(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1F36),
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<AttendanceStudentBloc, AttendanceStudentState>(
          builder: (context, attState) {
            if (attState is AttendanceStudentLoading) {
              return _buildAnalyticsPlaceholder(isLoading: true);
            }

            if (attState is AttendanceStudentLoaded) {
              final total = attState.records.length;
              final present = attState.records
                  .where((r) => r.studentAttendanceStatus.name == 'present')
                  .length;
              final absent = attState.records
                  .where((r) => r.studentAttendanceStatus.name == 'absent')
                  .length;
              final late = attState.records
                  .where((r) => r.studentAttendanceStatus.name == 'late')
                  .length;

              final attendanceRate = total > 0 ? (present / total * 100).round() : 0;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.insights_rounded,
                            color: Color(0xFF4A90D9),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Attendance Overview',
                                style: GoogleFonts.sourceSans3(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1F36),
                                ),
                              ),
                              Text(
                                '$total total records',
                                style: GoogleFonts.sourceSans3(
                                  fontSize: 13,
                                  color: const Color(0xFF8E99A8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Attendance rate bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: total > 0 ? present / total : 0,
                        minHeight: 8,
                        backgroundColor: Colors.white,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatChip('Present', '$present', const Color(0xFF4CAF50)),
                        _buildStatChip('Absent', '$absent', const Color(0xFFFF5252)),
                        _buildStatChip('Late', '$late', const Color(0xFFFF9800)),
                        _buildStatChip('Rate', '$attendanceRate%', const Color(0xFF4A90D9)),
                      ],
                    ),
                  ],
                ),
              );
            }

            return _buildAnalyticsPlaceholder(isLoading: false);
          },
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.sourceSans3(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.sourceSans3(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8E99A8),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsPlaceholder({required bool isLoading}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Column(
                children: [
                  Icon(Icons.analytics_outlined, size: 36, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'Analytics will appear once data loads',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
