import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile {
  @HiveField(0)
  final String? displayName;

  @HiveField(1)
  final int age;

  @HiveField(2)
  final String nick;

  UserProfile({  // Constructor
    this.displayName, 
    required this.age,
    required this.nick
    });

  Map<String, dynamic> toJson() { // Method to convert to JSON
    return {
      'displayName': displayName,
      'age': age,
      'nick': nick,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) { // Method to create from JSON
    return UserProfile(
      displayName: json['displayName'],
      age: json['age'],
      nick: json['nick'],
    );
  }

  UserProfile copyWith({ // Method to copy with modifications
    String? displayName, 
    int? age,
    String? nick
    }) { 
    return UserProfile(
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      nick: nick ?? this.nick,
    );
  }

  @override
  String toString() { // Override toString for better readability
    return 'UserProfile(displayName: $displayName, age: $age, nick: $nick)';
  }
}