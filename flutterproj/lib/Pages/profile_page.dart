import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/profile_bloc.dart';
import '../blocs/auth_bloc.dart' as auth;
import 'reminders_page.dart';
import 'qr_scan_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileError) {
              return Center(child: Text(state.message));
            } else if (state is ProfileLoaded) {
              return _buildProfileContent(context, state.userProfile);
            }
            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      );
  }

  Widget _buildProfileContent(BuildContext context, UserProfile user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header & Avatar Stack
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Blue Curved Header
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  width: double.infinity,
                  height: 250,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A50FE), // Primary Blue
                  ),
                  child: const SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
                        'Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Overlapping Profile Avatar
              Positioned(
                top: 150,
                child: Container(
                  padding: const EdgeInsets.all(4), // White border
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundImage: user.profileImageUrl.startsWith('http') 
                        ? NetworkImage(user.profileImageUrl) as ImageProvider
                        : FileImage(File(user.profileImageUrl)),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 70), // Spacing for avatar overlap

          // User Name & ID
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "School Id: ",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A50FE),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                user.schoolId,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Students Information Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Students Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.tune, color: Colors.blue[600]),
                      onPressed: () {
                        final profileBloc = context.read<ProfileBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (routeContext) => EditProfilePage(
                              currentUser: user,
                              profileBloc: profileBloc,
                            ),
                          ),
                        );
                      },
                    ), 
                  ],
                ),
                const SizedBox(height: 16),
                
                // Information Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Course & Year:', user.courseAndYear),
                      const SizedBox(height: 16),
                      _buildInfoRow('School Email:', user.schoolEmail),
                      const SizedBox(height: 16),
                      _buildInfoRow('Phone Number:', user.phoneNumber),
                      const SizedBox(height: 16),
                      _buildInfoRow('Home Address:', user.homeAddress),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Logout Button
                Center(
                  child: SizedBox(
                    width: 160,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<auth.AuthBloc>().add(const auth.LogoutRequested());
                        context.read<ProfileBloc>().add(LogoutRequested());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A50FE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'LogOut',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B8AFF),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Home
            InkWell(
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Icon(
                Icons.home_rounded,
                color: Colors.grey.shade400,
                size: 28,
              ),
            ),
            // Reminders
            InkWell(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RemindersPage()));
              },
              child: Icon(
                Icons.folder_outlined,
                color: Colors.grey.shade400,
                size: 28,
              ),
            ),
            // QR Scan / Attendance
            InkWell(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const QrScanPage()));
              },
              child: Icon(
                Icons.access_time_outlined,
                color: Colors.grey.shade400,
                size: 28,
              ),
            ),
            // Profile — active
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline, color: Colors.blue.shade700, size: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Clipper for the Blue Header
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40); // Start curve higher up
    // Quadratic bezier curve dips down towards the center
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0); // Go up to top right
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class UserProfile {
  final String greeting;
  final String name;
  final String schoolId;
  final String courseAndYear;
  final String schoolEmail;
  final String phoneNumber;
  final String homeAddress;
  final String profileImageUrl;

  UserProfile({
    required this.greeting,
    required this.name,
    required this.schoolId,
    required this.courseAndYear,
    required this.schoolEmail,
    required this.phoneNumber,
    required this.homeAddress,
    required this.profileImageUrl,
  });
}
