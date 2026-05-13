import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/schedule_bloc.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  void initState() {
    super.initState();
    context.read<ScheduleBloc>().add(const LoadSchedules());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: Text(
          'My Study Load',
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
      body: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading || state is ScheduleInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScheduleLoaded) {
            if (state.schedules.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy_outlined, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'No schedules found.',
                      style: GoogleFonts.sourceSans3(fontSize: 18, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }

            // Group by DayName
            final grouped = <String, List<dynamic>>{};
            for (var s in state.schedules) {
              grouped.putIfAbsent(s.dayName, () => []).add(s);
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: grouped.keys.length,
              itemBuilder: (context, index) {
                final dayName = grouped.keys.elementAt(index);
                final schedules = grouped[dayName]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        dayName,
                        style: GoogleFonts.sourceSans3(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2E3192),
                        ),
                      ),
                    ),
                    ...schedules.map((schedule) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                                  color: const Color(0xFFE3E8FC),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.schedule_rounded, color: Color(0xFF2E3192), size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Course ID: ${schedule.courseId}',
                                      style: GoogleFonts.sourceSans3(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1A1F36),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${schedule.startTime} - ${schedule.endTime}',
                                      style: GoogleFonts.sourceSans3(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Semester: ${schedule.semester} | Year: ${schedule.academicYear}',
                                      style: GoogleFonts.sourceSans3(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            );
          } else if (state is ScheduleError) {
            final isWakingUp = state.message.toLowerCase().contains('waking up');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isWakingUp ? Icons.cloud_sync : Icons.error_outline,
                    size: 60,
                    color: isWakingUp ? const Color(0xFF1BFFFF) : Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      isWakingUp ? 'Server is starting up, please wait a moment and try again.' : state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.sourceSans3(fontSize: 18, color: Colors.grey.shade800),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E3192),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: () => context.read<ScheduleBloc>().add(const LoadSchedules()),
                    child: Text('Retry', style: GoogleFonts.sourceSans3(fontSize: 16, color: Colors.white)),
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
