import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_page.dart';
import 'qr_scan_page.dart';
import '../blocs/reminders_bloc.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RemindersBloc(),
      child: const _RemindersPageContent(),
    );
  }
}

class _RemindersPageContent extends StatelessWidget {
  const _RemindersPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 10),
            _buildDaySelector(context),
            const SizedBox(height: 20),
            Expanded(
              child: _buildClassList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Balance the avatar width
          
          const Text(
            'Reminders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Funnel',
            ),
          ),
          
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector(BuildContext context) {
    final List<String> days = ['M', 'T', 'W', 'TH', 'F', 'S'];

    return BlocBuilder<RemindersBloc, RemindersState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24.0),
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1A50FE),
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: days.map((day) {
              final isSelected = state.selectedDay == day;
              
              return GestureDetector(
                onTap: () {
                  context.read<RemindersBloc>().add(SelectDay(day));
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF1A50FE) : Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildClassList() {
    return BlocBuilder<RemindersBloc, RemindersState>(
      builder: (context, state) {
        if (state.classesForDay.isEmpty) {
          return const Center(
            child: Text(
              "No classes scheduled for this day.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          itemCount: state.classesForDay.length,
          itemBuilder: (context, index) {
            final classData = state.classesForDay[index];
            return _buildClassCard(classData);
          },
        );
      },
    );
  }

  Widget _buildClassCard(ClassSchedule classData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFEBF0FF), width: 2), // Light blue border
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A50FE).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            classData.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.access_time_outlined,
                size: 18,
                color: Color(0xFF1A50FE),
              ),
              const SizedBox(width: 8),
              Text(
                classData.time,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B8AFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Color(0xFF1A50FE),
              ),
              const SizedBox(width: 8),
              Text(
                classData.location,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B8AFF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: Border.all(color: Colors.grey.shade200, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home_outlined, false, () {
              Navigator.popUntil(context, (route) => route.isFirst);
            }),
            _buildRemindersNavItem(),
            _buildNavItem(Icons.access_time, false, () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const QrScanPage()));
            }),
            _buildNavItem(Icons.person_outline, false, () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isPrimaryColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        icon,
        color: isPrimaryColor ? const Color(0xFF1A50FE) : const Color(0xFF6B8AFF).withOpacity(0.8),
        size: 28,
      ),
    );
  }

  Widget _buildRemindersNavItem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF0FF),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.folder, 
            color: Color(0xFF1A50FE),
            size: 22,
          ),
          const SizedBox(width: 8),
          const Text(
            'Reminders',
            style: TextStyle(
              color: Color(0xFF1A50FE),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
