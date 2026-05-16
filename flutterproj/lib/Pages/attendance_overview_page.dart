import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/analytics_bloc.dart';
import '../blocs/attendance_student_bloc.dart';
import '../models/enums/att_status.dart';

class AttendanceOverviewPage extends StatelessWidget {
  const AttendanceOverviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _AttendanceOverviewContent();
  }
}

class _AttendanceOverviewContent extends StatefulWidget {
  const _AttendanceOverviewContent({Key? key}) : super(key: key);

  @override
  State<_AttendanceOverviewContent> createState() =>
      _AttendanceOverviewContentState();
}

class _AttendanceOverviewContentState
    extends State<_AttendanceOverviewContent> {
  // ─── Colour tokens (matches ClassTrack palette) ────────────────────────
  static const _navy = Color(0xFF2E3192);
  static const _blue = Color(0xFF1A50FE);
  static const _sky = Color(0xFF4A90D9);
  static const _bg = Color(0xFFF4F7FC);
  static const _ink = Color(0xFF1A1F36);
  static const _muted = Color(0xFF8E99A8);
  static const _green = Color(0xFF4CAF50);
  static const _red = Color(0xFFFF5252);
  static const _amber = Color(0xFFFF9800);

  // ─── Analytics trigger guard ───────────────────────────────────────────
  bool _analyticsTriggered = false;

  void _maybeLoadAnalytics(
      BuildContext context, AttendanceStudentLoaded attState) {
    if (_analyticsTriggered) return;
    final analyticsState = context.read<AnalyticsBloc>().state;
    if (analyticsState is AnalyticsInitial ||
        analyticsState is AnalyticsError) {
      _analyticsTriggered = true;
      final absent = attState.records
          .where((r) => r.studentAttendanceStatus == AttStatus.absent)
          .length;
      final late = attState.records
          .where((r) => r.studentAttendanceStatus == AttStatus.late)
          .length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AnalyticsBloc>().add(
              LoadAnalytics({'totalAbsences': absent, 'totalLates': late}),
            );
      });
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────
  Color _meritColor(int score) {
    if (score >= 85) return _green;
    if (score >= 70) return _amber;
    return _red;
  }

  String _meritLabel(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Good Standing';
    if (score >= 70) return 'Fair';
    if (score >= 60) return 'At Risk';
    return 'Critical';
  }

  IconData _meritIcon(int score) {
    if (score >= 85) return Icons.verified_rounded;
    if (score >= 70) return Icons.warning_amber_rounded;
    return Icons.error_outline_rounded;
  }

  // ─── Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: BlocBuilder<AttendanceStudentBloc, AttendanceStudentState>(
          builder: (context, attState) {
            if (attState is AttendanceStudentLoading ||
                attState is AttendanceStudentInitial) {
              return _buildLoadingView();
            }
            if (attState is AttendanceStudentError) {
              return _buildErrorView(context, attState.message);
            }
            if (attState is AttendanceStudentLoaded) {
              _maybeLoadAnalytics(context, attState);
              return _buildContent(context, attState);
            }
            return _buildLoadingView();
          },
        ),
      ),
    );
  }

  // ─── Loading ──────────────────────────────────────────────────────────
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_blue),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading attendance…',
            style: GoogleFonts.poppins(fontSize: 14, color: _muted),
          ),
        ],
      ),
    );
  }

  // ─── Error ────────────────────────────────────────────────────────────
  Widget _buildErrorView(BuildContext context, String message) {
    final isWakingUp = message.toLowerCase().contains('waking up');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isWakingUp ? Icons.cloud_sync : Icons.error_outline,
              size: 56,
              color: isWakingUp ? _sky : _red,
            ),
            const SizedBox(height: 16),
            Text(
              isWakingUp ? 'Server is waking up…' : message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: _ink),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () => context
                  .read<AttendanceStudentBloc>()
                  .add(const LoadAttendanceStudent()),
              child: Text('Retry',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Main content ─────────────────────────────────────────────────────
  Widget _buildContent(
      BuildContext context, AttendanceStudentLoaded attState) {
    final records = attState.records;
    final total = records.length;
    final present =
        records.where((r) => r.studentAttendanceStatus == AttStatus.present).length;
    final absent =
        records.where((r) => r.studentAttendanceStatus == AttStatus.absent).length;
    final late =
        records.where((r) => r.studentAttendanceStatus == AttStatus.late).length;
    final excused =
        records.where((r) => r.studentAttendanceStatus == AttStatus.excused).length;
    final attendanceRate = total > 0 ? (present / total * 100) : 0.0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(context),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),
              _buildMeritCard(context, absent, late),
              const SizedBox(height: 20),
              _buildSummaryCard(total, present, absent, late, excused, attendanceRate),
              const SizedBox(height: 20),
              _buildInsightsSection(context, absent, late),
            ]),
          ),
        ),
      ],
    );
  }

  // ─── App bar ──────────────────────────────────────────────────────────
  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: _bg,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: _ink, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Attendance Overview',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _ink,
        ),
      ),
      centerTitle: true,
      actions: [
        BlocBuilder<AttendanceStudentBloc, AttendanceStudentState>(
          builder: (context, attState) {
            if (attState is! AttendanceStudentLoaded) {
              return const SizedBox.shrink();
            }
            return BlocBuilder<AnalyticsBloc, AnalyticsState>(
              builder: (context, analyticsState) {
                final isLoading = analyticsState is AnalyticsLoading;
                return IconButton(
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(_blue)),
                        )
                      : const Icon(Icons.refresh_rounded,
                          color: _blue, size: 22),
                  onPressed: isLoading
                      ? null
                      : () {
                          _analyticsTriggered = true;
                          final records = attState.records;
                          final absent = records
                              .where((r) =>
                                  r.studentAttendanceStatus == AttStatus.absent)
                              .length;
                          final late = records
                              .where((r) =>
                                  r.studentAttendanceStatus == AttStatus.late)
                              .length;
                          context.read<AnalyticsBloc>().add(
                                RefreshAnalytics(
                                    {'totalAbsences': absent, 'totalLates': late}),
                              );
                        },
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ─── Merit card ───────────────────────────────────────────────────────
  Widget _buildMeritCard(BuildContext context, int absent, int late) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        // Loading skeleton
        if (state is AnalyticsLoading || state is AnalyticsInitial) {
          return _buildMeritSkeleton();
        }

        // Error state
        if (state is AnalyticsError) {
          final isWakingUp = state.message.toLowerCase().contains('waking') ||
              state.message.toLowerCase().contains('taking too long');
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  isWakingUp ? Icons.cloud_sync : Icons.error_outline,
                  size: 40,
                  color: isWakingUp ? _sky : _red,
                ),
                const SizedBox(height: 12),
                Text(
                  isWakingUp
                      ? 'AI server is warming up…'
                      : 'Could not load merit score',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _muted,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    _analyticsTriggered = true;
                    context.read<AnalyticsBloc>().add(
                          RefreshAnalytics(
                              {'totalAbsences': absent, 'totalLates': late}),
                        );
                  },
                  child: Text('Try Again',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _blue)),
                ),
              ],
            ),
          );
        }

        // Loaded
        if (state is AnalyticsLoaded) {
          final score = state.result.meritScore;
          final color = _meritColor(score);
          final label = _meritLabel(score);
          final icon = _meritIcon(score);
          final progress = (score / 100).clamp(0.0, 1.0);

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF2E3192),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Merit Score',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    if (state.fromCache)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Cached',
                          style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$score',
                      style: GoogleFonts.poppins(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 4),
                      child: Text(
                        '/100',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: color.withValues(alpha: 0.4), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 14, color: color),
                          const SizedBox(width: 5),
                          Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMeritSkeleton() {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3192),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Merit Score',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Calculating…',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Summary card ─────────────────────────────────────────────────────
  Widget _buildSummaryCard(int total, int present, int absent, int late,
      int excused, double attendanceRate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Summary',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$total total records',
            style: GoogleFonts.poppins(fontSize: 12, color: _muted),
          ),
          const SizedBox(height: 20),
          // Attendance bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total > 0 ? present / total : 0,
              minHeight: 10,
              backgroundColor: const Color(0xFFF0F4FA),
              valueColor: const AlwaysStoppedAnimation<Color>(_green),
            ),
          ),
          const SizedBox(height: 20),
          // Stat grid
          Row(
            children: [
              Expanded(
                  child:
                      _buildStatBox('Present', present, _green, Icons.check_circle_outline)),
              const SizedBox(width: 12),
              Expanded(
                  child:
                      _buildStatBox('Absent', absent, _red, Icons.cancel_outlined)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildStatBox(
                      'Late', late, _amber, Icons.schedule_outlined)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatBox('Rate',
                      '${attendanceRate.toStringAsFixed(1)}%', _sky,
                      Icons.trending_up_rounded)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, dynamic value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Insights section ─────────────────────────────────────────────────
  Widget _buildInsightsSection(
      BuildContext context, int absent, int late) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state is! AnalyticsLoaded) return const SizedBox.shrink();
        final insights = state.result.insights;
        if (insights.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    size: 18, color: _blue),
                const SizedBox(width: 8),
                Text(
                  'AI Insights',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...insights.asMap().entries.map((entry) {
              return _buildInsightCard(entry.key, entry.value);
            }),
          ],
        );
      },
    );
  }

  Widget _buildInsightCard(int index, String insight) {
    final colors = [_blue, _navy, _sky];
    final color = colors[index % colors.length];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              insight,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _ink,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
