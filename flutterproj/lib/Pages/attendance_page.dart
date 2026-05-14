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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: BlocBuilder<AttendanceStudentBloc, AttendanceStudentState>(
        builder: (context, state) {
          if (state is AttendanceStudentLoading ||
              state is AttendanceStudentInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AttendanceStudentLoaded) {
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
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: state.records.length,
              itemBuilder: (context, index) {
                final record = state.records[index];
                final statusColor = _getStatusColor(
                  record.studentAttendanceStatus,
                );
                final statusText = _getStatusText(
                  record.studentAttendanceStatus,
                );
                final statusIcon = _getStatusIcon(
                  record.studentAttendanceStatus,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                            color: statusColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(statusIcon, color: statusColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Attendance #${record.attendanceId}',
                                style: GoogleFonts.sourceSans3(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1A1F36),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Student ID: ${record.studentDocumentSeries}',
                                style: GoogleFonts.sourceSans3(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w600,
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
                                color: statusColor.withOpacity(0.3),
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
          } else if (state is AttendanceStudentError) {
            final isWakingUp = state.message.toLowerCase().contains(
              'waking up',
            );
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isWakingUp ? Icons.cloud_sync : Icons.error_outline,
                    size: 60,
                    color: isWakingUp
                        ? const Color(0xFF1BFFFF)
                        : Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      isWakingUp
                          ? 'Server is waking up. Please wait...'
                          : state.message,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => context.read<AttendanceStudentBloc>().add(
                      const LoadAttendanceStudent(),
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}
