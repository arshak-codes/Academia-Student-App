import 'package:flutter/material.dart';
import 'package:new_project/constants.dart';

class TimeTableScreen extends StatelessWidget {
  static String routeName = 'TimeTableScreen';

  const TimeTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Table'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            _buildDaySchedule('Monday'),
            _buildDaySchedule('Tuesday'),
            _buildDaySchedule('Wednesday'),
            _buildDaySchedule('Thursday'),
            _buildDaySchedule('Friday'),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySchedule(String day) {
    return Card(
      color: Colors.black.withOpacity(0.7),
      child: ExpansionTile(
        title: Text(
          day,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        children: [
          _buildClassTile('Mathematics', '08:00 AM - 09:00 AM'),
          _buildClassTile('Science', '09:15 AM - 10:15 AM'),
          _buildClassTile('English', '10:30 AM - 11:30 AM'),
          _buildClassTile('History', '11:45 AM - 12:45 PM'),
          _buildClassTile('Physical Education', '02:00 PM - 03:00 PM'),
        ],
      ),
    );
  }

  Widget _buildClassTile(String subject, String time) {
    return ListTile(
      title: Text(subject, style: const TextStyle(color: Colors.white)),
      subtitle: Text(time, style: const TextStyle(color: Colors.grey)),
      leading: const Icon(Icons.book, color: Colors.green),
    );
  }
}
