import 'package:flutter/material.dart';
import 'editvehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_scaffold.dart'; // ✅ 确保导入 base_scaffold

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  List<Map<String, dynamic>> vehicles = [];
  String _searchQuery = '';
  String _selectedYear = 'All';

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('vehicles').get();

    final data = snapshot.docs.map((doc) {
      final vehicle = doc.data();
      vehicle['docId'] = doc.id;

      // ✅ 统一 year 为 string，避免类型冲突
      final year = vehicle['year'];
      if (year == null) {
        vehicle['year'] = '';
      } else if (year is int) {
        vehicle['year'] = year.toString();
      } else if (year is String) {
        vehicle['year'] = year;
      } else {
        vehicle['year'] = '';
      }

      return vehicle;
    }).toList();

    setState(() {
      vehicles = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredVehicles = vehicles.where((vehicle) {
      final query = _searchQuery.toLowerCase();

      final matchSearch = (vehicle['make'] ?? '')
          .toString()
          .toLowerCase()
          .contains(query) ||
          (vehicle['model'] ?? '')
              .toString()
              .toLowerCase()
              .contains(query) ||
          (vehicle['vin'] ?? '')
              .toString()
              .toLowerCase()
              .contains(query);

      final matchYear =
          _selectedYear == 'All' || vehicle['year'].toString() == _selectedYear;

      return matchSearch && matchYear;
    }).toList();

    final allYears = vehicles
        .map((v) => v['year'].toString())
        .where((y) => y.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    return BaseScaffold(
      title: "Vehicle Details",
      currentIndex: 1, // ✅ Vehicle tab 高亮
      body: Column(
        children: [
          // 🔍 搜索栏
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // 🔽 年份筛选
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Year',
                      border: OutlineInputBorder(),
                    ),
                    items: ['All', ...allYears]
                        .map((year) => DropdownMenuItem(
                      value: year,
                      child: Text(year),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedYear = 'All';
                      _searchQuery = '';
                    });
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),

          // 📋 车辆列表
          Expanded(
            child: ListView.builder(
              itemCount: filteredVehicles.length,
              itemBuilder: (context, index) {
                final vehicle = filteredVehicles[index];
                return Card(
                  child: ListTile(
                    title: Text(
                        '${vehicle['make'] ?? ''} ${vehicle['model'] ?? ''}'),
                    subtitle: Text(
                        'Year: ${vehicle['year'] ?? ''}  •  VIN: ${vehicle['vin'] ?? ''}'),
                    trailing: const Icon(Icons.directions_car),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditVehiclePage(vehicle: vehicle),
                        ),
                      );

                      if (result == 'edited' || result == 'deleted') {
                        await _loadVehicles();
                        final msg = result == 'edited'
                            ? 'Vehicle updated successfully!'
                            : 'Vehicle deleted successfully!';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(msg)),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddVehiclePage()),
          );

          if (result == 'added') {
            await _loadVehicles();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vehicle added successfully!')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final TextEditingController makeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController vinController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  Future<void> _saveVehicle() async {
    final make = makeController.text;
    final model = modelController.text;
    final year = int.tryParse(yearController.text) ?? 0;
    final vin = vinController.text;
    final notes = notesController.text;

    if (make.isEmpty || model.isEmpty || vin.isEmpty || year == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('vehicles').add({
      'make': make,
      'model': model,
      'year': year,
      'vin': vin,
      'notes': notes,
    });

    Navigator.pop(context, 'added');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Vehicle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: makeController,
              decoration: const InputDecoration(labelText: 'Make'),
            ),
            TextField(
              controller: modelController,
              decoration: const InputDecoration(labelText: 'Model'),
            ),
            TextField(
              controller: yearController,
              decoration: const InputDecoration(labelText: 'Year'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: vinController,
              decoration: const InputDecoration(labelText: 'VIN'),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Service History / Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveVehicle,
              child: const Text('Save Vehicle'),
            ),
          ],
        ),
      ),
    );
  }
}








