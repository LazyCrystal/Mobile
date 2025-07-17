import 'package:flutter/material.dart';

void main() {
  runApp(const InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});
//hi yizheng here
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stitch Design',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D141C),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Inter',
      ),
      home: const InventoryScreen(),
    );
  }
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> inventoryItems = [
      {
        'partNumber': 'Part #12345',
        'name': 'Brake Pad Set',
        'quantity': 10,
        'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuC_U40D2uj2wJcyU34FtthgXcaKY8Fd2J_Jcmh5Ao9E528wYz1NzDXDX_KOfZ-CuQfPE5ZdQpLjvsH3PSGUk-dHcxOdgM_Lse3Tsy6zhrGHEACKhOjlcRKMJKNZJ0tLNM9cPOwyKQUQsTHMJJdb2FNnJDLKgrBKqhUiESQq74hDZzRy1NZrZs_xFxEBGsZeR0Y9-agH740Snuk3V-3oMIry7xtHYZqOtYv2YZtwlXg7yn3z_Z8Vh1n8Caok060GGYB9A18NGiVHWw0'
      },
      {
        'partNumber': 'Part #67890',
        'name': 'Oil Filter',
        'quantity': 25,
        'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCTV6kyh1HNb1P-KkrsrYDF_iJDyGNgFtNCwZiicLtS8fpPtA6SY7BZf4YhWZilnA1L8txIOd0b-JLDSngWOpEsHnfNpwMLSerb6-B9d4sObEb8CbmvMVY1TpsHKaQPCLYeQCbo7ClhyIHDcVI9BoXJUHj4KqdSBKQtS0JlCwMl4aDECrJ7Hx5SpoNSNWCNdNg7kAKqgIX9_ht457t53Fjo4jTTBr5xDGBFls7uzrZ1TBgKWzr_-c94jJYT-r1D4bRJ9MkjlWTiS_o'
      },
      {
        'partNumber': 'Part #11223',
        'name': 'Spark Plug',
        'quantity': 50,
        'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAyk-S2moT7gBZ-w47Uy2fL8FQzeMnFDb_zA9Yts4BBH46Hl4CT218DZcOY_WIGYkbvdy6pR4L84UjIXwd0_wmlkDVbhavY3gGUsiGtBPLeYf_L_PClZcRNk6o1PhOER4zn3dswrRm0djDtEOftOClv2hUfxBaicwgqFcgnZuFLUV4FGom9iu_PiWCG1QpD88ju7bTrQJIbTrzXItTP7BrvzZuamRC98P0EM5xYBde5IqoHEPIadE2SJ06ewY3NoKv1JMFSocpFA6yU'
      },
      {
        'partNumber': 'Part #33445',
        'name': 'Tire',
        'quantity': 4,
        'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAmlnzlwdmDo4-qsw2JiPyR5nPeXDaUIlWAXMVQMlxpv1xEVWIim3nJO61KLSD5gmG1B26QngWP4WovZQK5xLzOD3vubDAxF7CjehTsyre5zyva7S8ZkF_pkAhqaRsH0obX7_B6q0Vh3UDHv1bMsW4z70PgJTeIgAOg2F9XYrE3TYW_CKAmE7l8ypDvytcwJ53TCF1SxEWtbQWzKF8Iua_-2Hsv-kMPMQoYVV3G-5VhaLgMAjk9iIkNaM0huu7n_QWIZBkx8IZzaW8'
      },
      {
        'partNumber': 'Part #55667',
        'name': 'Headlight Bulb',
        'quantity': 12,
        'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAZXvK4lJFzf0lN69synfvYWNlA9DJNBfwOq6qMB5bL4NmnYy05ygRNukcehHFDpmH8WLVMrZf62KEq20xpmCSEB15rT81zhyvd04Ea0gjAOfk6AHp1KpAro7taFYJoFLTN4Pnw3ypl6jJXvZZD0o81BLocfoX__PbZeWNY12DRFGdquSw-0tMonyEPY-G-tNoVRymjl-zMjaiGDOeG3nkTvJLKq3LlchiMyA6Mo5u046R47z9x4W_vp4tT4G4Ui5vlQsFxGPTeheI'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventory',
          style: TextStyle(
            color: Color(0xFF0D141C),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF0D141C), size: 24),
            onPressed: () {
              // TODO: Implement add item functionality
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAFC),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search parts',
                hintStyle: const TextStyle(color: Color(0xFF49739C)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF49739C)),
                filled: true,
                fillColor: const Color(0xFFE7EDF4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Parts',
              style: TextStyle(
                color: Color(0xFF0D141C),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: inventoryItems.length,
              itemBuilder: (context, index) {
                final item = inventoryItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item['imageUrl'],
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['partNumber'],
                              style: const TextStyle(
                                color: Color(0xFF0D141C),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item['name'],
                              style: const TextStyle(
                                color: Color(0xFF49739C),
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item['quantity'].toString(),
                        style: const TextStyle(
                          color: Color(0xFF0D141C),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF8FAFC),
        selectedItemColor: const Color(0xFF0D141C),
        unselectedItemColor: const Color(0xFF49739C),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        currentIndex: 3, // Inventory selected
        items: const [
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
          // TODO: Implement navigation
        },
      ),
    );
  }
}