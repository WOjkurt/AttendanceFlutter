import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/reminders_bloc.dart';
import '../models/schedule_model.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _RemindersPageContent();
  }
}

class _RemindersPageContent extends StatelessWidget {
  const _RemindersPageContent({Key? key}) : super(key: key);

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final period = h >= 12 ? 'PM' : 'AM';
      final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '$hour12:${m.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<RemindersBloc, RemindersState>(
                builder: (context, state) {
                  if (state is RemindersLoading || state is RemindersInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is RemindersLoaded) {
                    return _buildScheduleList(state.schedulesByDay);
                  } else if (state is RemindersError) {
                    return _buildErrorView(context, state.message);
                  }
                  return const Center(child: Text('Unknown state'));
                },
              ),
            ),
          ],
        ),
      ),
      // Bottom nav is handled by DashboardPage
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Reminders',
            style: GoogleFonts.sourceSans3(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1F36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(Map<String, List<Schedule>> schedulesByDay) {
    if (schedulesByDay.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_outlined, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No schedules found.',
              style: GoogleFonts.sourceSans3(
                fontSize: 18,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Order days logically (Monday first)
    const dayOrder = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];
    final sortedDays = schedulesByDay.keys.toList()
      ..sort((a, b) {
        final ai = dayOrder.indexOf(a);
        final bi = dayOrder.indexOf(b);
        return (ai == -1 ? 99 : ai).compareTo(bi == -1 ? 99 : bi);
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      itemCount: sortedDays.length,
      itemBuilder: (context, index) {
        final dayName = sortedDays[index];
        final schedules = schedulesByDay[dayName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E3192), Color(0xFF4A58D1)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      dayName,
                      style: GoogleFonts.sourceSans3(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${schedules.length} class${schedules.length != 1 ? 'es' : ''}',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ...schedules.map((schedule) => _buildClassCard(schedule)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildClassCard(Schedule schedule) {
    final timeStr =
        '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course #${schedule.courseId}',
            style: GoogleFonts.sourceSans3(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1F36),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E3192).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.access_time_outlined,
                  size: 18,
                  color: Color(0xFF2E3192),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                timeStr,
                style: GoogleFonts.sourceSans3(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  size: 18,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Semester ${schedule.semester} · ${schedule.academicYear}',
                style: GoogleFonts.sourceSans3(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.group_outlined,
                  size: 18,
                  color: Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Section ${schedule.sectionId}',
                style: GoogleFonts.sourceSans3(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    final isWakingUp = message.toLowerCase().contains('waking up');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isWakingUp ? Icons.cloud_sync : Icons.error_outline,
            size: 60,
            color: isWakingUp ? const Color(0xFF5BAAF0) : Colors.redAccent,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              isWakingUp ? 'Server is waking up. Please wait...' : message,
              textAlign: TextAlign.center,
              style: GoogleFonts.sourceSans3(
                fontSize: 18,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E3192),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () => context.read<RemindersBloc>().add(const LoadReminders()),
            child: Text(
              'Retry',
              style: GoogleFonts.sourceSans3(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
