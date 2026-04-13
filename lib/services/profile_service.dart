import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService {
  final FirebaseFirestore _firestore;

  ProfileService(this._firestore);

  /// Fetches the user profile document.
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchProfile(String uid) {
    return _firestore.collection('users').doc(uid).get();
  }

  /// Updates specific fields in the user profile.
  /// Uses SetOptions(merge: true) to ensure we don't overwrite existing data accidentally.
  Future<void> updateProfile(String uid, Map<String, dynamic> data) {
    return _firestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }
}