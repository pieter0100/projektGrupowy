import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/widgets/profile_field.dart';

// --- DODANE IMPORTY (Upewnij się, że ścieżki się zgadzają!) ---
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:projekt_grupowy/game_logic/local_saves.dart';
import 'package:projekt_grupowy/models/user/user.dart';

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
      print("Błąd podczas ładowania danych użytkownika: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. Przygotuj wartości (z zabezpieczeniem na wypadek braku danych)
    final displayName = _currentUser?.profile.displayName ?? 'Brak nazwy';
    final email = _firebaseEmail ?? 'Brak emaila';
    
    // Tworzymy przykładowy "Nick" na podstawie imienia, 
    // lub możesz to zmienić, jeśli masz osobne pole w modelu.
    final nick = '@${displayName.toLowerCase().replaceAll(' ', '')}';

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
      
      // 4. Jeśli ładuje, pokaż kółko. Jeśli skończył, pokaż formularz.
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
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://www.krauseschocolates.com/cdn/shop/products/NUMBER_POP_LARGE-_6_7_1024x1024.jpg?v=1496260776',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
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

                  // FORM FIELDS Z DYNAMICZNYMI DANYMI
                  ProfileField(label: 'Nick:', initialValue: nick),
                  ProfileField(label: 'Name:', initialValue: displayName),
                  ProfileField(label: 'Email:', initialValue: email),
                ],
              ),
            ),
    );
  }
}