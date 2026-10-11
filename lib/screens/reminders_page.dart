import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  List<String> reminders = [];

  final TextEditingController reminderController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadReminders();
  }

  Future<void> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      reminders = prefs.getStringList('reminders') ?? [];
    });
  }

  Future<void> saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('reminders', reminders);
  }

  void addReminder() {
    String reminder = reminderController.text.trim();

    if (reminder.isEmpty) {
      return;
    }

    setState(() {
      reminders.add(reminder);
    });

    saveReminders();

    reminderController.clear();

    Navigator.pop(context);
  }

  void deleteReminder(int index) {
    setState(() {
      reminders.removeAt(index);
    });

    saveReminders();
  }

  void showAddReminderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Add Reminder',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: reminderController,
            decoration: const InputDecoration(
              labelText: 'Reminder',
              hintText: 'Example: Take medicine',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 18),
              ),
            ),
            ElevatedButton(
              onPressed: addReminder,
              child: const Text(
                'Add',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Reminders',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: reminders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.alarm,
                    size: 100,
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'No reminders yet',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: showAddReminderDialog,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Add Reminder',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ListTile(
                    leading: const Icon(
                      Icons.alarm,
                      size: 40,
                    ),
                    title: Text(
                      reminders[index],
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        deleteReminder(index);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddReminderDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
      ),
    );
  }
}