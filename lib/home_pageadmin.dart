import 'package:flutter/material.dart';
import 'db.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({super.key});

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    searchController.addListener(_filterUsers);
  }

  Future<void> _loadUsers() async {
    final data = await DBHelper.instance.getAllUsers();
    setState(() {
      users = data;
      filteredUsers = data;
    });
  }

  void _filterUsers() {
    String keyword = searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users
          .where((user) =>
          user['username'].toLowerCase().contains(keyword))
          .toList();
    });
  }

  Future<void> _deleteUser(String username) async {
    if (username == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('admin cannot be deleted.')),
      );
      return;
    }
    await DBHelper.instance.deleteUser(username);
    _loadUsers();
  }

  void _showEditDialog(Map<String, dynamic> user) {
    final TextEditingController passwordController =
    TextEditingController(text: user['password']);
    String error = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('edit user：${user['username']}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'new password'),
                  obscureText: true,
                ),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(error, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final newPassword = passwordController.text.trim();
                  if (newPassword.isEmpty) {
                    setState(() => error = 'Password cannot be empty');
                    return;
                  }
                  await DBHelper.instance.updateUserPassword(
                      user['username'], newPassword);
                  Navigator.pop(context);
                  _loadUsers();
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String errorText = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add new user'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  if (errorText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(errorText,
                          style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final username = usernameController.text.trim();
                    final password = passwordController.text.trim();

                    if (username.isEmpty || password.isEmpty) {
                      setState(() => errorText = 'Please fill full information.');
                      return;
                    }

                    final success = await DBHelper.instance.addUser(
                        username, password);
                    if (success) {
                      Navigator.pop(context);
                      _loadUsers();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User added successfully.')),
                      );
                    } else {
                      setState(() => errorText = 'User already accessed');
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin user control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddUserDialog(context),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search user.',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return ListTile(
                  title: Text(user['username']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteUser(user['username']),
                  ),
                  onTap: () => _showEditDialog(user),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}




