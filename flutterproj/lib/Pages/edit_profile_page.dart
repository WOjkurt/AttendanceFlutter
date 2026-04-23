import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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
  late TextEditingController _greetingController;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _greetingController = TextEditingController(text: widget.currentUser.greeting);
  }

  @override
  void dispose() {
    _greetingController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image.'), backgroundColor: Colors.red),
      );
    }
  }

  ImageProvider _getProfileImage() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (widget.currentUser.profileImageUrl.startsWith('http')) {
      return NetworkImage(widget.currentUser.profileImageUrl);
    } else {
      return FileImage(File(widget.currentUser.profileImageUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditProfileBloc(),
      child: BlocListener<EditProfileBloc, EditProfileState>(
        listener: (context, state) {
          if (state is EditProfileSuccess) {
            // Update the main profile bloc
            final updatedProfile = UserProfile(
              greeting: _greetingController.text,
              name: widget.currentUser.name,
              schoolId: widget.currentUser.schoolId,
              courseAndYear: widget.currentUser.courseAndYear,
              schoolEmail: widget.currentUser.schoolEmail,
              phoneNumber: widget.currentUser.phoneNumber,
              homeAddress: widget.currentUser.homeAddress,
              profileImageUrl: _imageFile?.path ?? widget.currentUser.profileImageUrl,
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
          ),
          body: BlocBuilder<EditProfileBloc, EditProfileState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _getProfileImage(),
                          ),
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1A50FE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildInputField('Greeting', _greetingController),
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
                                        greeting: _greetingController.text,
                                        profileImagePath: _imageFile?.path,
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
