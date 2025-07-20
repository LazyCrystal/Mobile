import 'package:flutter/material.dart';
import 'package:mobileassignment1/db.dart'; // 修改为你的 DBHelper 路径

class EditVehiclePage extends StatefulWidget {
  final Map<String, dynamic> vehicle;

  const EditVehiclePage({super.key, required this.vehicle});

  @override
  State<EditVehiclePage> createState() => _EditVehiclePageState();
}

class _EditVehiclePageState extends State<EditVehiclePage> {
  late TextEditingController makeController;
  late TextEditingController modelController;
  late TextEditingController yearController;
  late TextEditingController vinController;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    makeController = TextEditingController(text: widget.vehicle['make']);
    modelController = TextEditingController(text: widget.vehicle['model']);
    yearController = TextEditingController(text: widget.vehicle['year'].toString());
    vinController = TextEditingController(text: widget.vehicle['vin']);
    notesController = TextEditingController(text: widget.vehicle['notes']);
  }

  @override
  void dispose() {
    makeController.dispose();
    modelController.dispose();
    yearController.dispose();
    vinController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _updateVehicle() async {
    final updatedVehicle = {
      'make': makeController.text,
      'model': modelController.text,
      'year': int.tryParse(yearController.text) ?? 0,
      'vin': vinController.text,
      'notes': notesController.text,
    };

    final db = await DBHelper.instance.database;

    await db.update(
      'vehicles',
      updatedVehicle,
      where: 'id = ?',
      whereArgs: [widget.vehicle['id']],
    );

    Navigator.pop(context, true); // 返回并刷新
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this vehicle?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = await DBHelper.instance.database;
      await db.delete(
        'vehicles',
        where: 'id = ?',
        whereArgs: [widget.vehicle['id']],
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Vehicle')),
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
              onPressed: _updateVehicle,
              child: const Text('Update Vehicle'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _confirmDelete,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Vehicle'),
            ),
          ],
        ),
      ),
    );
  }
}
