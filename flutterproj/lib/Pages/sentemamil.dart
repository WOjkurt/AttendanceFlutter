import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/sent_email_bloc.dart';

class SentEmailScreen extends StatefulWidget {
  const SentEmailScreen({super.key});

  @override
  State<SentEmailScreen> createState() => _SentEmailScreenState();
}

class _SentEmailScreenState extends State<SentEmailScreen> {
  int _selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Sent Emails',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins', 
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: const AssetImage('assets/images/dblogo.png'), 
              backgroundColor: Colors.grey[200],
            ),
          )
        ],
      ),
      body: BlocProvider(
        create: (context) => SentEmailBloc()..add(LoadSentEmails()),
        child: BlocBuilder<SentEmailBloc, SentEmailState>(
          builder: (context, state) {
            if (state is SentEmailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SentEmailLoaded) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: state.emails.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildEmailCard(
                        title: state.emails[index],
                        onTap: () {},
                      ),
                    );
                  },
                ),
              );
            } else if (state is SentEmailError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink(); // Initial state
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF65B4FF),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Compose",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildEmailCard({required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.mail_outline, color: Color(0xFF1A6FC4)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF1A6FC4), size: 20),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.home, index: 0),
          _buildNavItem(icon: Icons.folder_open, index: 1),
          _buildNavItem(icon: Icons.history, index: 2),
          _buildNavItem(
            icon: Icons.sms_outlined, 
            index: 3, 
            label: "Absence Email",
            isActive: true,
          ),
          _buildNavItem(icon: Icons.person_outline, index: 4),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon, 
    required int index, 
    String? label, 
    bool isActive = false,
  }) {
    final color = const Color(0xFF1A6FC4);
    
    if (isActive && label != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20), 
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      );
    }
    
    return IconButton(
      icon: Icon(icon, color: color, size: 26),
      onPressed: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}
