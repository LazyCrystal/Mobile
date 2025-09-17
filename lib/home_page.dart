import 'package:flutter/material.dart';
import 'package:mobile_assignment/Schedule.dart';
import 'package:intl/intl.dart';
import 'invoice.dart';
import 'inventory.dart';
import 'Customer.dart';
import 'firebase_invoice_service.dart';
import 'inventory_service.dart';
import 'customer_service.dart';
import 'schedule_service.dart';
import 'base_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 添加 Firestore 导入
import 'vehicle.dart'; // 添加 Vehicle 页面导入

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;

  // Dashboard data
  int _totalVehicles = 0; // 添加车辆总数
  int _totalInvoices = 0;
  double _totalRevenue = 0.0;
  int _totalInventoryItems = 0;
  int _lowStockItems = 0;
  int _totalCustomers = 0;
  int _upcomingAppointments = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 添加：从 Firestore 'vehicles' 集合加载车辆数量
      try {
        final vehicleSnapshot = await FirebaseFirestore.instance.collection('vehicles').get();
        _totalVehicles = vehicleSnapshot.docs.length;
      } catch (e) {
        print('Error loading vehicles count: $e');
        _totalVehicles = 0;
      }

      // Load invoices data
      final invoices = await FirebaseInvoiceService.getAllInvoices();
      _totalInvoices = invoices.length;

      // Calculate total revenue from paid invoices
      _totalRevenue = invoices
          .where((invoice) => _getInvoiceStatus(invoice) == 'Paid')
          .fold(0.0, (sum, invoice) {
        final amount = double.tryParse(invoice['totalAmount']?.replaceAll('\$', '') ?? '0.0') ?? 0.0;
        return sum + amount;
      });

      // Load inventory data
      final inventoryItems = await InventoryService.getAllInventoryItems();
      _totalInventoryItems = inventoryItems.length;
      _lowStockItems = inventoryItems.where((item) => (item['quantity'] ?? 0) <= 5).length;

      // Load customer count
      _totalCustomers = await CustomerService.getTotalCustomersCount();

      // Load upcoming appointments count
      _upcomingAppointments = await ScheduleService.getUpcomingAppointmentsCount();

    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper to get invoice status
  String _getInvoiceStatus(Map<String, dynamic> invoice) {
    if (invoice['status'] == 'Draft' || invoice['status'] == 'Rejected') {
      return invoice['status'];
    }

    final totalAmount = double.tryParse(invoice['totalAmount']?.replaceAll('\$', '') ?? '0.0') ?? 0.0;
    final payments = invoice['payments'] as List<dynamic>? ?? [];
    final paidAmount = payments.fold(0.0, (sum, payment) => sum + (double.tryParse(payment['amount'] ?? '0.0') ?? 0.0));

    if (paidAmount >= totalAmount && totalAmount > 0) {
      return 'Paid';
    } else if (paidAmount > 0 && paidAmount < totalAmount) {
      return 'Partially Paid';
    } else if (_isOverdue(invoice)) {
      return 'Overdue';
    } else {
      return 'Unpaid';
    }
  }

  // Helper to check if invoice is overdue
  bool _isOverdue(Map<String, dynamic> invoice) {
    final totalAmount = double.tryParse(invoice['totalAmount']?.replaceAll('\$', '') ?? '0.0') ?? 0.0;
    final payments = invoice['payments'] as List<dynamic>? ?? [];
    final paidAmount = payments.fold(0.0, (sum, payment) => sum + (double.tryParse(payment['amount'] ?? '0.0') ?? 0.0));

    if (invoice['dueDate'] != null && paidAmount < totalAmount) {
      try {
        final dueDate = DateFormat('yyyy-MM-dd').parse(invoice['dueDate']);
        final now = DateTime.now();
        return dueDate.isBefore(DateTime(now.year, now.month, now.day));
      } catch (e) {
        print('Error parsing due date for overdue check: $e');
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Stitch Design Dashboard',
      currentIndex: 0,
      onRefresh: _loadDashboardData,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildQuickActionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Good Morning' : now.hour < 18 ? 'Good Afternoon' : 'Good Evening';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D98F4), Color(0xFF1E5F99)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Welcome to Stitch Design',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Total Revenue: \$${_totalRevenue.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D141C),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            // 添加：车辆统计卡片（第一个）
            _buildStatCard(
              'Vehicles',
              _totalVehicles.toString(),
              Icons.directions_car,
              const Color(0xFF2196F3),
            ),
            _buildStatCard(
              'Customers',
              _totalCustomers.toString(),
              Icons.people,
              const Color(0xFF9C27B0),
            ),
            _buildStatCard(
              'Upcoming Appointments',
              _upcomingAppointments.toString(),
              Icons.calendar_today,
              const Color(0xFFFF9800),
            ),
            _buildStatCard(
              'Total Invoices',
              _totalInvoices.toString(),
              Icons.receipt_long,
              const Color(0xFF3D98F4),
            ),
            _buildStatCard(
              'Inventory Items',
              _totalInventoryItems.toString(),
              Icons.inventory_2,
              const Color(0xFF4CAF50),
            ),
            _buildStatCard(
              'Low Stock',
              _lowStockItems.toString(),
              Icons.inventory,
              const Color(0xFFF57C00),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF49739C),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D141C),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            // 添加：车辆管理快速操作（第一个）
            _buildQuickActionCard(
              'Vehicle Management',
              Icons.directions_car,
              const Color(0xFF2196F3),
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VehiclePage()),
                );
              },
            ),
            _buildQuickActionCard(
              'Create Invoice',
              Icons.add_circle_outline,
              const Color(0xFF3D98F4),
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InvoiceScreen()),
                );
              },
            ),
            _buildQuickActionCard(
              'Add Inventory',
              Icons.inventory_2_outlined,
              const Color(0xFF4CAF50),
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InventoryScreen()),
                );
              },
            ),
            _buildQuickActionCard(
              'View Customers',
              Icons.people_outline,
              const Color(0xFF9C27B0),
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomerScreen()),
                );
              },
            ),
            _buildQuickActionCard(
              'Schedule',
              Icons.calendar_today,
              const Color(0xFFFF9800),
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SchedulePage()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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