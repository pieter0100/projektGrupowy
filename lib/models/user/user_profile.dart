import 'package:hive/hive.dart';

part '../generated/user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile {
  @HiveField(0)
  final String displayName;

  @HiveField(1)
  final int age;

  UserProfile({  // Constructor
    required this.displayName, 
    required this.age 
    });

  Map<String, dynamic> toJson() { // Method to convert to JSON
    return {
      'displayName': displayName,
      'age': age,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) { // Method to create from JSON
    return UserProfile(
      displayName: json['displayName'],
      age: json['age'],
    );
  }

  UserProfile copyWith({ // Method to copy with modifications
    String? displayName, 
    int? age
    }) { 
    return UserProfile(
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
    );
  }

  @override
  String toString() { // Override toString for better readability
    return 'UserProfile(displayName: $displayName, age: $age)';
  }
}