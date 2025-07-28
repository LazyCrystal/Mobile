import 'package:flutter/material.dart';
import 'package:mobile_assignment/Schedule.dart';
import 'invoice.dart';
import 'inventory.dart';
import 'Customer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GearShift Management',
          style: TextStyle(
            color: Color(0xFF0D141C),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Your Dashboard',
              style: TextStyle(
                color: Color(0xFF0D141C),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildNavCard(
                    context,
                    icon: Icons.local_shipping,
                    title: 'Vehicles',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PlaceholderScreen(title: 'Vehicles')),
                      );
                    },
                  ),
                  _buildNavCard(
                    context,
                    icon: Icons.calendar_today,
                    title: 'Schedule',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SchedulePage()),
                      );
                    },
                  ),
                  _buildNavCard(
                    context,
                    icon: Icons.people,
                    title: 'CRM',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CustomerScreen()),
                      );
                    },
                  ),
                  _buildNavCard(
                    context,
                    icon: Icons.inventory,
                    title: 'Inventory',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InventoryScreen()),
                      );
                    },
                  ),
                  _buildNavCard(
                    context,
                    icon: Icons.description,
                    title: 'Invoices',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InvoiceScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Home page as default
        selectedItemColor: const Color(0xFF0D141C),
        unselectedItemColor: const Color(0xFF49739C),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        backgroundColor: const Color(0xFFF8FAFC),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping, size: 24),
            label: 'Vehicles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, size: 24),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, size: 24),
            label: 'CRM',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory, size: 24),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description, size: 24),
            label: 'Invoices',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlaceholderScreen(title: 'Vehicles')),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SchedulePage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CustomerScreen()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InventoryScreen()),
              );
              break;
            case 5:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InvoiceScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildNavCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      color: const Color(0xFFE7EDF4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: const Color(0xFF0D141C)),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0D141C),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Placeholder widget for screens not yet implemented
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
      ),
      body: Center(
        child: Text('$title Screen', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}