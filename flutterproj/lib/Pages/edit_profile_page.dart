import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/edit_profile_bloc.dart';
import '../blocs/profile_bloc.dart';
import 'profile_page.dart'; // To get UserProfile definition

class EditProfilePage extends StatefulWidget {
  final UserProfile currentUser;
  final ProfileBloc profileBloc;

  const EditProfilePage({
    Key? key,
    required this.currentUser,
    required this.profileBloc,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    // Try to split the name into first and last, roughly.
    final nameParts = widget.currentUser.name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _emailController = TextEditingController(text: widget.currentUser.schoolEmail);
    _phoneController = TextEditingController(text: widget.currentUser.phoneNumber);
    _addressController = TextEditingController(text: widget.currentUser.homeAddress);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditProfileBloc(),
      child: BlocListener<EditProfileBloc, EditProfileState>(
        listener: (context, state) {
          if (state is EditProfileSuccess) {
            // Update the main profile bloc
            final fullName = '${_firstNameController.text} ${_lastNameController.text}'.trim();
            final updatedProfile = UserProfile(
              name: fullName,
              schoolId: widget.currentUser.schoolId, // ID doesn't change
              courseAndYear: widget.currentUser.courseAndYear, // Course doesn't change
              schoolEmail: _emailController.text,
              phoneNumber: _phoneController.text,
              homeAddress: _addressController.text,
              profileImageUrl: widget.currentUser.profileImageUrl,
            );
            
            widget.profileBloc.add(UpdateProfileData(updatedProfile));
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile Updated Successfully!'), backgroundColor: Colors.green),
            );
            Navigator.pop(context); // Go back to profile page
          } else if (state is EditProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(widget.currentUser.profileImageUrl),
                  ),
                ),
              ),
            ],
          ),
          body: BlocBuilder<EditProfileBloc, EditProfileState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  children: [
                    _buildInputField('First Name', _firstNameController),
                    const SizedBox(height: 16),
                    _buildInputField('Last Name', _lastNameController),
                    const SizedBox(height: 16),
                    _buildInputField('Email', _emailController),
                    const SizedBox(height: 16),
                    _buildInputField('Phone Number', _phoneController),
                    const SizedBox(height: 16),
                    _buildInputField('Address', _addressController),
                    const SizedBox(height: 40),
                    
                    // Submit Button
                    SizedBox(
                      width: 160,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: state is EditProfileLoading
                            ? null
                            : () {
                                context.read<EditProfileBloc>().add(
                                      UpdateProfileSubmitted(
                                        firstName: _firstNameController.text,
                                        lastName: _lastNameController.text,
                                        email: _emailController.text,
                                        phone: _phoneController.text,
                                        address: _addressController.text,
                                      ),
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A50FE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: state is EditProfileLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF), // Very light blue fill
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF6B8AFF).withOpacity(0.5), // Light blue border
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextFormField(
            controller: controller,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.only(top: 4, bottom: 4),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
