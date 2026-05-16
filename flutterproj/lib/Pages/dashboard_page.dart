import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/profile_bloc.dart';
import '../blocs/attendance_student_bloc.dart';
import '../blocs/schedule_bloc.dart';
import '../blocs/course_bloc.dart';
import '../blocs/reminders_bloc.dart';
import 'home_page.dart';
import 'reminders_page.dart';
import 'qr_scan_page.dart';
import 'profile_page.dart';
import 'course_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  bool _isWarmingUp = true;

  static const Color _activeColor = Color(0xFF2E3192);

  late final List<Widget> _pages;

  Future<void> _warmUpServers() async {
    final servers = [
      'https://k-group-ams-dbtc-11f4.onrender.com/',
      'https://ai-integration-qbk5.onrender.com/',
    ];
    await Future.wait(
      servers.map((url) => http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 90))
          .catchError((_) => http.Response('', 0))),
    );
  }

  @override
  void initState() {
    super.initState();
    _pages = const [
      HomePage(),
      CoursePage(),
      RemindersPage(),
      QrScanPage(),
      ProfilePage(),
    ];

    Future.microtask(() async {
      await _warmUpServers();
      if (!mounted) return;
      
      setState(() {
        _isWarmingUp = false;
      });

      context.read<ProfileBloc>().add(const LoadProfile());
      context.read<AttendanceStudentBloc>().add(const LoadAttendanceStudent());
      context.read<ScheduleBloc>().add(const LoadSchedule());
      context.read<CourseBloc>().add(const LoadCourses());
    });
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isWarmingUp 
          ? _buildWarmingUpScreen()
          : BlocListener<ScheduleBloc, ScheduleState>(
              listener: (context, state) {
                if (state is ScheduleLoaded) {
                  context.read<RemindersBloc>().add(LoadReminders(state.schedules));
                }
              },
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
      bottomNavigationBar: _isWarmingUp ? null : _buildBottomNavigationBar(),
    );
  }

  Widget _buildWarmingUpScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_activeColor),
          ),
          const SizedBox(height: 24),
          Text(
            'Connecting to servers...',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1F36),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'This may take a moment if the system is waking up.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF8E99A8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(index: 0, icon: Icons.home_rounded,            label: 'Home'),
            _buildNavItem(index: 1, icon: Icons.library_books_rounded,   label: 'Courses'),
            _buildNavItem(index: 2, icon: Icons.calendar_today_rounded,  label: 'Reminders'),
            _buildNavItem(index: 3, icon: Icons.qr_code_scanner_rounded, label: 'Scan'),
            _buildNavItem(index: 4, icon: Icons.person_outline_rounded,  label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // Single reusable nav item — used for ALL tabs including Scan.
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      splashColor: _activeColor.withValues(alpha: 0.1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _activeColor.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? _activeColor : Colors.grey.shade400,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? _activeColor : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
