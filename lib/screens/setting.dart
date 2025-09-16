import 'package:flutter/material.dart';
import 'package:tls_inspection_machine/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();

  // Settings state
  bool _notificationsEnabled = true;
  bool _soundEffects = true;
  bool _vibration = true;
  bool _autoSync = true;
  bool _darkMode = false;
  String _language = 'English';
  String _inspectionMode = 'Auto';
  double _fontSize = 16.0;

  final List<String> _languages = ['English', 'Urdu', 'Arabic', 'Chinese'];
  final List<String> _inspectionModes = ['Auto', 'Manual'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SETTINGS - ${_authService.currentUser?.fullName ?? 'User Preferences'}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade600,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User Profile Section
            _buildSectionHeader('USER PROFILE'),
            _buildUserProfileCard(),
            const SizedBox(height: 20),

            // Application Settings
            _buildSectionHeader('APPLICATION SETTINGS'),
            _buildSettingCard(
              Icons.notifications,
              'Notifications',
              'Enable app notifications',
              Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ),
            _buildSettingCard(
              Icons.volume_up,
              'Sound Effects',
              'Enable sound feedback',
              Switch(
                value: _soundEffects,
                onChanged: (value) {
                  setState(() {
                    _soundEffects = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ),
            _buildSettingCard(
              Icons.vibration,
              'Vibration',
              'Enable vibration feedback',
              Switch(
                value: _vibration,
                onChanged: (value) {
                  setState(() {
                    _vibration = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ),
            _buildSettingCard(
              Icons.sync,
              'Auto Sync',
              'Automatically sync data',
              Switch(
                value: _autoSync,
                onChanged: (value) {
                  setState(() {
                    _autoSync = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ),
            _buildSettingCard(
              Icons.dark_mode,
              'Dark Mode',
              'Enable dark theme',
              Switch(
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ),

            // Inspection Settings
            _buildSectionHeader('INSPECTION SETTINGS'),
            _buildSettingCard(
              Icons.inventory,
              'Inspection Mode',
              'Default inspection mode',
              DropdownButton<String>(
                value: _inspectionMode,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                elevation: 4,
                style: const TextStyle(color: Colors.blue),
                underline: Container(height: 0),
                onChanged: (String? newValue) {
                  setState(() {
                    _inspectionMode = newValue!;
                  });
                },
                items: _inspectionModes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            // Language Settings
            _buildSectionHeader('LANGUAGE & DISPLAY'),
            _buildSettingCard(
              Icons.language,
              'Language',
              'App language preference',
              DropdownButton<String>(
                value: _language,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                elevation: 4,
                style: const TextStyle(color: Colors.blue),
                underline: Container(height: 0),
                onChanged: (String? newValue) {
                  setState(() {
                    _language = newValue!;
                  });
                },
                items: _languages.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            _buildSettingCard(
              Icons.text_fields,
              'Font Size',
              'Adjust text size',
              Slider(
                value: _fontSize,
                min: 12.0,
                max: 24.0,
                divisions: 6,
                label: _fontSize.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _fontSize = value;
                  });
                },
                activeColor: Colors.blue,
                inactiveColor: Colors.blue.shade200,
              ),
            ),

            // Actions Section
            _buildSectionHeader('ACTIONS'),
            _buildActionCard(
              Icons.sync,
              'Sync Data Now',
              'Manually sync operators and faults',
              Colors.blue,
                  () {
                _syncData();
              },
            ),
            _buildActionCard(
              Icons.cached,
              'Clear Cache',
              'Free up storage space',
              Colors.orange,
                  () {
                _clearCache();
              },
            ),
            _buildActionCard(
              Icons.help,
              'Help & Support',
              'Get assistance with the app',
              Colors.green,
                  () {
                _showHelp();
              },
            ),
            _buildActionCard(
              Icons.info,
              'About',
              'App version and information',
              Colors.purple,
                  () {
                _showAbout();
              },
            ),

            const SizedBox(height: 30),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout),
                label: const Text(
                  'LOGOUT',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Text(
                _authService.currentUser?.fullName?.substring(0, 1) ?? 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _authService.currentUser?.fullName ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Line: ${_authService.currentUser?.assignedLine ?? 'Not assigned'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Role: Inspector',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Edit profile action
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(IconData icon, String title, String subtitle, Widget control) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            control,
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _syncData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Syncing operators and faults...'),
        backgroundColor: Colors.blue[800],
        duration: const Duration(seconds: 2),
      ),
    );

    // Simulate sync process
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync completed successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear all cached data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'For assistance with the Denim TLS Inspection App, please contact:\n\n'
              'Denim MIS Team\n'
              'Email: denim@interloop.com.pk\n'
              'Phone: +92-3014557836',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Denim TLS Inspection App\n'
              'Version: 0.1\n\n'
              'Developed by Denim Team\n'
              '© 2025 Interloop Denim Inspection Systems',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade300),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}