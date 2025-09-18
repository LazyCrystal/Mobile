import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'base_scaffold.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Firestore collections.
  final CollectionReference appointments =
  FirebaseFirestore.instance.collection('appointments');
  final CollectionReference workAssignments =
  FirebaseFirestore.instance.collection('workAssignments');
  final CollectionReference vehicles =
  FirebaseFirestore.instance.collection('vehicles');
  final CollectionReference inventory =
  FirebaseFirestore.instance.collection('Inventory');

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
    _checkUnfinishedWork();
  }

  // ----------------- Appointment -------------------
  void _loadAppointments() {
    appointments.snapshots().listen((snapshot) {
      Map<DateTime, List<Map<String, dynamic>>> newEvents = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['date'] == null) continue;
        final date = DateTime.parse(data['date']);
        final normalizedDate = DateTime(date.year, date.month, date.day);
        if (newEvents[normalizedDate] == null) {
          newEvents[normalizedDate] = [];
        }
        newEvents[normalizedDate]!.add({
          'id': doc.id,
          'title': data['title'],
          'date': date,
        });
      }
      setState(() {
        _events = newEvents;
      });
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Future<void> _addAppointment() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TextEditingController titleController = TextEditingController();

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Add Appointment"),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  await appointments.add({
                    'title': titleController.text,
                    'date': pickedDate.toIso8601String(),
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      );
    }
  }

  Future<void> _editAppointment(Map<String, dynamic> event) async {
    TextEditingController titleController =
    TextEditingController(text: event['title']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Appointment"),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: "Title"),
        ),
        actions: [
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              await appointments.doc(event['id']).delete();
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await appointments.doc(event['id']).update({
                  'title': titleController.text,
                });
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  // ----------------- Work Assignment -------------------
  Future<void> _addWorkAssignment() async {
    String? selectedVehicle;
    DateTime? selectedDate;
    TextEditingController taskController = TextEditingController();

    final vehicleSnapshot = await vehicles.get();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Assign Work"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Select Vehicle"),
                items: vehicleSnapshot.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child:
                    Text("${data['make']} ${data['model']} (${data['year']})"),
                  );
                }).toList(),
                onChanged: (val) => selectedVehicle = val,
              ),
              TextField(
                controller: taskController,
                decoration: const InputDecoration(labelText: "Task"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                child: Text(
                  selectedDate == null
                      ? "Pick Date"
                      : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
                ),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setDialogState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              child: const Text("Assign"),
              onPressed: () async {
                if (selectedVehicle != null &&
                    taskController.text.isNotEmpty &&
                    selectedDate != null) {
                  await workAssignments.add({
                    'vehicleId': selectedVehicle,
                    'task': taskController.text,
                    'status': 'Pending',
                    'assignedDate': selectedDate!.toIso8601String(),
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeAssignment(
      String assignmentId, String vehicleId, String task, DateTime assignedDate) async {
    await workAssignments.doc(assignmentId).update({'status': 'Complete'});

    await vehicles.doc(vehicleId).collection('serviceHistory').add({
      'task': task,
      'date': assignedDate.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Work marked as complete and added to history")),
    );
  }

  Future<void> _checkUnfinishedWork() async {
    final now = DateTime.now();
    final snapshot = await workAssignments
        .where('status', isEqualTo: 'Pending')
        .get();

    int overdueCount = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['assignedDate'] != null) {
        DateTime assigned = DateTime.parse(data['assignedDate']);
        if (assigned.isBefore(now.subtract(const Duration(days: 2)))) {
          overdueCount++;
        }
      }
    }

    if (overdueCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text(
              "⚠ Overdue Work Warning",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            content: Text(
              "There are $overdueCount work assignments overdue for more than 2 days!\n\nPlease resolve them immediately.",
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        );
      });
    }
  }

  // ----------------- UI -------------------
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Schedule",
      currentIndex: 2,
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Appointments"),
              Tab(text: "Work Assignments"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // --- Appointments tab ---
                Column(
                  children: [
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      eventLoader: _getEventsForDay,
                      enabledDayPredicate: (day) {
                        return !day.isBefore(DateTime.now()
                            .subtract(const Duration(days: 1)));
                      },
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        children: _getEventsForDay(_selectedDay ?? _focusedDay)
                            .map((event) => ListTile(
                          title: Text(event['title']),
                          subtitle: Text(event['date']
                              .toString()
                              .split(' ')[0]),
                          onTap: () => _editAppointment(event),
                        ))
                            .toList(),
                      ),
                    ),
                  ],
                ),

                // --- Work Assignments tab ---
                StreamBuilder<QuerySnapshot>(
                  stream: workAssignments.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(data['task'] ?? ''),
                          subtitle: Text(
                              "Status: ${data['status']} • Date: ${data['assignedDate']?.toString().split('T')[0] ?? ''}"),
                          trailing: data['status'] == 'Pending'
                              ? ElevatedButton(
                            onPressed: () => _completeAssignment(
                              docs[index].id,
                              data['vehicleId'],
                              data['task'],
                              DateTime.parse(data['assignedDate']),
                            ),
                            child: const Text("Complete"),
                          )
                              : const Icon(Icons.check, color: Colors.green),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _addAppointment();
          } else {
            _addWorkAssignment();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
