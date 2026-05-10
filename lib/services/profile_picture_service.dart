import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ProfilePictureService {
  static const String _profilePicturesFolder = 'profile_pictures';

  /// Get the directory where profile pictures are stored
  static Future<Directory> _getProfilePicturesDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${appDocDir.path}/$_profilePicturesFolder');
    
    // Create the directory if it doesn't exist
    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }
    
    return profileDir;
  }

  /// Save a profile picture from a file path and return the stored path
  /// Returns the local path where the image was saved
  static Future<String> saveProfilePicture({
    required String userId,
    required String sourceImagePath,
  }) async {
    try {
      final profileDir = await _getProfilePicturesDirectory();
      final sourceFile = File(sourceImagePath);
      
      if (!await sourceFile.exists()) {
        throw Exception('Source image file does not exist');
      }
      
      // Generate a unique filename using userId and UUID
      final fileName = '${userId}_${const Uuid().v4()}.jpg';
      final destinationPath = '${profileDir.path}/$fileName';
      
      // Copy the file to the app documents directory
      await sourceFile.copy(destinationPath);
      
      return destinationPath;
    } catch (e) {
      throw Exception('Failed to save profile picture: $e');
    }
  }

  /// Get the profile picture file if it exists
  static Future<File?> getProfilePicture(String picturePath) async {
    if (picturePath.isEmpty) {
      return null;
    }
    
    final file = File(picturePath);
    if (await file.exists()) {
      return file;
    }
    
    return null;
  }

  /// Delete a profile picture
  static Future<bool> deleteProfilePicture(String picturePath) async {
    try {
      final file = File(picturePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to delete profile picture: $e');
    }
  }

  /// Delete all profile pictures for a user
  static Future<bool> deleteAllUserProfilePictures(String userId) async {
    try {
      final profileDir = await _getProfilePicturesDirectory();
      
      // Find all files that start with userId
      final files = profileDir.listSync();
      bool deletedAny = false;
      
      for (var file in files) {
        if (file is File && file.path.contains(userId)) {
          await file.delete();
          deletedAny = true;
        }
      }
      
      return deletedAny;
    } catch (e) {
      throw Exception('Failed to delete user profile pictures: $e');
    }
  }
}
