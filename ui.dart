import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const ReminderApp());

class ReminderApp extends StatefulWidget {
  const ReminderApp({super.key});

  @override
  State<ReminderApp> createState() => _ReminderAppState();
}

class _ReminderAppState extends State<ReminderApp> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<String> activities = [
    'Wake up',
    'Go to gym',
    'Breakfast',
    'Meetings',
    'Lunch',
    'Quick nap',
    'Go to library',
    'Dinner',
    'Go to sleep'
  ];

  String selectedDay = '';
  String selectedTime = '';
  String selectedActivity = '';

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadSavedReminders();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadSavedReminders() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedDay = prefs.getString('selectedDay') ?? '';
      selectedTime = prefs.getString('selectedTime') ?? '';
      selectedActivity = prefs.getString('selectedActivity') ?? '';
    });
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedDay', selectedDay);
    prefs.setString('selectedTime', selectedTime);
    prefs.setString('selectedActivity', selectedActivity);
  }

  Future<void> _setReminder() async {
    if (selectedDay.isEmpty || selectedTime.isEmpty || selectedActivity.isEmpty) {
      // Show an error message or snackbar indicating missing fields
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all fields.'))
      );
      return;
    }

    final dateTime = DateTime.parse(selectedDay + ' ' + selectedTime);
    if (dateTime.isBefore(DateTime.now())) {
      // Show an error message or snackbar indicating invalid date/time
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a future date and time.'))
      );
      return;
    }

    const AndroidNotificationDetails channel = AndroidNotificationDetails(
      'channel_id',
      'Reminder Channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      selectedActivity,
      'It\'s time for your reminder!',
      channel,
      payload: 'reminder',
    );

    _saveReminders();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Reminder App'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedDay,
                onChanged: (value) {
                  setState(() {
                    selectedDay = value!;
                  });
                },
                items: daysOfWeek.map((day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Day of the Week',
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedTime,
                onChanged: (value) {
                  setState(() {
                    selectedTime = value!;
                  });
                },
                items: List.generate(24, (index) {
                  final hour = index < 10 ? '0$index' : '$index';
                  return DropdownMenuItem<String>(
                    value: '$hour:00',
                    child: Text('$hour:00'),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Time',
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedActivity,
                onChanged: (value) {
                  setState(() {
                    selectedActivity = value!;
                  });
                },
                items: activities.map((activity) {
                  return DropdownMenuItem<String>(
                    value: activity,
                    child: Text(activity),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Activity',
                ),
              ),
              ElevatedButton(
                onPressed: _setReminder,
                child: const Text('Set Reminder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}