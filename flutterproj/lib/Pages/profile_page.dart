import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/profile_bloc.dart';
import '../blocs/auth_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProfileBloc>().add(const LoadProfile());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            return _buildLoadedBody(context, state);
          } else if (state is ProfileError) {
            return _buildErrorBody(context, state);
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildLoadedBody(BuildContext context, ProfileLoaded state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Blue curved header
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: double.infinity,
                height: 160,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E3192),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Profile',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.sourceSans3(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // Avatar ni ha
              Positioned(
                bottom: -50,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 52,
                    backgroundColor: Color(0xFFE3E8FC),
                    child: Icon(
                      Icons.person,
                      size: 54,
                      color: Color(0xFF2E3192),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 66),

          // Name and School ID
          Text(
            state.user.fullName,
            style: GoogleFonts.sourceSans3(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1F36),
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: GoogleFonts.sourceSans3(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              children: [
                const TextSpan(text: 'School Id: '),
                TextSpan(
                  text: state.student.documentSeries,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1F36),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          //
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Students Information',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1F36),
                      ),
                    ),
                    const Icon(Icons.tune, color: Color(0xFF2E3192), size: 22),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE8EDF5),
                      width: 1,
                    ),
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
                      _buildInfoField(
                        'Course & Year:',
                        'Year ${state.student.yearLevel}',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoField('School Email:', state.user.email),
                      const SizedBox(height: 16),
                      _buildInfoField(
                        'Student ID:',
                        state.student.documentSeries,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoField(
                        'User Document Series:',
                        state.user.documentSeries,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // LogOut ni yot
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E3192),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                      shadowColor: const Color(0xFF2E3192).withOpacity(0.4),
                    ),
                    onPressed: () {
                      context.read<AuthBloc>().add(const LogoutRequested());
                    },
                    child: Text(
                      'LogOut',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sourceSans3(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E3192),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.sourceSans3(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1F36),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBody(BuildContext context, ProfileError state) {
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                context.read<ProfileBloc>().add(const LoadProfile());
              }
            },
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
