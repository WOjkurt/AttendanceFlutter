import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutterproj/Pages/login.dart';
import 'package:flutterproj/Pages/dashboard.dart';
import 'package:flutterproj/blocs/auth_bloc.dart';
import 'package:flutterproj/blocs/profile_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
          create: (context) => ProfileBloc()..add(LoadProfileData()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
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
