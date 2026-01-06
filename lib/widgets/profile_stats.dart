import 'package:flutter/material.dart';

class StatisticBox extends StatelessWidget {
  const StatisticBox({super.key, required this.witchBox, required this.value});

  final String witchBox;
  final String value;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String label;
    Color iconColor;

    switch (witchBox) {
      case 'dayStreak':
        icon = Icons.local_fire_department;
        label = 'Day Streak';
        iconColor = Colors.orange;
        break;
      case 'totalXP':
        icon = Icons.flash_on;
        label = 'Total XP';
        iconColor = Colors.amber;
        break;
      case 'achievements':
        icon = Icons.emoji_events;
        label = 'Achievements';
        iconColor = Colors.blueAccent;
        break;
      case 'leaderBoard':
        icon = Icons.military_tech;
        label = 'Leader Board';
        iconColor = Colors.deepPurpleAccent;
        break;
      default:
        icon = Icons.error_outline;
        label = 'Error';
        iconColor = Colors.grey;
    }

    return Container(
      width: 153,
      padding: EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Color(0x33000000), width: 3.0),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 40),
          SizedBox(width: 5.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: TextStyle(fontSize: 16)),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}