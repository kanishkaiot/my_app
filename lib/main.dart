import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LabLinkApp());
}

class LabLinkApp extends StatelessWidget {
  const LabLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121820),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ─── LOGIN PAGE ───────────────────────────────────────
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'LabLink Login',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 40),
              _buildTextField('Username', 'enter username', false),
              const SizedBox(height: 16),
              _buildTextField('Email', 'enter email', false),
              const SizedBox(height: 16),
              _buildTextField('Password', 'enter password', true),
              const SizedBox(height: 24),
              SizedBox(
                width: 160,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DashboardPage()),
                    );
                  },
                  child: const Text('submit',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1B2430),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            suffixIcon: isPassword
                ? const Icon(Icons.visibility_off, color: Colors.white38)
                : null,
          ),
        ),
      ],
    );
  }
}

// ─── DASHBOARD PAGE ───────────────────────────────────
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool lightsOn = false;
  bool fansOn = false;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();

    // Listen to light1 realtime changes
    FirebaseDatabase.instance
        .ref("devices/lab_switch/light1")
        .onValue
        .listen((event) {
      setState(() => lightsOn = (event.snapshot.value as bool?) ?? false);
    });

    // Listen to light2 realtime changes
    FirebaseDatabase.instance
        .ref("devices/lab_switch/light2")
        .onValue
        .listen((event) {
      setState(() => fansOn = (event.snapshot.value as bool?) ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        leading: const BackButton(color: Colors.white),
        title: const Text('Back', style: TextStyle(color: Colors.white)),
        toolbarHeight: 80,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('LabLink',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9800))),
            const Text('Smart Lab Automation',
                style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 24),
            const Text('Devices',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 12),
            _buildDeviceCard(
              icon: Icons.lightbulb,
              iconColor: const Color(0xFFFF9800),
              title: 'Lab Lights',
              subtitle: lightsOn ? 'Zone A-C Active' : 'All Off',
              value: lightsOn,
              onChanged: (v) {
                print("LIGHT 1 SWITCH: $v");
                FirebaseDatabase.instance
                    .ref("devices/lab_switch/light1")
                    .set(v);
                setState(() => lightsOn = v);
              },
            ),
            const SizedBox(height: 12),
            _buildDeviceCard(
              icon: Icons.wind_power,
              iconColor: Colors.blueGrey,
              title: 'Ventilation Fans',
              subtitle: fansOn ? 'Running' : 'All Units Offline',
              value: fansOn,
              onChanged: (v) {
                print("LIGHT 2 SWITCH: $v");
                FirebaseDatabase.instance
                    .ref("devices/lab_switch/light2")
                    .set(v);
                setState(() => fansOn = v);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1B2430),
        selectedItemColor: const Color(0xFFFF9800),
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Status'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildDeviceCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2430),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6C63FF),
          ),
        ],
      ),
    );
  }
}