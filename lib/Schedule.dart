import 'package:flutter/material.dart';
import '../home_page.dart'; // Import the home_page.dart file

void main() => runApp(const CalendarApp());

class CalendarApp extends StatelessWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SchedulePage(),
    );
  }
}

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final List<String> days = const ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final List<String> monthNames = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  DateTime currentMonth = DateTime(2025, 7);
  final List<Map<String, dynamic>> appointments = [
    {'title': 'Team Meeting', 'time': '9:00 AM - 10:00 AM', 'day': 9},
    {'title': 'Client Call', 'time': '1:00 PM - 2:00 PM', 'day': 13},
    {'title': 'Follow-up Meeting', 'time': '4:00 PM - 4:30 PM', 'day': 13},
  ];

  int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int getFirstDayOffset(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }

  void changeMonth(int delta) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + delta);
    });
  }

  void showDayAppointments(int day) {
    final dayAppointments = appointments.where((Map<String, dynamic> appt) => appt['day'] == day).toList();
    if (dayAppointments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No appointments on day $day')),
      );
    } else {
      final message = dayAppointments.map((Map<String, dynamic> appt) => '${appt['title']}: ${appt['time']}').join('\n');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointments on day $day:\n$message')),
      );
    }
  }

  void showAddAppointmentDialog({int? selectedDay}) {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    final dayController = TextEditingController(text: selectedDay?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time (e.g., 9:00 AM - 10:00 AM)'),
            ),
            TextField(
              controller: dayController,
              decoration: const InputDecoration(labelText: 'Day of Month'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final title = titleController.text.trim();
              final time = timeController.text.trim();
              final dayText = dayController.text.trim();
              if (title.isEmpty || time.isEmpty || dayText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              final day = int.tryParse(dayText);
              if (day == null || day < 1 || day > getDaysInMonth(currentMonth)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid day')),
                );
                return;
              }
              setState(() {
                appointments.add({
                  'title': title,
                  'time': time,
                  'day': day,
                });
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointment added')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int daysInMonth = getDaysInMonth(currentMonth);
    int firstDayOffset = getFirstDayOffset(currentMonth);
    int totalCells = daysInMonth + firstDayOffset;
    int rows = (totalCells / 7).ceil();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddAppointmentDialog(),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF0D141C)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => changeMonth(-1),
                          child: const Icon(Icons.arrow_back_ios, size: 20),
                        ),
                        Text(
                          "${monthNames[currentMonth.month - 1]} ${currentMonth.year}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () => changeMonth(1),
                          child: const Icon(Icons.arrow_forward_ios, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
                backgroundColor: Colors.grey[100],
                elevation: 0,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: days
                    .map((d) => Text(
                  d,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: MediaQuery.of(context).size.width / 7 * rows,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rows * 7,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    final day = index - firstDayOffset + 1;
                    final hasAppointment = appointments.any((Map<String, dynamic> appt) => appt['day'] == day);
                    return GestureDetector(
                      onTap: () {
                        if (day > 0 && day <= daysInMonth) {
                          showDayAppointments(day);
                        }
                      },
                      onLongPress: () {
                        if (day > 0 && day <= daysInMonth) {
                          showAddAppointmentDialog(selectedDay: day);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 2,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (day > 0 && day <= daysInMonth)
                              Text(
                                "$day",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            const SizedBox(height: 2),
                            if (hasAppointment)
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "Meeting",
                                  style: TextStyle(fontSize: 6),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Scheduled Appointments",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  return AppointmentTile(
                    title: appointments[index]['title'],
                    time: appointments[index]['time'],
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class AppointmentTile extends StatelessWidget {
  final String title;
  final String time;

  const AppointmentTile({
    required this.title,
    required this.time,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title),
        subtitle: Text(time),
        leading: const Icon(Icons.schedule),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}