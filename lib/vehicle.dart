import 'package:flutter/material.dart';
import 'db.dart';
import 'editvehicle.dart';

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
    final db = await DBHelper.instance.database;
    final result = await db.query('vehicles');
    setState(() {
      vehicles = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredVehicles = vehicles.where((vehicle) {
      final query = _searchQuery.toLowerCase();

      final matchSearch = vehicle['make'].toLowerCase().contains(query) ||
          vehicle['model'].toLowerCase().contains(query) ||
          vehicle['vin'].toLowerCase().contains(query);

      final matchYear = _selectedYear == 'All' ||
          vehicle['year'].toString() == _selectedYear;

      return matchSearch && matchYear;
    }).toList();

    final allYears = vehicles
        .map((v) => v['year'].toString())
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Details')),
      body: Column(
        children: [
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
                const SizedBox(width: 8), // 间距
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedYear = 'All';
                      _searchQuery = '';
                    });
                  },
                  child: const Text('Clear', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filteredVehicles.length,
              itemBuilder: (context, index) {
                final vehicle = filteredVehicles[index];
                return Card(
                  child: ListTile(
                    title: Text('${vehicle['make']} ${vehicle['model']}'),
                    subtitle: Text('Year: ${vehicle['year']}  •  VIN: ${vehicle['vin']}'),
                    trailing: Icon(Icons.directions_car),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditVehiclePage(vehicle: vehicle),
                        ),
                      );

                      if (result == true) {
                        _loadVehicles();
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

          if (result == true) {
            _loadVehicles();
          }
        },
        child: const Icon(Icons.add),
      ),
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

    print('Save button pressed.');

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

    final db = await DBHelper.instance.database;

    await db.insert('vehicles', {
      'make': make,
      'model': model,
      'year': year,
      'vin': vin,
      'notes': notes,
    });

    Navigator.pop(context, true);
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



