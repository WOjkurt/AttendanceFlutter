import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/attendance_student_bloc.dart';
import '../models/enums/att_status.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  @override
  void initState() {
    super.initState();
    context.read<AttendanceStudentBloc>().add(const LoadAttendanceStudent());
  }

  Color _getStatusColor(AttStatus status) {
    switch (status) {
      case AttStatus.present:
        return const Color(0xFF00C853);
      case AttStatus.absent:
        return const Color(0xFFFF3D00);
      case AttStatus.late:
        return const Color(0xFFFF9100);
      case AttStatus.excused:
        return const Color(0xFF2979FF);
      case AttStatus.unknown:
        return Colors.grey.shade500;
    }
  }

  String _getStatusText(AttStatus status) {
    switch (status) {
      case AttStatus.present:
        return 'Present';
      case AttStatus.absent:
        return 'Absent';
      case AttStatus.late:
        return 'Late';
      case AttStatus.excused:
        return 'Excused';
      case AttStatus.unknown:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(AttStatus status) {
    switch (status) {
      case AttStatus.present:
        return Icons.check_circle_outline;
      case AttStatus.absent:
        return Icons.cancel_outlined;
      case AttStatus.late:
        return Icons.access_time;
      case AttStatus.excused:
        return Icons.info_outline;
      case AttStatus.unknown:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: Text(
          'My Attendance',
          style: GoogleFonts.sourceSans3(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E3192),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: BlocBuilder<AttendanceStudentBloc, AttendanceStudentState>(
        builder: (context, state) {
          if (state is AttendanceStudentLoading ||
              state is AttendanceStudentInitial) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF2E3192)),
                  const SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: GoogleFonts.sourceSans3(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is AttendanceStudentLoaded) {
            return _buildLoaded(state);
          }

          if (state is AttendanceStudentError) {
            return _buildError(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoaded(AttendanceStudentLoaded state) {
    if (state.records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fact_check_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No attendance records found.',
              style: GoogleFonts.sourceSans3(
                fontSize: 18,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Summary counts at the top
    final counts = <AttStatus, int>{};
    for (final r in state.records) {
      counts[r.studentAttendanceStatus] =
          (counts[r.studentAttendanceStatus] ?? 0) + 1;
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: state.records.length + 1, // +1 for summary header
      itemBuilder: (context, index) {
        if (index == 0) return _buildSummary(state.records.length, counts);

        final record = state.records[index - 1];
        final statusColor = _getStatusColor(record.studentAttendanceStatus);
        final statusText = _getStatusText(record.studentAttendanceStatus);
        final statusIcon = _getStatusIcon(record.studentAttendanceStatus);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Record #${index}',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1F36),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Attendance ID: ${record.attendanceId}',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.sourceSans3(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummary(int total, Map<AttStatus, int> counts) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3192),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: GoogleFonts.sourceSans3(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryChip(
                'Present',
                counts[AttStatus.present] ?? 0,
                const Color(0xFF00C853),
              ),
              _buildSummaryChip(
                'Absent',
                counts[AttStatus.absent] ?? 0,
                const Color(0xFFFF3D00),
              ),
              _buildSummaryChip(
                'Late',
                counts[AttStatus.late] ?? 0,
                const Color(0xFFFF9100),
              ),
              _buildSummaryChip(
                'Excused',
                counts[AttStatus.excused] ?? 0,
                const Color(0xFF2979FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$count',
              style: GoogleFonts.sourceSans3(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.sourceSans3(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, AttendanceStudentError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.isColdStart
                  ? Icons.cloud_off_rounded
                  : Icons.error_outline_rounded,
              size: 80,
              color: state.isColdStart ? const Color(0xFF5BAAF0) : Colors.redAccent,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: state.isColdStart ? const Color(0xFFE8F4FD) : Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    state.isColdStart
                        ? 'Server is waking up...'
                        : 'Failed to load attendance',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: state.isColdStart ? const Color(0xFF2E86C1) : Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.isColdStart
                        ? 'The server takes 30–60 seconds to wake up. Please try again.'
                        : state.message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 14,
                      color: state.isColdStart 
                          ? const Color(0xFF2E86C1).withOpacity(0.8) 
                          : Colors.red.shade700.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.read<AttendanceStudentBloc>().add(
                const LoadAttendanceStudent(),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Try Again',
                style: GoogleFonts.sourceSans3(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E3192),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
