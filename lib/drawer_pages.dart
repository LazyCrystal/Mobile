import 'package:flutter/material.dart';
import 'base_scaffold.dart';

// My Account Page
class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'My Account',
      currentIndex: 0,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            const SizedBox(height: 24),
            _buildAccountInfoSection(),
            const SizedBox(height: 24),
            _buildPreferencesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF3D98F4),
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'John Doe',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D141C),
            ),
          ),
          const Text(
            'john.doe@stitchdesign.com',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF49739C),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Add edit profile functionality
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D98F4),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          const Text(
            'Account Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D141C),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('User ID', 'USR001'),
          _buildInfoRow('Role', 'Administrator'),
          _buildInfoRow('Department', 'Management'),
          _buildInfoRow('Join Date', 'January 15, 2024'),
          _buildInfoRow('Last Login', 'Today, 2:30 PM'),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D141C),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive email updates'),
            value: true,
            onChanged: (value) {},
            activeColor: const Color(0xFF3D98F4),
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive push notifications'),
            value: false,
            onChanged: (value) {},
            activeColor: const Color(0xFF3D98F4),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: false,
            onChanged: (value) {},
            activeColor: const Color(0xFF3D98F4),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF49739C),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0D141C),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Region & Language Page
class RegionLanguagePage extends StatefulWidget {
  const RegionLanguagePage({super.key});

  @override
  State<RegionLanguagePage> createState() => _RegionLanguagePageState();
}

class _RegionLanguagePageState extends State<RegionLanguagePage> {
  String _selectedLanguage = 'English';
  String _selectedRegion = 'United States';
  String _selectedCurrency = 'USD';
  String _selectedDateFormat = 'MM/DD/YYYY';
  String _selectedTimeFormat = '12 Hour';

  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];
  final List<String> _regions = ['United States', 'Canada', 'United Kingdom', 'Australia', 'Germany'];
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'CAD', 'AUD'];
  final List<String> _dateFormats = ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'];
  final List<String> _timeFormats = ['12 Hour', '24 Hour'];

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Region & Language',
      currentIndex: 0,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLanguageSection(),
            const SizedBox(height: 24),
            _buildRegionSection(),
            const SizedBox(height: 24),
            _buildFormatSection(),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          const Text(
            'Language',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D141C),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _languages.map((String language) {
              return DropdownMenuItem<String>(
                value: language,
                child: Text(language),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedLanguage = newValue;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          const Text(
            'Region & Currency',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D141C),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedRegion,
            decoration: const InputDecoration(
              labelText: 'Region',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _regions.map((String region) {
              return DropdownMenuItem<String>(
                value: region,
                child: Text(region),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedRegion = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCurrency,
            decoration: const InputDecoration(
              labelText: 'Currency',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _currencies.map((String currency) {
              return DropdownMenuItem<String>(
                value: currency,
                child: Text(currency),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCurrency = newValue;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          const Text(
            'Date & Time Format',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D141C),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedDateFormat,
            decoration: const InputDecoration(
              labelText: 'Date Format',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _dateFormats.map((String format) {
              return DropdownMenuItem<String>(
                value: format,
                child: Text(format),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedDateFormat = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedTimeFormat,
            decoration: const InputDecoration(
              labelText: 'Time Format',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _timeFormats.map((String format) {
              return DropdownMenuItem<String>(
                value: format,
                child: Text(format),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedTimeFormat = newValue;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings saved successfully')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3D98F4),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Save Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// FAQ Page
class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I create a new invoice?',
      answer: 'To create a new invoice, navigate to the Invoices section from the bottom navigation bar, then tap the "+" button to start creating a new invoice.',
    ),
    FAQItem(
      question: 'How can I manage my inventory?',
      answer: 'Go to the Inventory section to view, add, edit, or delete inventory items. You can also track stock levels and set low stock alerts.',
    ),
    FAQItem(
      question: 'How do I schedule appointments?',
      answer: 'Use the Schedule section to view your calendar, create new appointments, and manage your daily schedule.',
    ),
    FAQItem(
      question: 'How can I view customer information?',
      answer: 'Navigate to the CRM section to access customer data, view customer history, and manage customer relationships.',
    ),
    FAQItem(
      question: 'How do I change my account settings?',
      answer: 'Access your account settings through the drawer menu by tapping the hamburger menu icon and selecting "My Account".',
    ),
    FAQItem(
      question: 'How can I get support?',
      answer: 'For technical support, please contact our support team at support@stitchdesign.com or call +1-800-123-4567.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'FAQ',
      currentIndex: 0,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchSection(),
            const SizedBox(height: 24),
            _buildFAQList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D141C),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search FAQ...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQList() {
    return Column(
      children: _faqItems.map((item) => _buildFAQItem(item)).toList(),
    );
  }

  Widget _buildFAQItem(FAQItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ExpansionTile(
        title: Text(
          item.question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D141C),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              item.answer,
              style: const TextStyle(
                color: Color(0xFF49739C),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

// Branches Page
class BranchesPage extends StatelessWidget {
  const BranchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Branches',
      currentIndex: 0,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 24),
            _buildBranchesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D98F4), Color(0xFF1E5F99)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Locations',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Find the nearest Stitch Design branch',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchesList() {
    final List<Branch> branches = [
      Branch(
        name: 'Main Branch',
        address: '123 Business Street, Downtown',
        city: 'New York, NY 10001',
        phone: '+1 (555) 123-4567',
        hours: 'Mon-Fri: 9:00 AM - 6:00 PM\nSat: 10:00 AM - 4:00 PM',
        isMain: true,
      ),
      Branch(
        name: 'Westside Branch',
        address: '456 Commerce Avenue',
        city: 'Los Angeles, CA 90210',
        phone: '+1 (555) 987-6543',
        hours: 'Mon-Fri: 8:00 AM - 7:00 PM\nSat: 9:00 AM - 5:00 PM',
        isMain: false,
      ),
      Branch(
        name: 'North Branch',
        address: '789 Corporate Plaza',
        city: 'Chicago, IL 60601',
        phone: '+1 (555) 456-7890',
        hours: 'Mon-Fri: 9:00 AM - 5:30 PM\nSat: 10:00 AM - 3:00 PM',
        isMain: false,
      ),
    ];

    return Column(
      children: branches.map((branch) => _buildBranchCard(branch)).toList(),
    );
  }

  Widget _buildBranchCard(Branch branch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: branch.isMain ? const Color(0xFF3D98F4) : const Color(0xFF49739C),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  branch.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: branch.isMain ? const Color(0xFF3D98F4) : const Color(0xFF0D141C),
                  ),
                ),
              ),
              if (branch.isMain)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D98F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'MAIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            branch.address,
            style: const TextStyle(
              color: Color(0xFF0D141C),
              fontSize: 14,
            ),
          ),
          Text(
            branch.city,
            style: const TextStyle(
              color: Color(0xFF49739C),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.phone,
                color: Color(0xFF49739C),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                branch.phone,
                style: const TextStyle(
                  color: Color(0xFF49739C),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.access_time,
                color: Color(0xFF49739C),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  branch.hours,
                  style: const TextStyle(
                    color: Color(0xFF49739C),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Add directions functionality
                  },
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text('Directions'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3D98F4),
                    side: const BorderSide(color: Color(0xFF3D98F4)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Add call functionality
                  },
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D98F4),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Branch {
  final String name;
  final String address;
  final String city;
  final String phone;
  final String hours;
  final bool isMain;

  Branch({
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.hours,
    required this.isMain,
  });
}
