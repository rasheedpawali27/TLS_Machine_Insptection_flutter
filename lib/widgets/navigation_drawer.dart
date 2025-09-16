import 'package:flutter/material.dart';

class StylishDrawer extends StatelessWidget {
  const StylishDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Drawer Header
              const UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.transparent),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage("assets/images/login.png"),
                  radius: 30,
                ),
                accountName: Text("John Doe",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                accountEmail: Text("Line: A1",
                    style: TextStyle(fontSize: 14)),
              ),

              // Grid Navigation
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  padding: const EdgeInsets.all(12),
                  children: [
                    _buildNavItem(Icons.inventory, "Inline", Colors.orange, context),
                    _buildNavItem(Icons.assignment, "Endline", Colors.green, context),
                    _buildNavItem(Icons.summarize, "DHU", Colors.red, context),
                    _buildNavItem(Icons.bar_chart, "Round", Colors.purple, context),
                    _buildNavItem(Icons.article, "Operation", Colors.indigo, context),
                    _buildNavItem(Icons.settings, "Settings", Colors.grey, context),
                    _buildNavItem(Icons.help, "Help", Colors.teal, context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Grid Button UI
  Widget _buildNavItem(
      IconData icon, String label, Color color, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // Yaha apni navigation laga dena
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: color.withOpacity(0.4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
