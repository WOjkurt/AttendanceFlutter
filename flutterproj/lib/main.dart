import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutterproj/Pages/login.dart';
import 'package:flutterproj/Pages/dashboard_page.dart';
import 'package:flutterproj/blocs/auth_bloc.dart';
import 'package:flutterproj/blocs/profile_bloc.dart';
import 'package:flutterproj/blocs/attendance_student_bloc.dart';
import 'package:flutterproj/blocs/schedule_bloc.dart';
import 'package:flutterproj/blocs/course_bloc.dart';
import 'package:flutterproj/blocs/student_bloc.dart';
import 'package:flutterproj/blocs/reminders_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc()..add(const AuthStatusChecked()),
        ),
        BlocProvider(
          create: (context) => ProfileBloc()..add(const LoadProfile()),
        ),
        BlocProvider(
          create: (context) => AttendanceStudentBloc()..add(const LoadAttendanceStudent()),
        ),
        BlocProvider(
          create: (context) => ScheduleBloc()..add(const LoadSchedules()),
        ),
        BlocProvider(
          create: (context) => CourseBloc()..add(const LoadCourses()),
        ),
        BlocProvider(
          create: (context) => StudentBloc(),
        ),
        BlocProvider(
          create: (context) => RemindersBloc()..add(const LoadReminders()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.sourceSans3TextTheme(),
          fontFamily: GoogleFonts.sourceSans3().fontFamily,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Reactively shows LoginPage or DashboardPage based on auth state.
/// When the session timer expires, AuthBloc emits AuthUnauthenticated
/// and this widget automatically swaps back to LoginPage.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const DashboardPage();
        }
        return const LoginPage();
      },
    );
  }
}
