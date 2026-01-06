import 'package:flutter/material.dart';
import 'package:projekt_grupowy/widgets/profile_stats.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        backgroundColor: Color(0xFFE5E5E5),
        scrolledUnderElevation: 0.0,
      ),
      body: Column(children: [ProfileHeader(), StatisticsSection()]),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 25.0,
        bottom: 25.0,
        left: 10.0,
        right: 10.0,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x33000000), width: 3.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Imie Nazwisko',
                style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.black,
                  height: 1.0,
                ),
              ),
              Text(
                'pobrany nick',
                style: TextStyle(fontSize: 20.0, color: Color(0x88000000)),
              ),
              Row(
                children: [
                  Icon(
                    Icons.access_time_filled,
                    size: 16.0,
                    color: Color(0x88000000),
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    'pobrane data',
                    style: TextStyle(fontSize: 15.0, height: 2.5),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: 30.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text('picture')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 25.0,
        bottom: 25.0,
        left: 10.0,
        right: 10.0,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 25.0,
                      color: Colors.black,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 30.0),
              Column(children: [SizedBox(width: 190)]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  StatisticBox(witchBox: 'dayStreak', value: '67'),
                  SizedBox(height: 15.0),
                  StatisticBox(witchBox: 'achievements', value: '6 7',),
                ],
              ),
              SizedBox(width: 15.0),
              Column(
                children: [
                  StatisticBox(witchBox: 'totalXP', value: '67'),
                  SizedBox(height: 15.0),
                  StatisticBox(witchBox: 'leaderBoard', value: '6 7',),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
