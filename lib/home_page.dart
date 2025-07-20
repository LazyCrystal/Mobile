import 'package:flutter/material.dart';
import 'vehicle.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workshop Management')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.directions_car),
              label: const Text('Vehicle Details Management'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VehiclePage()),
                );
              },
            ),
            const SizedBox(height: 10),
            //add new here
          ],
        ),
      ),
    );
  }
}


