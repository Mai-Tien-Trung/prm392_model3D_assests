import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Home",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 50),

                // 3 NÚT CHÍNH
                _buildButton(
                  text: "3D Model Generate",
                  onTap: () => Navigator.pushNamed(context, '/generate'),
                  icon: Icons.auto_awesome,
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),

                _buildButton(
                  text: "Membership",
                  onTap: () {
                    // TODO: Chuyển đến trang Membership
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Membership Page (Coming Soon)")),
                    );
                  },
                  icon: Icons.card_membership,
                  color: Colors.purple,
                ),
                const SizedBox(height: 20),

                _buildButton(
                  text: "Logout",
                  onTap: logout,
                  icon: Icons.logout,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 20),
            Text(
              text,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}