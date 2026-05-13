import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_page.dart';
import '../blocs/attendance_status_bloc.dart';
import '../blocs/analytics_bloc.dart';

class AttendanceStatusPage extends StatelessWidget {
  const AttendanceStatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AttendanceStatusBloc()..add(LoadAttendanceStatus()),
        ),
        BlocProvider(
          create: (context) => AnalyticsBloc(),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FC),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: BlocConsumer<AttendanceStatusBloc,
                      AttendanceStatusState>(
                    listener: (context, state) {
                      // When attendance data loads, automatically trigger
                      // analytics (respects cache).
                      if (state is AttendanceStatusLoaded) {
                        final data = _buildAttendanceDataMap(state);
                        context
                            .read<AnalyticsBloc>()
                            .add(LoadAnalytics(data));
                      }
                    },
                    builder: (context, state) {
                      if (state is AttendanceStatusLoading ||
                          state is AttendanceStatusInitial) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 100.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (state is AttendanceStatusError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Text(
                              state.errorMessage,
                              style: GoogleFonts.sourceSans3(color: Colors.red),
                            ),
                          ),
                        );
                      } else if (state is AttendanceStatusLoaded) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                state.statusMessage,
                                style: GoogleFonts.sourceSans3(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildSummaryGrid(state),
                            const SizedBox(height: 32),
                            _buildMeritCard(),
                            const SizedBox(height: 48),
                            _buildBackToHomeButton(context),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Converts the loaded attendance state into a hashable data map
  /// used for cache invalidation in the analytics repository.
  Map<String, dynamic> _buildAttendanceDataMap(AttendanceStatusLoaded state) {
    return {
      'totalPresents': state.totalPresents,
      'totalAbsences': state.totalAbsences,
      'totalLates': state.totalLates,
      'meritStatus': state.meritStatus,
    };
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFE3E8FC),
                    child: Icon(Icons.person_rounded, color: Color(0xFF2E3192), size: 24),
                  ),
                ),
              ),
            ],
          ),
          
          Text(
            'Summary',
            style: GoogleFonts.sourceSans3(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(AttendanceStatusLoaded state) {
    if (state.totalPresents == null || state.totalAbsences == null || state.totalLates == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: Text(
              "No attendance data received yet.",
              style: GoogleFonts.sourceSans3(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildStatRow(
            label: 'Presents',
            value: state.totalPresents,
            icon: Icons.check_circle_outline_rounded,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            label: 'Lates',
            value: state.totalLates,
            icon: Icons.schedule_rounded,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            label: 'Absences',
            value: state.totalAbsences,
            icon: Icons.cancel_outlined,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required int? value,
    required IconData icon,
    required MaterialColor color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.shade100, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.shade600, size: 24),
          const SizedBox(width: 14),
          Text(
            label,
            style: GoogleFonts.sourceSans3(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color.shade800,
            ),
          ),
          const Spacer(),
          Text(
            value?.toString() ?? '-',
            style: GoogleFonts.sourceSans3(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Merit Card (powered by AnalyticsBloc) ────────────────────────────────

  Widget _buildMeritCard() {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, analyticsState) {
        // Determine what to display in the merit score area.
        final String displayScore;
        if (analyticsState is AnalyticsLoaded) {
          displayScore = analyticsState.result.meritScore.toString();
        } else if (analyticsState is AnalyticsLoading) {
          displayScore = '...';
        } else if (analyticsState is AnalyticsError) {
          displayScore = '--';
        } else {
          displayScore = '--';
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24.0),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A50FE), Color(0xFF6B8AFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A50FE).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student Merit',
                      style: GoogleFonts.sourceSans3(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayScore,
                      style: GoogleFonts.sourceSans3(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackToHomeButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Back to Home',
            style: GoogleFonts.sourceSans3(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E3192),
            ),
          ),
        ),
      ),
    );
  }
}
