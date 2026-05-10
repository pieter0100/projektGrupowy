import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/widgets/profile_field.dart';

// --- DODANE IMPORTY (Upewnij się, że ścieżki się zgadzają!) ---
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:projekt_grupowy/game_logic/local_saves.dart';
import 'package:projekt_grupowy/models/user/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:projekt_grupowy/services/profile_picture_service.dart';

class PersonalData extends StatefulWidget {
  const PersonalData({super.key});

  @override
  State<PersonalData> createState() => _PersonalDataState();
}

class _PersonalDataState extends State<PersonalData> {
  User? _currentUser;
  String? _firebaseEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // 1. Pobierz obecnego użytkownika z Firebase (aby mieć jego ID oraz Email)
      final firebaseUser = auth.FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        final uid = firebaseUser.uid;
        
        // 2. Pobierz resztę danych z lokalnej bazy Hive
        final user = LocalSaves.getUser(uid);

        setState(() {
          _currentUser = user;
          _firebaseEmail = firebaseUser.email; 
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData(String fieldType, String newValue) async {
    try {
      final firebaseUser = auth.FirebaseAuth.instance.currentUser;
      
      if (firebaseUser == null || _currentUser == null) {
        return;
      }

      final uid = firebaseUser.uid;
      final updatedUser = _currentUser!;

      // Update the appropriate field
      if (fieldType == 'nick') {
        final updatedProfile = _currentUser!.profile.copyWith(nick: newValue);
        final updatedUserObj = updatedUser.copyWith(profile: updatedProfile);
        
        // Save to Hive
        await LocalSaves.saveUser(updatedUserObj);
        
        // Save to Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'profile.nick': newValue
        });

        setState(() {
          _currentUser = updatedUserObj;
        });
      } else if (fieldType == 'name') {
        final updatedProfile = _currentUser!.profile.copyWith(displayName: newValue);
        final updatedUserObj = updatedUser.copyWith(profile: updatedProfile);
        
        // Save to Hive
        await LocalSaves.saveUser(updatedUserObj);
        
        // Save to Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'profile.displayName': newValue
        });

        setState(() {
          _currentUser = updatedUserObj;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Widget _buildProfilePictureWidget() {
    // If no profile picture path, show placeholder immediately
    if (_currentUser?.profile.profilePicturePath == null || 
        _currentUser!.profile.profilePicturePath!.isEmpty) {
      return const Center(
        child: Icon(Icons.person, size: 60, color: Colors.grey),
      );
    }

    // If there's a path, try to load the image
    return FutureBuilder<File?>(
      future: ProfilePictureService.getProfilePicture(_currentUser!.profile.profilePicturePath!),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return ClipOval(
            child: Image.file(
              snapshot.data!,
              fit: BoxFit.cover,
            ),
          );
        }

        // Placeholder: show silhouette icon
        return const Center(
          child: Icon(Icons.person, size: 60, color: Colors.grey),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _currentUser?.profile.displayName ?? _currentUser?.profile.nick ?? '';
    final nick = _currentUser?.profile.nick ?? 'unknown';
    final email = _firebaseEmail ?? 'No email found';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Data'),
        backgroundColor: const Color(0xFFE5E5E5),
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          onPressed: ()  {
            if (context.canPop()) {
                context.pop();
            } else {
              context.go('/settings'); 
            }
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 24.0),

                  // PROFILE PICTURE
                  Center(
                    child: Text(
                      "Profile picture",
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // AVATAR IMAGE
                        Container(
                          width: 115,
                          height: 115,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300,
                          ),
                          child: _buildProfilePictureWidget(),
                        ),

                        // EDIT ICON
                        Positioned(
                          bottom: 0,
                          right: -15,
                          child: Container(
                            decoration: const BoxDecoration(shape: BoxShape.circle),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 24,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  ProfileField(
                    label: 'Nick:',
                    initialValue: nick,
                    onSave: (value) => _updateUserData('nick', value),
                  ),
                  ProfileField(
                    label: 'Name:',
                    initialValue: displayName,
                    onSave: (value) => _updateUserData('name', value),
                  ),
                  ProfileField(label: 'Email:', initialValue: email),
                ],
              ),
            ),
    );
  }
}